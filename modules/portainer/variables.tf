variable "network_name" { type = string }
variable "docker_group_id" { type = string }
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

  sensitive = true
}