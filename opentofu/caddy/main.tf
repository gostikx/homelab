variable "network_name"     { type = string }
variable "shared_state_dir" { type = string}

variable "ssh_config" {
  type = object({
    host        = string
    port        = number
    user        = string
    key         = string
  })
}

terraform {
  backend "local" {
    path          = "${var.shared_state_dir}/caddy/terraform.tfstate"
    workspace_dir = "${var.shared_state_dir}/caddy"
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

resource "null_resource" "setup_server_dirs" {
  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/stacks/caddy/config",
      "mkdir -p /opt/stacks/caddy/certs",
      "chmod 700 /opt/stacks/caddy",
    ]
  }
}

resource "null_resource" "upload_caddy_config" {
  depends_on = [null_resource.setup_server_dirs]

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/config/"
    destination = "/opt/stacks/caddy/config"
  }

  provisioner "remote-exec" {
    inline = [
      "find /opt/stacks/caddy/config -type d -exec chmod 700 {} \\;",
      "find /opt/stacks/caddy/config -type f -exec chmod 600 {} \\;"
    ]
  }
}

resource "null_resource" "upload_caddy_certs" {
  depends_on = [null_resource.setup_server_dirs]

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/certs/"
    destination = "/opt/stacks/caddy/certs"
  }

  provisioner "remote-exec" {
    inline = [
      "find /opt/stacks/caddy/certs -type d -exec chmod 700 {} \\;",
      "find /opt/stacks/caddy/certs -type f -exec chmod 600 {} \\;"
    ]
  }
}

resource "docker_image" "caddy" {
  name = "caddy:2.11.4-alpine"
}

resource "docker_container" "caddy" {
  name      = "caddy"
  image     = docker_image.caddy.image_id
  restart   = "always"

  volumes {
    host_path      = "/opt/stacks/caddy/config"
    container_path = "/etc/caddy"
    read_only      = true
  }

  volumes {
    host_path      = "/opt/stacks/caddy/certs"
    container_path = "/data/caddy/certificates/local"
    read_only      = true
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  networks_advanced {
    name = var.network_name
  }
}
