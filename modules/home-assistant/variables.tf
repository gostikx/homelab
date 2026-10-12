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

variable "plugins" {
  description = "Плагины (кастомные интеграции), которые надо скачать и положить в config/custom_components/<name>: subdir — каталог внутри архива (у интеграций HA это custom_components/<домен>)"
  type = list(object({
    name   = string
    url    = string
    subdir = optional(string, "")
  }))
  default = []

  validation {
    condition     = length(distinct([for plugin in var.plugins : plugin.name])) == length(var.plugins)
    error_message = "Имена плагинов должны быть уникальны: имя — ключ for_each и имя каталога в custom_components."
  }
}

variable "trusted_proxies" {
  description = "IP/подсети reverse proxy (обычно docker-сеть, где живёт Caddy). Пишутся в http.trusted_proxies конфига HA (.storage/http): без них HA отвергает запросы из-под прокси с 400 Bad Request"
  type        = list(string)

  validation {
    condition     = length(var.trusted_proxies) > 0
    error_message = "trusted_proxies пуст: HA ответит 400 на запросы из-под reverse proxy. Соберите подсети из data.docker_network.homelab_net.ipam_config в стеке."
  }
}
