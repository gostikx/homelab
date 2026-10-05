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

  networks_advanced {
    name = var.network_name
  }
}
