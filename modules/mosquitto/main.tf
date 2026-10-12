locals {
  stack_path  = "/opt/stacks/mosquitto"
  config_path = "${local.stack_path}/config"
  data_path   = "${local.stack_path}/data"
  log_path    = "/var/stacks/mosquitto/log"
}

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.stack_path, mode = "700" },
    { path = local.config_path, mode = "700" },
    { path = local.data_path, mode = "700" },
    { path = local.log_path, mode = "700" },
  ]
}

module "upload_config" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  local_path  = "${path.module}/config/mosquitto.conf"
  remote_path = "${local.config_path}/mosquitto.conf"

  triggers_replace = { config = filesha256("${path.module}/config/mosquitto.conf") }

  commands = [
    "find ${local.config_path} -type d -exec chmod 700 {} \\;",
    "find ${local.config_path} -type f -exec chmod 600 {} \\;",
  ]

  depends_on = [module.setup_dirs]
}

resource "docker_image" "mosquitto" {
  name = "eclipse-mosquitto:2.1.2-alpine"
}

resource "docker_container" "mosquitto" {
  name    = "mosquitto"
  image   = docker_image.mosquitto.image_id
  restart = "unless-stopped"

  user = "1001:1001"

  ports {
    internal = 1883
    external = 1883
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = local.config_path
    container_path = "/mosquitto/config"
    read_only      = true
  }

  volumes {
    volume_name    = local.data_path
    container_path = "/mosquitto/data"
  }

  volumes {
    host_path      = local.log_path
    container_path = "/mosquitto/log"
  }

  env = [
    "TZ=Europe/Moscow"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "mosquitto_sub -h 127.0.0.1 -p 1883 -t '$SYS/broker/uptime' -C 1 -W 15 || exit 1"]
    start_period = "10s"
    interval     = "30s"
    timeout      = "20s"
    retries      = 3
  }

  wait         = true
  wait_timeout = 60

  networks_advanced {
    name = var.network_name
  }
}
