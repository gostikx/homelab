locals {
  stack_path  = "/opt/stacks/caddy"
  config_path = "${local.stack_path}/config"
  data_path   = "${local.stack_path}/data"
  certs_path  = "${local.stack_path}/ca"

  log_path = "/var/stacks/caddy/log"
}

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config

  dirs = [
    { path = "${local.stack_path}", mode = "700" },
    { path = "${local.config_path}", mode = "700" },
    { path = "${local.data_path}", mode = "700" },
    { path = "${local.certs_path}", mode = "700" },
    { path = "${local.log_path}", mode = "700" },
    { path = "${local.certs_path}/certs", mode = "700" },
  ]

  copies = [
    { from = "${var.ca_root_path}/root_ca.crt", to = "${local.certs_path}/certs/root_ca.crt" },
    { from = "${var.ca_root_path}/intermediate_ca.crt", to = "${local.certs_path}/certs/intermediate_ca.crt" },
  ]
}

locals {
  caddyfile = templatefile("${path.module}/config/Caddyfile.tftpl", {
    services          = var.services
    acme_url          = var.acme.url
    acme_ca_root_path = var.acme.ca_root_path
    mqtt              = var.mqtt
  })
  caddyfile_hash = sha256(local.caddyfile)
}

module "upload_caddy_config" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  content     = local.caddyfile
  remote_path = "${local.config_path}/Caddyfile"

  triggers_replace = {
    caddyfile = local.caddyfile_hash
  }

  commands = [
    "find ${local.config_path} -type d -exec chmod 700 {} \\;",
    "find ${local.config_path} -type f -exec chmod 600 {} \\;"
  ]

  depends_on = [module.setup_dirs]
}

resource "docker_image" "caddy" {
  name = "caddy:2.11.4-alpine"
}

locals {
  caddy_image = "caddy-l4:2.11.4"
}

module "upload_caddy_dockerfile" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  local_path  = "${path.module}/Dockerfile"
  remote_path = "/opt/stacks/caddy/Dockerfile"

  triggers_replace = { dockerfile = filesha256("${path.module}/Dockerfile") }

  depends_on = [module.setup_dirs]
}

resource "terraform_data" "build_caddy_image" {
  depends_on = [module.upload_caddy_dockerfile]

  triggers_replace = {
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

  capabilities {
    drop = ["ALL"]
  }

  security_opts = ["no-new-privileges:true"]

  command = ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--watch"]

  healthcheck {
    test         = ["CMD-SHELL", "curl -fsS -o /dev/null http://127.0.0.1:2019/config/ || exit 1"]
    start_period = "5s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 3
  }

  wait         = true
  wait_timeout = 30

  depends_on = [
    terraform_data.build_caddy_image,
    module.upload_caddy_config,
  ]

  volumes {
    host_path      = local.config_path
    container_path = "/etc/caddy"
    read_only      = true
  }

  volumes {
    host_path      = "${local.certs_path}/certs"
    container_path = "/etc/ca"
    read_only      = true
  }

  volumes {
    host_path      = local.data_path
    container_path = "/data/caddy"
  }

  volumes {
    host_path      = local.log_path
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
    aliases = var.host_aliases
  }
}
