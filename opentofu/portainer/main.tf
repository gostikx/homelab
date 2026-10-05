locals {
  data_path     = "/opt/stacks/portainer-ce/data"
  password_hash = bcrypt(var.portainer_admin.password)
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
      "mkdir -p ${local.data_path}"
    ]
  }
}

resource "docker_image" "portainer-ce" {
  name = "portainer/portainer-ce:2.45.0-alpine"
}

resource "docker_container" "portainer-ce" {
  name    = "portainer-ce"
  image   = docker_image.portainer-ce.image_id
  restart = "always"

  user      = "1001:1001"
  group_add = [var.docker_group_id]

  command = [
    "--admin-password=${local.password_hash}"
  ]

  volumes {
    host_path      = local.data_path
    container_path = "/data"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget --spider -q http://127.0.0.1:9000 || exit 1"]
    start_period = "10s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 60
}
