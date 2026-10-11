locals {
  data_path = "/opt/stacks/small-step-ca"

  network_host_alias = "acme.homelab.dev"
}

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.data_path, mode = "700" },
  ]
}

resource "docker_image" "step-ca" {
  name = "smallstep/step-ca:0.30.2"
}

resource "docker_container" "step-ca" {
  depends_on = [
    module.setup_dirs,
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
    "DOCKER_STEPCA_INIT_NAME=${nonsensitive(var.smallstep_config.issuer)}",
    "DOCKER_STEPCA_INIT_DNS_NAMES=${join(",", nonsensitive(var.smallstep_config.dns_names))}",
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
    test         = ["CMD-SHELL", "step ca health --ca-url https://${local.network_host_alias}:9000 --root /home/step/certs/root_ca.crt | grep -q '^ok' || exit 1"]
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