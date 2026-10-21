locals {
  stack_path = "/opt/stacks/open-design"
  data_path  = "${local.stack_path}/data"

  opendesign_image = "opendesign:0.24.1-opencode"
}
