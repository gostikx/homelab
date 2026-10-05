variable "network_name" { type = string }
variable "postgres_config" {
  type = object({
    user     = string
    password = string
  })
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
}
variable "smallstep_config" {
  type = object({
    name              = string
    dns_names         = list(string)
    password          = string
    provisioner_name  = optional(string, "admin")
    address           = optional(string, ":9000")
    acme              = optional(bool, true)
    ssh               = optional(bool, false)
    remote_management = optional(bool, false)
    published_port    = optional(number, 0)
    # Веб-интерфейс управления CA (модуль small-step-ca)
    web = optional(object({
      name           = optional(string, "smallstep-web")
      image          = optional(string, "nevidanniu/step-ca-web:latest")
      session_secret = optional(string, "")
      published_port = optional(number, 0)
    }), {})
  })
}
