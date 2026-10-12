data "docker_network" "homelab_net" {
  name = var.network_name
}

module "mosquitto" {
  source = "../../modules/mosquitto"

  ssh_config   = var.ssh_config
  network_name = var.network_name

  depends_on = [data.docker_network.homelab_net]
}

module "home_assistant" {
  source = "../../modules/home-assistant"

  ssh_config   = var.ssh_config
  network_name = var.network_name
  plugins      = var.plugins

  trusted_proxies = [for ipam in data.docker_network.homelab_net.ipam_config : ipam.subnet]

  depends_on = [data.docker_network.homelab_net]
}
