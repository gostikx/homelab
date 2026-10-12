provider "docker" {
  host = "ssh://${var.ssh_config.user}@${var.ssh_config.host}:${var.ssh_config.port}"
}
