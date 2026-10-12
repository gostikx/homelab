locals {
  data_path     = "/opt/stacks/portainer-ce/data"
  password_hash = bcrypt(var.portainer_admin.password)
}
