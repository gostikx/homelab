variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

variable "adguard_config" {
  type = object({
    http_address    = optional(string, "0.0.0.0:3000")
    doh_insecure    = optional(bool, true)
    username        = optional(string, "admin")
    language        = optional(string, "ru")
    theme           = optional(string, "dark")
    bind_hosts      = optional(list(string), ["0.0.0.0"])
    upstream_dns    = optional(list(string), ["https://dns10.quad9.net/dns-query"])
    trusted_proxies = optional(list(string), ["127.0.0.0/8", "::1/128"])
  })

  default = {}
}

variable "adguard_admin" {
  type = object({
    password_hash = string
  })

  sensitive = true
}
