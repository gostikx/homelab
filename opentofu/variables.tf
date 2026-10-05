variable "network_name" { type = string }
variable "postgres_config" {
  type = object({
    user     = string
    password = string
  })

  # sensitive скрывает значение целиком (отдельного флага для поля в OpenTofu нет),
  # но секрет здесь только password: user читается в модуле через nonsensitive().
  sensitive = true
}
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}
variable "portainer_admin" {
  type = object({
    password = string
  })

  # В объекте лежит только пароль администратора, поэтому скрывается весь объект.
  sensitive = true
}
variable "smallstep_config" {
  type = object({
    issuer    = string
    dns_names = list(string)
    password  = string
  })

  # Секрет — только password; issuer/dns_names в модуле читаются через nonsensitive().
  sensitive = true
}
