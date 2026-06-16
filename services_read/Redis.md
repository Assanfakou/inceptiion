# Redis Explanation

## What
- In-memory key-value cache used to speed WordPress by reducing DB queries.
- WordPress checks Redis first; on cache miss it queries MariaDB and stores results in Redis.

## Dockerfile (exact)
From `srcs/requirements/bonus/redis/Dockerfile`:

```dockerfile
FROM debian:12
RUN apt-get update && apt-get install -y redis-server
EXPOSE 6379
CMD ["redis-server", "--bind", "0.0.0.0", "--port", "6379", "--protected-mode", "no"]
```

- Base: `debian:12`.
- Installs `redis-server` package.
- Exposes port `6379` and starts Redis bound to `0.0.0.0` with protected mode disabled.

## What the CMD flags mean
- `--bind 0.0.0.0` — listen on all container interfaces so other containers can connect.
- `--port 6379` — default Redis port (explicit in the Dockerfile).
- `--protected-mode no` — disables the protected-mode safety check (ensure Docker network isolation or add auth).

## How WordPress uses Redis (short)
1. WordPress asks for data.
2. Redis Object Cache checks Redis using keys like `wp:posts:1`.
3. If hit — return cached data. If miss — query MariaDB, cache the result, then return.

## PHP clients
- `PhpRedis` (C extension) — fastest, requires `php-redis`.
- `Predis` (pure PHP) — no extra install, commonly bundled with the cache plugin.

This project uses Predis via the Redis Object Cache plugin.

## Quick checks (replace container names if different)
```bash
# Ping Redis
docker exec -it redis redis-cli ping    # should print: PONG

# Show number of cached keys
docker exec -it redis redis-cli dbsize

# List keys (be careful on production)
docker exec -it redis redis-cli keys "*"

# Monitor live Redis commands
docker exec -it redis redis-cli monitor

# From WordPress container: check Redis plugin status
docker exec -it wordpress wp redis status --allow-root

# Check Redis is listening on 6379 inside the container
docker exec -it redis ss -tlnp | grep 6379
```

## Notes / security
- `--protected-mode no` makes Redis accept external connections without requiring a password. Only use this when the container runs on an isolated Docker network and you trust other containers. For production, prefer enabling `requirepass` or using Docker network restrictions.
- The Dockerfile exposes port `6379` but does not publish it to the host — the service is reachable from other containers only unless you map the port in your compose file.
