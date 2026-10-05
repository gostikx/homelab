# variable "network_name" { type = string }
# variable "ssh_config" {
#   type = object({
#     host        = string
#     port        = number
#     user        = string
#     key         = string
#   })
# }

# terraform {
#   required_providers {
#     docker = {
#       source  = "kreuzwerker/docker"
#       version  = ">= 4.0.0" 
#     }
#     null = {
#       source  = "hashicorp/null"
#       version = ">= 3.0.0"
#     }
#     http = {
#       source  = "hashicorp/http"
#       version  = ">= 3.4"
#     }
#     local = {
#       source  = "hashicorp/local"
#       version  = ">= 2.5"
#     }
#   }
# }

resource "null_resource" "extract_hacs_locally" {
  provisioner "local-exec" {
    command = "mkdir -p .tmp/hacs && unzip -o hacs.zip -d .tmp/hacs/"
  }
}

# 1. Скачиваем файл из интернета
data "http" "download_file" {
  url = "https://github.com"

  # Необязательно: можно задать заголовки, если сервер требует авторизацию или User-Agent
  request_headers = {
    Accept = "application/octet-stream"
  }
}

# 2. Сохраняем скачанный файл на локальный диск
resource "local_sensitive_file" "save_zip" {
  # local_sensitive_file используется вместо local_file, 
  # чтобы бинарный контент (zip) не выводился в консоль (stdout) при tofu apply

  content_base64 = data.http.download_file.response_body_base64
  filename       = "${path.module}/plugin.zip"
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

  name    = "homeassistant"
  image   = docker_image.home_assistant.image_id
  restart = "always"

  # HA и mosquitto живут в одной docker-сети (homelab-network): HA обращается
  # к брокеру по имени контейнера (mosquitto:1883) напрямую, без TLS.
  # ВНИМАНИЕ: если понадобится mDNS/SSDP-обнаружение устройств, верните
  # network_mode = "host" и опубликуйте mosquitto на 127.0.0.1:1883 вместо этого.
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