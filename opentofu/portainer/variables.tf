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

  # validation {
  #   condition     = contains(var.portainer_admin.password, "")
  #   error_message = "Добавьте acme.homelab.dev в smallstep_config.dns_names (см. local.ca_alias в main.tf)."
  # }
}