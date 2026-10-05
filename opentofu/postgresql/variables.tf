variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}
variable "postgres_config" {
  type = object({
    user     = string
    password = string
  })
}