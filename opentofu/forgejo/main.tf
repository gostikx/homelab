variable "ssh_host"     { type = string }
variable "ssh_user"     { type = string }
variable "ssh_key"      { type = string }
variable "network_name" { type = string }

variable "shared_state_dir" {
  type        = string
  description = "Глобальный путь к состояниям, передаваемый из системы"
}

terraform {
  backend "local" {
    path          = "${var.shared_state_dir}/forgejo/terraform.tfstate"
    workspace_dir = "${var.shared_state_dir}/forgejo"
  }
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

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.ssh_host}:22"
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
