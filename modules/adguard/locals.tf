locals {
  work_path = "/opt/stacks/adguard-home/work"
  conf_path = "/opt/stacks/adguard-home/conf"

  adguard_config = templatefile("${path.module}/config/AdGuardHome.yaml.tftpl", {
    http_address    = var.adguard_config.http_address
    doh_insecure    = var.adguard_config.doh_insecure
    username        = var.adguard_config.username
    password_hash   = var.adguard_admin.password_hash
    language        = var.adguard_config.language
    theme           = var.adguard_config.theme
    bind_hosts      = var.adguard_config.bind_hosts
    upstream_dns    = var.adguard_config.upstream_dns
    trusted_proxies = var.adguard_config.trusted_proxies
  })

  adguard_config_hash = nonsensitive(sha256(local.adguard_config))
}
