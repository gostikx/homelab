locals {
  data_path = "/opt/stacks/postgres/data"
  # Пользователь внутри контейнера: postgres (999/999)
  # Пользователь внутри контейнера alpine: postgres (70/70)
  user = {
    uid = 70
    gid = 70
  }
}

resource "null_resource" "setup_server_dirs" {
  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.data_path}",
      "docker run --rm -v ${local.data_path}:/target alpine chown -R ${local.user.uid}:${local.user.gid} /target"
    ]
  }
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
    "POSTGRES_USER=${var.postgres_config.user}",
    "POSTGRES_PASSWORD=${var.postgres_config.password}"
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
    test = ["CMD", "pg_isready", "-U", "postgres"]

    start_period = "5s"

    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  networks_advanced {
    name = var.network_name
  }
}
