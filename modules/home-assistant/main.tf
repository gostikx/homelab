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

module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = concat(
    [
      { path = local.data_path, mode = "700" },
      { path = local.config_path, mode = "700" },
      { path = local.custom_components_path, mode = "700" },
      { path = "${local.config_path}/.storage", mode = "700" },
    ],
    [for name in keys(local.plugins) : { path = "${local.custom_components_path}/${name}", mode = "700" }],
  )
}

module "upload_config" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  content     = local.configuration
  remote_path = "${local.config_path}/configuration.yaml"

  commands = [
    "chmod 600 ${local.config_path}/configuration.yaml",
  ]

  triggers_replace = { config = local.configuration_hash }

  depends_on = [module.setup_dirs]
}

module "upload_http_store" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  content     = local.http_storage
  remote_path = "${local.config_path}/.storage/http"

  commands = [
    "chmod 600 ${local.config_path}/.storage/http",
  ]

  triggers_replace = { config = local.http_storage_hash }

  depends_on = [module.setup_dirs]
}

resource "terraform_data" "upload_home_assistant_config" {
  triggers_replace = {
    config       = local.configuration_hash
    http_storage = local.http_storage_hash
    plugins      = sha256(join(",", [for name in sort(keys(local.plugins)) : module.download_plugins[name].spec_hash]))
  }
}

module "download_plugins" {
  source   = "../../plugins/downloader"
  for_each = local.plugins

  plugin = each.value
}

module "upload_plugins" {
  source   = "../../plugins/upload_files"
  for_each = local.plugins

  ssh_config = var.ssh_config

  local_path  = "${module.download_plugins[each.key].plugin_path}/"
  remote_path = "${local.custom_components_path}/${each.key}"

  commands = [
    "test -f ${local.custom_components_path}/${each.key}/manifest.json || { echo 'ОШИБКА: ${local.custom_components_path}/${each.key}/manifest.json не найден — каталог залился не туда, проверьте plugin.subdir у ${each.key} (заливали ${module.download_plugins[each.key].plugin_path})' >&2; exit 1; }",
    "find ${local.custom_components_path}/${each.key} -user \"$(id -u)\" -type d -exec chmod 700 {} \\;",
    "find ${local.custom_components_path}/${each.key} -user \"$(id -u)\" -type f -exec chmod 600 {} \\;",
  ]

  triggers_replace = { spec = module.download_plugins[each.key].spec_hash }

  depends_on = [module.download_plugins, module.setup_dirs]
}

resource "docker_image" "home_assistant" {
  name         = "ghcr.io/home-assistant/home-assistant:stable"
  keep_locally = true
}

resource "docker_container" "home_assistant" {
  depends_on = [module.upload_config, module.upload_http_store, module.upload_plugins, module.setup_dirs]

  name    = "home-assistant"
  image   = docker_image.home_assistant.image_id
  restart = "always"

  user = "1001:1001"

  env = [
    "TZ=Europe/Moscow"
  ]

  volumes {
    host_path      = local.config_path
    container_path = "/config"
  }

  healthcheck {
    test         = ["CMD-SHELL", "curl -fsS -o /dev/null http://127.0.0.1:8123/manifest.json || exit 1"]
    start_period = "1m0s"
    interval     = "30s"
    timeout      = "10s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 180

  networks_advanced {
    name = var.network_name
  }

  lifecycle {
    replace_triggered_by = [terraform_data.upload_home_assistant_config]
  }
}
