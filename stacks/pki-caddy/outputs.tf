output "ca_root_path" {
  description = "Абсолютный путь к каталогу с сертификатами CA на хост-машине"
  value       = module.smallstep_ca.ca_root_path
}

output "network_name" {
  description = "Имя docker-сети, в которой живут CA и Caddy"
  value       = var.network_name
}
