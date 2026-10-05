locals {
  data_path = "/opt/stacks/small-step-ca"

  network_host_alias = "acme.homelab.dev"
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
      "mkdir -p ${local.data_path}",
    ]
  }
}

resource "docker_image" "step-ca" {
  name = "smallstep/step-ca:0.30.2"
}

resource "docker_container" "step-ca" {
  depends_on = [
    null_resource.setup_server_dirs,
  ]

  name    = "smallstep"
  image   = docker_image.step-ca.image_id
  restart = "always"

  user = "1001:1001"

  working_dir = "/home/step"

  env = [
    "TZ=Europe/Moscow",
    "HOME=/home/step",
    "STEPPATH=/home/step",
    "DOCKER_STEPCA_INIT_ACME=true",
    "DOCKER_STEPCA_INIT_REMOTE_MANAGEMENT=false",
    "DOCKER_STEPCA_INIT_NAME=${var.smallstep_config.issuer}",
    "DOCKER_STEPCA_INIT_DNS_NAMES=${join(",", var.smallstep_config.dns_names)}",
    "DOCKER_STEPCA_INIT_PASSWORD=${sensitive(var.smallstep_config.password)}",
  ]

  volumes {
    host_path      = local.data_path
    container_path = "/home/step"
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  healthcheck {
    test         = ["CMD-SHELL", "step ca health --ca-url https://127.0.0.1:9000 --root /home/step/certs/root_ca.crt | grep -q '^ok' || exit 1"]
    start_period = "15s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 60

  networks_advanced {
    name    = var.network_name
    aliases = [local.network_host_alias]
  }
}

output "ca_root_path" {
  description = "Абсолютный путь к корневому сертификату на хост-машине"
  value       = "${local.data_path}/certs"
}