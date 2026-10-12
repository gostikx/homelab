module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.work_path, mode = 700 },
    { path = local.conf_path, mode = 700 },
  ]
}

resource "terraform_data" "upload_adguard_config" {
  triggers_replace = {
    config = local.adguard_config_hash
  }
}

module "upload_adguard_config" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  content     = local.adguard_config
  remote_path = "${local.conf_path}/AdGuardHome.yaml"

  triggers_replace = {
    config = local.adguard_config_hash
  }

  commands = [
    "find ${local.conf_path} -type d -exec chmod 700 {} \\;",
    "find ${local.conf_path} -type f -exec chmod 600 {} \\;"
  ]

  depends_on = [module.setup_dirs]
}

resource "docker_image" "adguard-home" {
  name = "adguard/adguardhome:v0.107.79"
}

resource "docker_container" "adguard-home" {
  name    = "adguard-home"
  image   = docker_image.adguard-home.image_id
  restart = "always"

  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }

  ports {
    internal = 53
    external = 53
    protocol = "tcp"
  }

  volumes {
    host_path      = local.work_path
    container_path = "/opt/adguardhome/work"
  }

  volumes {
    host_path      = local.conf_path
    container_path = "/opt/adguardhome/conf"
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -q --spider http://127.0.0.1:3000/ || exit 1"]
    start_period = "10s"
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
  }

  wait         = true
  wait_timeout = 60

  networks_advanced {
    name = var.network_name
  }

  depends_on = [terraform_data.upload_adguard_config, module.upload_adguard_config]

  lifecycle {
    replace_triggered_by = [terraform_data.upload_adguard_config]
  }
}
