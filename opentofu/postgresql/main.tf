variable "network_name"     { type = string }
variable "shared_state_dir" { type = string}

variable "postgres_config" {
  type = object({
    user      = string
    password  = string
  })
}

terraform {
  backend "local" {
    path          = "${var.shared_state_dir}/postgres/terraform.tfstate"
    workspace_dir = "${var.shared_state_dir}/postgres"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version  = ">= 4.0.0" 
    }
  }
}

resource "docker_image" "postgres" {
  name = "postgres:18.6-alpine3.24"
}

resource "docker_volume" "postgres-data" {
  name = "postgres_data"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.image_id
  restart   = "always"

  volumes {
    volume_name    = docker_volume.postgres-data.name
    container_path = "/data"
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }
  
  env = [
    "POSTGRES_USER=${postgres_config.user}",
    "POSTGRES_PASSWORD=${postgres_config.password}"
  ]
}
