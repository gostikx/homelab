variable network_name { type = string }
variable "postgres_config" {
  type = object({
    user     = string
    password = string
  })
}
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

terraform {
  backend "local" {}
}

locals {
  ws           = terraform.workspace

  manage_network        = local.ws == "network"
  enable_portainer      = local.ws == "portainer"
  enable_caddy          = local.ws == "caddy"
  enable_forgejo        = local.ws == "forgejo"
  enable_postgres       = local.ws == "postgresql"
  enable_home_assistant = local.ws == "home_assistant"
  enable_mosquitto      = local.ws == "mosquitto"
}

provider "docker" {
  host = "ssh://${var.ssh_config.user}@${var.ssh_config.host}:${var.ssh_config.port}"
}

# Общая docker-сеть создаётся один раз в workspace "network".
# В остальных workspace ресурс имеет count = 0, поэтому они её не трогают.
resource "docker_network" "homelab_net" {
  count      = local.manage_network ? 1 : 0
  name       = var.network_name
  attachable = true

  lifecycle { ignore_changes = [attachable] }
}

module "portainer" {
  count        = local.enable_portainer ? 1 : 0
  source       = "./portainer"
  ssh_config   = var.ssh_config
  network_name = var.network_name
}

module "caddy" {
  count        = local.enable_caddy ? 1 : 0
  source       = "./caddy"
  ssh_config   = var.ssh_config
  network_name = var.network_name
}

module "forgejo" {
  count        = local.enable_forgejo ? 1 : 0
  source       = "./forgejo"
  ssh_config   = var.ssh_config
  network_name = var.network_name
}

module "postgresql" {
  count           = local.enable_postgres ? 1 : 0
  source          = "./postgresql"
  postgres_config = var.postgres_config
  network_name    = var.network_name
}

module "home_assistant" {
  count        = local.enable_home_assistant ? 1 : 0
  source       = "./home-assistant"
  ssh_config   = var.ssh_config
  network_name = var.network_name
}

module "mosquitto" {
  count        = local.enable_mosquitto ? 1 : 0
  source       = "./mosquitto"
  ssh_config   = var.ssh_config
  network_name = var.network_name
}
