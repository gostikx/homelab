variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host        = string
    port        = number
    user        = string
    key         = string
  })
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version  = ">= 4.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

resource "docker_image" "forgejo" {
  name = "codeberg.org/forgejo/forgejo:16.0.3-rootless"
}

resource "docker_volume" "forgejo-data" {
  name = "forgejo_data"
}

resource "docker_container" "forgejo" {
  name      = "forgejo"
  image     = docker_image.forgejo.image_id
  restart   = "always"

  user = "1000:1000"

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
  ]

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.forgejo-data.name
    container_path = "/data"
  }

  networks_advanced {
    name = var.network_name
  }
}
