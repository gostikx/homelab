variable "ssh_host"     { type = string }
variable "ssh_user"     { type = string }
variable "network_name" { type = string }

variable "shared_state_dir" {
  type        = string
  description = "Глобальный путь к состояниям, передаваемый из системы"
}

terraform {
  backend "local" {
    path          = "${var.shared_state_dir}/portainer/terraform.tfstate"
    workspace_dir = "${var.shared_state_dir}/portainer"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version  = ">= 4.0.0"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.ssh_host}:22"
}

resource "docker_image" "portainer-ce" {
  name = "portainer/portainer-ce:2.45.0-alpine"
}

resource "docker_volume" "portainer-ce-data" {
  name = "portainer_data"
}

resource "docker_container" "portainer-ce" {
  name      = "portainer-ce"
  image     = docker_image.portainer-ce.image_id
  restart   = "always"

  volumes {
    volume_name    = docker_volume.portainer-ce-data.name
    container_path = "/data"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  ports {
    internal = 8000
    external = 8000
  }

  ports {
    internal = 9000
    external = 9000
  }

  ports {
    internal = 9433
    external = 9433
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test     = ["CMD-SHELL", "wget --spider -q http://127.0.0.1:9000 || exit 1"]

    start_period = "5s" 

    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}
