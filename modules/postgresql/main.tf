locals {
  data_path = "/opt/stacks/postgres/data"
  # Пользователь внутри контейнера: postgres (999/999)
  # Пользователь внутри контейнера alpine: postgres (70/70)
  user = {
    uid = 70
    gid = 70
  }
}

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.data_path, uid = local.user.uid, gid = local.user.gid },
  ]
}

resource "docker_image" "postgres" {
  name = "postgres:18.6-alpine3.24"
}

resource "docker_container" "postgres" {
  name    = "postgres"
  image   = docker_image.postgres.image_id
  restart = "always"

  env = [
    "PGDATA=/var/lib/postgresql/data/pgdata",
    "POSTGRES_USER=${nonsensitive(var.postgres_config.user)}",
    "POSTGRES_PASSWORD=${var.postgres_config.password}" # sensitive (см. variables.tf)
  ]

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = local.data_path
    container_path = "/var/lib/postgresql"
  }

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${nonsensitive(var.postgres_config.user)} || exit 1"]
    start_period = "30s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 120

  networks_advanced {
    name = var.network_name
  }
}
