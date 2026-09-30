variable "shared_state_dir" { type = string }
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

provider "docker" {
  host = "ssh://${ssh_config.user}@${ssh_config.host}:${ssh_config.port}"
}

resource "docker_network" "homelab_net" {
  name = "homelab-network"
}

module "portainer" {
  source            = "./portainer"
  ssh_config        = var.ssh_config
  shared_state_dir  = var.shared_state_dir
  network_name      = docker_network.homelab_net.name
}

module "caddy" {
  source            = "./caddy"
  ssh_config        = var.ssh_config
  shared_state_dir  = var.shared_state_dir
  network_name      = docker_network.homelab_net.name
}

module "forgejo" {
  source            = "./forgejo"
  ssh_config        = var.ssh_config
  shared_state_dir  = var.shared_state_dir
  network_name      = docker_network.homelab_net.name
}

module "postgresql" {
  source            = "./postgresql"
  postgres_config   = var.postgres_config
  shared_state_dir  = var.shared_state_dir
  network_name      = docker_network.homelab_net.name
}
