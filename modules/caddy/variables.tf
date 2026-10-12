variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}
variable "ca_root_path" {
  type        = string
  description = "Путь к root сертификату"
  default     = ""
}
variable "host_aliases" {
  description = <<-EOT
    Сетевые алиасы контейнера в docker-сети = DNS-имена сайтов, которые обслуживает Caddy.
    Пустой список → без алиасов. Имя mqtt-сайта (local.mqtt_dns) модуль добавляет сам.
  EOT

  type    = list(string)
  default = []
}
variable "acme" {
  type = object({
    url          = string
    ca_root_path = string
  })
}
variable "services" {
  description = <<-EOT
    Сервисы, которые Caddy публикует наружу (рендерятся в Caddyfile.tftpl циклом).
    dns       — имя сайта
    container — адрес бэкенда внутри docker-сети, подставляется в reverse_proxy
    name      — имя для файла лога: /var/log/caddy/<name>_access.log
  EOT

  type = list(object({
    name      = string
    dns       = string
    container = string
  }))
}
variable "mqtt" {
  type = object({
    external_port = number
    dns           = string
    container     = string
  })
}