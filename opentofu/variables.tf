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
    issuer    = string
    dns_names = list(string)
    password  = string
  })
}
