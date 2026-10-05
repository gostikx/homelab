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

  env = [
    "TZ=Europe/Moscow"
  ]

  volumes {
    host_path      = "/opt/stacks/homeassistant/config"
    container_path = "/config"
  }

  healthcheck {
    test         = ["CMD-SHELL", "curl -fsS -o /dev/null http://127.0.0.1:8123/manifest.json || exit 1"]
    start_period = "60s"
    interval     = "30s"
    timeout      = "10s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 180

  networks_advanced {
    name = var.network_name
  }
}

resource "null_resource" "delete_hacs_locally" {
  provisioner "local-exec" {
    command = "rm -rf .tmp/hacs"
  }
}