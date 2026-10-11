output "network_name" {
  description = "Имя общей docker-сети homelab"
  value       = docker_network.homelab_net.name
}
