data "docker_network" "homelab_net" {
  name = var.network_name
}

module "postgresql" {
  source = "../../modules/postgresql"

  ssh_config      = var.ssh_config
  postgres_config = var.postgres_config
  network_name    = var.network_name

  depends_on = [data.docker_network.homelab_net]
}

module "forgejo" {
  source = "../../modules/forgejo"

  ssh_config   = var.ssh_config
  network_name = var.network_name

  depends_on = [data.docker_network.homelab_net]
}
