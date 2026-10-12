data "docker_network" "homelab_net" {
  name = var.network_name
}

module "smallstep_ca" {
  source = "../../modules/small-step-ca"

  ssh_config       = var.ssh_config
  network_name     = var.network_name
  smallstep_config = var.smallstep_config

  depends_on = [data.docker_network.homelab_net]
}

module "caddy" {
  source = "../../modules/caddy"

  ssh_config   = var.ssh_config
  network_name = var.network_name
  acme         = var.acme
  services     = var.services

  host_aliases = [for svc in var.services : svc.dns]

  ca_root_path = module.smallstep_ca.ca_root_path

  depends_on = [
    data.docker_network.homelab_net,
    module.smallstep_ca,
  ]
}
