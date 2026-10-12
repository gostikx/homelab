variable "network_name" {
  description = "Имя общей docker-сети homelab, в которой запускается контейнер (стек проверяет её через data.docker_network)"
  type        = string
}

variable "docker_group_id" {
  description = "GID группы docker на хосте (стек читает его через ssh_resource): нужен контейнеру в group_add, чтобы работать с /var/run/docker.sock"
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

variable "portainer_admin" {
  description = "Учётные данные администратора Portainer: password — пароль, из которого считается bcrypt-хеш для флага --admin-password"
  type = object({
    password = string
  })

  sensitive = true
}