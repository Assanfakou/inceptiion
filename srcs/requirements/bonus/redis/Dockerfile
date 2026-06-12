FROM debian:12

RUN apt-get update && apt-get install -y redis-server

EXPOSE 6379

CMD ["redis-server", "--bind", "0.0.0.0", "--port", "6379", "--protected-mode", "no"]
