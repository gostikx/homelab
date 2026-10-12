locals {
  stack_path  = "/opt/stacks/mosquitto"
  config_path = "${local.stack_path}/config"
  data_path   = "${local.stack_path}/data"
  log_path    = "/var/stacks/mosquitto/log"
}
