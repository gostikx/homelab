locals {
  data_path = "/opt/stacks/3x-ui/data"
}

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.data_path, mode = "700" },
  ]
}

resource "docker_image" "mhsanaei-3x-ui" {
  name = "ghcr.io/mhsanaei/3x-ui:v3.9.0"
}

resource "docker_container" "mhsanaei-3x-ui" {
  name    = "3x-ui"
  image   = docker_image.mhsanaei-3x-ui.image_id
  restart = "always"

  volumes {
    host_path      = local.data_path
    container_path = "/data"
  }

  networks_advanced {
    name = var.network_name
  }
}
