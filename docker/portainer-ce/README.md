# Portainer (docker container manager)

[Official documentation](https://github.com/portainer/portainer "Go to portainer")

Run service as docker container:

```sh
# Install withoud save file:
$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/portainer-ce/docker-compose.yaml | docker compose -f - up -d

or

# Install with file
$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/portainer-ce/docker-compose.yaml -o docker-compose.yaml
$ docker compose up -d

```