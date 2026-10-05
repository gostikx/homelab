locals {
  host_network_aliases = [
    "caddy.homelab.dev",
    "portainer.homelab.dev",
    "forgejo.homelab.dev",
    "adguard.homelab.dev",
  ]
}
resource "null_resource" "setup_server_dirs" {
  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/stacks/caddy/config",
      "mkdir -p /opt/stacks/caddy/data",
      "mkdir -p /opt/stacks/caddy/ca/certs",
      "install -m 600 ${var.ca_root_path}/root_ca.crt /opt/stacks/caddy/ca/certs/root_ca.crt",
      "install -m 600 ${var.ca_root_path}/intermediate_ca.crt /opt/stacks/caddy/ca/certs/intermediate_ca.crt",
      "chmod 700 /opt/stacks/caddy/config /opt/stacks/caddy/data /opt/stacks/caddy/ca",

      "mkdir -p /var/stacks/caddy/log",
    ]
  }
}

resource "null_resource" "upload_caddy_config" {
  depends_on = [null_resource.setup_server_dirs]

  triggers = {
    caddyfile = filesha256("${path.module}/config/Caddyfile")
  }

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/config/"
    destination = "/opt/stacks/caddy/config"
  }

  provisioner "remote-exec" {
    inline = [
      "find /opt/stacks/caddy/config -type d -exec chmod 700 {} \\;",
      "find /opt/stacks/caddy/config -type f -exec chmod 600 {} \\;"
    ]
  }
}

resource "docker_image" "caddy" {
  name = "caddy:2.11.4-alpine"
}

locals {
  caddy_image = "caddy-l4:2.11.4"
}

resource "null_resource" "upload_caddy_dockerfile" {
  depends_on = [null_resource.setup_server_dirs]

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = "${path.module}/Dockerfile"
    destination = "/opt/stacks/caddy/Dockerfile"
  }
}

resource "null_resource" "build_caddy_image" {
  depends_on = [null_resource.upload_caddy_dockerfile]

  triggers = {
    dockerfile = filesha256("${path.module}/Dockerfile")
  }

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "docker build -t ${local.caddy_image} /opt/stacks/caddy"
    ]
  }
}

resource "docker_container" "caddy" {
  name    = "caddy"
  image   = local.caddy_image
  restart = "always"

  user = "1001:1001"

  command = ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--watch"]

  healthcheck {
    test         = ["CMD", "curl", "-fsS", "-o", "/dev/null", "http://127.0.0.1:2019/config/"]
    interval     = "10s"
    timeout      = "5s"
    start_period = "5s"
    retries      = 3
  }

  wait         = true
  wait_timeout = 30

  depends_on = [
    null_resource.build_caddy_image,
    null_resource.upload_caddy_config,
  ]

  volumes {
    host_path      = "/opt/stacks/caddy/config"
    container_path = "/etc/caddy"
    read_only      = true
  }

  volumes {
    host_path      = "/opt/stacks/caddy/ca/certs"
    container_path = "/etc/ca"
    read_only      = true
  }

  volumes {
    host_path      = "/opt/stacks/caddy/data"
    container_path = "/data/caddy"
  }

  volumes {
    host_path      = "/var/stacks/caddy/log"
    container_path = "/var/log/caddy"
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 8883
    external = 8883
  }

  networks_advanced {
    name    = var.network_name
    aliases = local.host_network_aliases
  }
}
