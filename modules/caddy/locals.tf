locals {
  stack_path  = "/opt/stacks/caddy"
  config_path = "${local.stack_path}/config"
  data_path   = "${local.stack_path}/data"
  certs_path  = "${local.stack_path}/ca"

  log_path = "/var/stacks/caddy/log"

  caddyfile = templatefile("${path.module}/config/Caddyfile.tftpl", {
    services          = var.services
    acme_url          = var.acme.url
    acme_ca_root_path = var.acme.ca_root_path
    mqtt              = var.mqtt
  })

  caddyfile_hash = sha256(local.caddyfile)

  # Свой образ: в официальном caddy нет модуля layer4 (MQTT-прокси), см. Dockerfile модуля
  caddy_image = "caddy-l4:2.11.4"
}
