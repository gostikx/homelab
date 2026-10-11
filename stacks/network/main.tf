resource "docker_network" "homelab_net" {
  name       = var.network_name
  attachable = true

  lifecycle { ignore_changes = [attachable] }
}
