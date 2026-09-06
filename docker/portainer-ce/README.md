# Portainer (docker container manager)

[Official documentation](https://github.com/portainer/portainer "Go to portainer")

Install withoud save file:

```sh
$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/portainer-ce/docker-compose.yaml | docker compose -f - up -d

или

$ curl -sSL https://raw.githubusercontent.com/gostikx/homelab/refs/heads/main/docker/portainer-ce/docker-compose.yaml -o docker-compose.yml
$ docker compose up -d

```