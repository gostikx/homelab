resource "null_resource" "setup_server_dirs" {
  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/stacks/mosquitto/config",
      "chmod 700 /opt/stacks/mosquitto/config",
      "mkdir -p /var/stacks/mosquitto/log",
      # Контейнер mosquitto работает под пользователем mosquitto (uid/gid 1883)
      # и должен писать сюда лог, а пользователь devops — читать его.
      # 707 даёт devops (владелец, создавший каталог) и mosquitto (others)
      # полный доступ к каталогу, 666 — к самому файлу лога.
      "chmod 707 /var/stacks/mosquitto/log",
      "touch /var/stacks/mosquitto/log/mosquitto.log",
      "chmod 666 /var/stacks/mosquitto/log/mosquitto.log"
    ]
  }
}

resource "null_resource" "upload_config" {
  depends_on = [null_resource.setup_server_dirs]

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/config/mosquitto.conf"
    destination = "/opt/stacks/mosquitto/config/mosquitto.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "find /opt/stacks/mosquitto/config -type d -exec chmod 700 {} \\;",
      "find /opt/stacks/mosquitto/config -type f -exec chmod 600 {} \\;"
    ]
  }
}

resource "docker_image" "mosquitto" {
  name = "eclipse-mosquitto:2.1.2-alpine"
}

resource "docker_volume" "mosquitto-data" {
  name = "mosquitto_data"
}

resource "docker_container" "mosquitto" {
  name    = "mosquitto"
  image   = docker_image.mosquitto.image_id
  restart = "unless-stopped"

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = "/opt/stacks/mosquitto/config"
    container_path = "/mosquitto/config"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.mosquitto-data.name
    container_path = "/mosquitto/data"
  }

  volumes {
    host_path      = "/var/stacks/mosquitto/log"
    container_path = "/mosquitto/log"
  }

  env = [
    "TZ=Europe/Moscow"
  ]

  networks_advanced {
    name = var.network_name
  }
}
