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

variable "plugins" {
  description = "Плагины (кастомные интеграции) для home-assistant: subdir — каталог внутри архива, который уходит в config/custom_components/<name>"
  type = list(object({
    name   = string
    url    = string
    subdir = optional(string, "")
  }))
  default = []
}