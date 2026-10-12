locals {
  data_path              = "/opt/stacks/home-assistant"
  config_path            = "${local.data_path}/config"
  custom_components_path = "${local.config_path}/custom_components"

  plugins = { for plugin in var.plugins : plugin.name => plugin }

  configuration = templatefile("${path.module}/config/configuration.yaml.tftpl", {})
  http_storage = templatefile("${path.module}/config/http.storage.json.tftpl", {
    trusted_proxies_json = jsonencode(var.trusted_proxies)
  })

  configuration_hash = sha256(local.configuration)
  http_storage_hash  = sha256(local.http_storage)
}
