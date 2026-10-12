variable "network_name" {
  description = "Имя общей docker-сети homelab, в которой запускается контейнер (стек проверяет её через data.docker_network)"
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

variable "smallstep_config" {
  description = "Первичная инициализация step-ca: issuer — имя CA, dns_names — SAN-ы сертификата (обязателен acme.homelab.dev), password — пароль admin-провижионера"
  type = object({
    issuer    = string
    dns_names = list(string)
    password  = string
  })

  sensitive = true

  validation {
    condition     = contains(nonsensitive(var.smallstep_config.dns_names), "acme.homelab.dev")
    error_message = "Добавьте acme.homelab.dev в smallstep_config.dns_names"
  }
}