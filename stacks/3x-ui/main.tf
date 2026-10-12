data "docker_network" "homelab_net" {
  name = var.network_name
}

module "3xui" {
  source = "../../modules/3x-ui"

  ssh_config   = var.ssh_config
  network_name = var.network_name

  depends_on = [data.docker_network.homelab_net]
}
