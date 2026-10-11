variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

variable "smallstep_config" {
  type = object({
    issuer    = string
    dns_names = list(string)
    password  = string
  })

  sensitive = true

  validation {
    condition     = contains(nonsensitive(var.smallstep_config.dns_names), "acme.homelab.dev")
    error_message = "Добавьте acme.homelab.dev в smallstep_config.dns_names"
  }
}