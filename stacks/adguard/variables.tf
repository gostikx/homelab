variable "network_name" {
  description = "Имя общей docker-сети homelab (стек проверяет её через data.docker_network)"
  type        = string
}

variable "ssh_config" {
  description = "Доступ к docker-хосту по SSH: host, port, user и key (путь к приватному ключу)"
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

variable "adguard_config" {
  description = "Настройки AdGuard Home, которые рендерятся в AdGuardHome.yaml: слушающий адрес, DoH без проверки сертификата, логин, язык, тема, bind-хосты, upstream-DNS и доверенные прокси Caddy"
  type = object({
    http_address    = optional(string, "0.0.0.0:3000")
    doh_insecure    = optional(bool, true)
    username        = optional(string, "admin")
    language        = optional(string, "ru")
    theme           = optional(string, "dark")
    bind_hosts      = optional(list(string), ["0.0.0.0"])
    upstream_dns    = optional(list(string), ["https://dns10.quad9.net/dns-query"])
    trusted_proxies = optional(list(string), ["127.0.0.0/8", "::1/128"])
  })

  default = {}
}

variable "adguard_admin" {
  description = "Пароль администратора AdGuard Home в виде bcrypt-хеша: конфиг рендерится в файл, поэтому пароль берётся уже захэшированным"
  type = object({
    password_hash = string
  })

  sensitive = true
}
