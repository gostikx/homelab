data "docker_network" "homelab_net" {
  name = var.network_name
}

module "opendesign" {
  source = "../../modules/opendesign"

  ssh_config   = var.ssh_config
  network_name = var.network_name
  od_api_token = var.od_api_token

  depends_on = [data.docker_network.homelab_net]
}
