resource "ssh_resource" "get_docker_group" {
  host        = var.ssh_config.host
  user        = var.ssh_config.user
  private_key = file(var.ssh_config.key)

  commands = [
    "getent group docker | cut -d: -f3"
  ]
}

locals {
  docker_group_id = trimspace(resource.ssh_resource.get_docker_group.result)
}

data "docker_network" "homelab_net" {
  name = var.network_name
}

module "portainer" {
  source = "../../modules/portainer"

  portainer_admin = var.portainer_admin
  docker_group_id = local.docker_group_id
  ssh_config      = var.ssh_config
  network_name    = var.network_name

  depends_on = [data.docker_network.homelab_net]
}
