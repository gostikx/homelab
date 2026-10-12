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

variable "smallstep_config" {
  description = "Первичная инициализация step-ca: issuer — имя CA, dns_names — SAN-ы сертификата (обязателен acme.homelab.dev), password — пароль admin-провижионера"
  type = object({
    issuer    = string
    dns_names = list(string)
    password  = string
  })

  sensitive = true
}

variable "acme" {
  description = "Параметры ACME-клиента Caddy: url — адрес ACME-директории step-ca, ca_root_path — каталог с корневыми сертификатами CA на docker-хосте"
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
    Публикация MQTT-брокера наружу через Caddy (layer4). См. modules/caddy/variables.tf.

    null (не задано) или use_tls = false → caddy MQTT не публикует вообще (plain-доступ по IP
    отдаёт сам mosquitto своим портом 1883).
    use_tls       — true: layer4 терминирует TLS и матчит SNI = dns (клиент ходит по dns-имени
                    и обязательно с TLS, сертификат выпускается через ACME);
    external_port — порт, который слушает layer4 внутри контейнера caddy и публикуется наружу
                    (используется только при use_tls = true);
    dns           — имя сайта для SNI и выпуска сертификата (только при use_tls = true);
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
