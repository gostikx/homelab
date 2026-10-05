variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

# variable "ssh_host" {
#   type    = string
#   default = "111.222.33.44"
# }

# variable "ssh_user" {
#   type    = string
#   default = "root"
# }

# variable "ssh_password" {
#   type      = string
#   sensitive = true
# }

# variable "ha_config_dir" {
#   type    = string
#   default = "/config"
# }

# # Карта ваших плагинов. Ключ — короткое имя, значение — URL архива.
# variable "plugins" {
#   type = map(string)
#   default = {
#     yandex_plus = "https://github.com"
#     xiaomi_raw  = "https://github.com"
#     # Сюда можно дописывать любые другие плагины:
#     # my_next_plugin = "https://github.com"
#   }
# }
