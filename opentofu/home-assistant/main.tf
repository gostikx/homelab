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
      version = "~> 3.3.2"
    }
  }
}

resource "null_resource" "extract_hacs_locally" {
  provisioner "local-exec" {
    command = "mkdir -p .tmp/hacs && unzip -o hacs.zip -d .tmp/hacs/"
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
      "mkdir -p /opt/stacks/homeassistant/config/custom_components/hacs",
      "chmod 700 /opt/stacks/homeassistant"
    ]
  }
}

resource "null_resource" "upload_hacs" {
  depends_on = [null_resource.extract_hacs_locally, null_resource.setup_server_dirs]

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/.tmp/hacs/"
    destination = "/opt/stacks/homeassistant/config/custom_components/hacs"
  }

  provisioner "remote-exec" {
    inline = [
      "find /opt/stacks/homeassistant/config -type d -exec chmod 700 {} \\;",
      "find /opt/stacks/homeassistant/config -type f -exec chmod 600 {} \\;"
    ]
  }
}

resource "docker_image" "home_assistant" {
  name         = "ghcr.io/home-assistant/home-assistant:stable"
  keep_locally = true
}

resource "docker_container" "home_assistant" {
  depends_on = [null_resource.upload_hacs]

  name  = "homeassistant"
  image = docker_image.home_assistant.image_id
  restart = "always"

  network_mode = "host"

  env = [
    "TZ=Europe/Moscow"
  ]

  volumes {
    host_path      = "/opt/stacks/homeassistant/config"
    container_path = "/config"
  }

  networks_advanced {
    name = var.network_name
  }
}

resource "null_resource" "delete_hacs_locally" {
  provisioner "local-exec" {
    command = "rm -rf .tmp/hacs"
  }
}