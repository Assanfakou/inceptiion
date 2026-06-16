# Portainer Service Explanation

## What is Portainer?

Portainer is a web-based Docker management UI.

It allows you to manage your entire Docker infrastructure visually:
* view and manage containers (start, stop, restart, delete)
* inspect images
* manage volumes
# Portainer (concise, matches Dockerfile)

## What
- Web UI to manage Docker hosts, containers, images, networks and volumes.
- In this project Portainer is provided as a lightweight binary extracted into `/portainer` and run directly.

## Dockerfile (exact)
From `srcs/requirements/bonus/portainer/Dockerfile`:

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y curl tar
RUN curl -L https://github.com/portainer/portainer/releases/download/2.27.6/portainer-2.27.6-linux-amd64.tar.gz -o portainer.tar.gz
RUN mkdir /portainer && tar -xvf portainer.tar.gz -C /
WORKDIR /portainer
CMD ["./portainer"]
```

- Downloads the Portainer release tarball, extracts it to the root filesystem, and runs the `portainer` binary from `/portainer`.
- The image does not explicitly `EXPOSE` a port in the Dockerfile; Portainer's default ports are documented upstream (commonly `9000` for the HTTP UI and `9443` for HTTPS). Verify the running container to see which ports are active.

## Docker socket (recommended)
To manage the host Docker engine Portainer must access the Docker socket. Typical compose snippet:

```yaml
services:
  portainer:
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Mounting `/var/run/docker.sock` allows Portainer to control the Docker daemon on the host. Without it Portainer will start but cannot manage the host.

## Quick checks (replace `<portainer>`)
```bash
# Is container running?
docker ps | grep portainer

# Check that Docker socket is present inside the container
docker exec -it <portainer> ls -l /var/run/docker.sock

# See which ports Portainer listens on inside the container
docker exec -it <portainer> ss -tlnp

# Get Portainer binary version
docker exec -it <portainer> /portainer/portainer --version

# If UI is reachable from host (adjust host/port):
curl -I http://localhost:9000 || curl -I https://localhost:9443
```

## Notes / Security
- The Dockerfile disables no extra access controls — controlling access to Portainer is your responsibility.
- Mounting the Docker socket gives the container root-level control over the host. Only mount it on trusted hosts.
- The Dockerfile in this repo does not enable TLS or authentication; Portainer handles authentication when you first visit the UI, but network-level protections (firewalls, not publishing ports to public interfaces) are recommended.

