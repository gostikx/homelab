variable "network_name" { type = string }
variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}
variable "ca_root_path" {
  type        = string
  description = "Путь к root сертификату"
  default     = ""
}