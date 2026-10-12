variable "network_name" { type = string }
variable "ssh_config" {
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