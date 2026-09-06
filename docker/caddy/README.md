# Caddy (reverse proxy)

[Official documentation](https://caddyserver.com/docs/running#docker-compose "Go to caddy server")

Run service as docker container:

```sh
# Install withoud save file:
$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/caddy/docker-compose.yaml | docker compose -f - up -d

or

# Install with file
$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/caddy/docker-compose.yaml -o docker-compose.yaml
$ docker compose up -d

```