data "docker_network" "homelab_net" {
  name = var.network_name
}

module "adguard" {
  source = "../../modules/adguard"

  ssh_config     = var.ssh_config
  network_name   = var.network_name
  adguard_config = var.adguard_config
  adguard_admin  = var.adguard_admin

  depends_on = [data.docker_network.homelab_net]
}
