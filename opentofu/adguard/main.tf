locals {
  work_path = "/opt/stacks/adguard-home/work"
  conf_path = "/opt/stacks/adguard-home/conf"
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
      "mkdir -p ${local.work_path}",
      "mkdir -p ${local.conf_path}",
    ]
  }
}

resource "docker_image" "adguard-home" {
  name = "adguard/adguardhome:v0.107.79"
}

resource "docker_container" "adguard-home" {
  name    = "adguard-home"
  image   = docker_image.adguard-home.image_id
  restart = "always"

  ports {
    internal = 3000
    external = 8300
  }

  ports {
    internal = 80
    external = 8080
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
}
