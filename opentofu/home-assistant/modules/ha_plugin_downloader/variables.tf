variable "plugin_name" {
  type        = string
  description = "Короткое уникальное имя для ресурсов OpenTofu (например, yandex_plus)"
}

variable "plugin_url" {
  type        = string
  description = "Прямая ссылка на zip-архив репозитория"
}

variable "ssh_host" { type = string }
variable "ssh_user" { type = string }
variable "ssh_password" { type = string }
variable "ha_config_dir" { type = string }
