variable "postgres_config" {
  type = object({
    user      = string
    password  = string
  })
}
variable "ssh_config" {
  type = object({
    host        = string
    port        = number
    user        = string
    key         = string
  })
}

terraform {
  backend "local" {}
}

locals {
  ws = terraform.workspace

  enable_portainer      = local.ws == "portainer"
  enable_caddy          = local.ws == "caddy"
  enable_forgejo        = local.ws == "forgejo"
  enable_postgres       = local.ws == "postgresql"
  enable_home_assistant = local.ws == "home_assistant"
}

provider "docker" {
  host = "ssh://${var.ssh_config.user}@${var.ssh_config.host}:${var.ssh_config.port}"
}

resource "docker_network" "homelab_net" {
  name = "homelab-network"
  attachable = true

  lifecycle { ignore_changes = [attachable] }
}

module "portainer" {
  count             = local.enable_portainer ? 1 : 0
  source            = "./portainer"
  ssh_config        = var.ssh_config
  network_name      = docker_network.homelab_net.name
}

module "caddy" {
  count             = local.enable_caddy ? 1 : 0
  source            = "./caddy"
  ssh_config        = var.ssh_config
  network_name      = docker_network.homelab_net.name
}

module "forgejo" {
  count             = local.enable_forgejo ? 1 : 0
  source            = "./forgejo"
  ssh_config        = var.ssh_config
  network_name      = docker_network.homelab_net.name
}

module "postgresql" {
  count             = local.enable_postgres ? 1 : 0
  source            = "./postgresql"
  postgres_config   = var.postgres_config
  network_name      = docker_network.homelab_net.name
}

module "home_assistant" {
  count             = local.enable_home_assistant ? 1 : 0
  source            = "./home-assistant"
  ssh_config        = var.ssh_config
  network_name      = docker_network.homelab_net.name
}
