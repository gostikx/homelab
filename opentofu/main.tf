terraform {
  backend "local" {}
}

locals {
  ws = terraform.workspace

  manage_network        = local.ws == "network"
  enable_portainer      = local.ws == "portainer"
  enable_caddy          = local.ws == "caddy"
  enable_forgejo        = local.ws == "forgejo"
  enable_postgres       = local.ws == "postgresql"
  enable_home_assistant = local.ws == "home_assistant"
  enable_mosquitto      = local.ws == "mosquitto"
  enable_smallstep_ca   = local.ws == "smallstep-ca"
  enable_adguard        = local.ws == "adguard-home"
}

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

provider "docker" {
  host = "ssh://${var.ssh_config.user}@${var.ssh_config.host}:${var.ssh_config.port}"
}

resource "docker_network" "homelab_net" {
  count      = local.manage_network ? 1 : 0
  name       = var.network_name
  attachable = true

  lifecycle { ignore_changes = [attachable] }
}

data "docker_network" "homelab_net" {
  count = local.manage_network ? 0 : 1
  name  = var.network_name
}

module "smallstep_ca" {
  count            = local.enable_smallstep_ca ? 1 : 0
  source           = "./small-step-ca"
  smallstep_config = var.smallstep_config
  ssh_config       = var.ssh_config
  network_name     = var.network_name
  depends_on       = [data.docker_network.homelab_net]
}

module "caddy" {
  count        = local.enable_caddy ? 1 : 0
  source       = "./caddy"
  ssh_config   = var.ssh_config
  network_name = var.network_name
  # ca_root_path = module.smallstep_ca[0].ca_root_path
  ca_root_path = "/opt/stacks/small-step-ca/certs"
  depends_on = [
    module.smallstep_ca,
    data.docker_network.homelab_net,
  ]
}

module "portainer" {
  count           = local.enable_portainer ? 1 : 0
  source          = "./portainer"
  portainer_admin = var.portainer_admin
  docker_group_id = local.docker_group_id
  ssh_config      = var.ssh_config
  network_name    = var.network_name
  depends_on      = [data.docker_network.homelab_net]
}

module "forgejo" {
  count        = local.enable_forgejo ? 1 : 0
  source       = "./forgejo"
  ssh_config   = var.ssh_config
  network_name = var.network_name
  depends_on   = [data.docker_network.homelab_net]
}

module "postgresql" {
  count           = local.enable_postgres ? 1 : 0
  source          = "./postgresql"
  ssh_config      = var.ssh_config
  postgres_config = var.postgres_config
  network_name    = var.network_name
  depends_on      = [data.docker_network.homelab_net]
}

module "home_assistant" {
  count        = local.enable_home_assistant ? 1 : 0
  source       = "./home-assistant"
  ssh_config   = var.ssh_config
  network_name = var.network_name
  depends_on   = [data.docker_network.homelab_net]
}

module "mosquitto" {
  count        = local.enable_mosquitto ? 1 : 0
  source       = "./mosquitto"
  ssh_config   = var.ssh_config
  network_name = var.network_name
  depends_on   = [data.docker_network.homelab_net]
}

module "adguard" {
  count        = local.enable_adguard ? 1 : 0
  source       = "./adguard"
  ssh_config   = var.ssh_config
  network_name = var.network_name
  depends_on   = [data.docker_network.homelab_net]
}