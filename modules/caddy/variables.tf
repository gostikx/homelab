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

variable "ca_root_path" {
  type        = string
  description = "Путь к root сертификату"
  default     = ""
}

variable "host_aliases" {
  description = <<-EOT
    Сетевые алиасы контейнера в docker-сети = DNS-имена сайтов, которые обслуживает Caddy
    (нужны, чтобы CA при выпуске по http-01 резолвила запрашиваемое имя). Пустой список → без алиасов.
    Имя mqtt-сайта (mqtt.dns) стек добавляет сам и только при use_tls = true.
  EOT

  type    = list(string)
  default = []
}

variable "acme" {
  description = "Параметры ACME-клиента Caddy: url — адрес ACME-директории step-ca, ca_root_path — каталог с корневыми сертификатами CA на docker-хосте (копируются в /etc/ca контейнера)"
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
  description = <<-EOT
    Публикация MQTT-брокера наружу через Caddy (layer4, только TLS).

    null (не задано) или use_tls = false → caddy MQTT не публикует вообще: ни блока layer4, ни
    проброса порта, ни сайта-заглушки. Plain-доступ к брокеру по IP без SSL обеспечивает сам
    mosquitto (публикует свой 1883, см. modules/mosquitto).
    use_tls       — true: layer4 терминирует TLS и матчит SNI = dns (клиент ходит по dns-имени и
                    обязательно с TLS, сертификат выпускается через ACME);
    external_port — порт, который слушает layer4 внутри контейнера caddy и публикуется наружу
                    (используется только при use_tls = true);
    dns           — имя сайта для SNI и для выпуска сертификата (только при use_tls = true);
    container     — адрес брокера в docker-сети (host:port) для proxy.
  EOT

  type = object({
    use_tls       = bool
    external_port = number
    dns           = string
    container     = string
  })

  default = null
}
