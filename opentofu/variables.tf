variable "ssh_host" {
  type        = string
  description = "IP-адрес или домен удаленного сервера"
}

variable "ssh_port" {
  type        = number
  description = "Порт для подключения по SSH"
  default     = 22
}

variable "ssh_user" {
  type        = string
  description = "Имя пользователя для подключения по SSH"
  default     = "root"
}

variable "ssh_password" {
  type        = string
  sensitive   = true
  description = "Пароль пользователя для подключения по SSH"
}

variable "ssh_key_path" {
  type        = string
  description = "Путь к приватному SSH-ключу"
  default     = "~/.ssh/id_rsa"
}
