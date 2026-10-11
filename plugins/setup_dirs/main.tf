locals {
  foreign_dir_guard = [
    for dir in var.dirs : "if [ -d ${dir.path} ] && [ \"$(stat -c %u ${dir.path})\" != \"$(id -u)\" ]; then rmdir ${dir.path} 2>/dev/null || { echo 'ОШИБКА: ${dir.path} принадлежит другому uid и не пуст — удалите его вручную (rm -rf) и повторите apply' >&2; exit 1; }; fi"
    if dir.uid == null
  ]

  dir_commands = flatten([
    for dir in var.dirs : concat(
      ["mkdir -p ${dir.path}"],
      dir.mode != null ? ["chmod ${dir.mode} ${dir.path}"] : [],
      dir.uid != null ? [
        "docker run --rm -v ${dir.path}:/target ${var.chown_image} chown${dir.recursive ? " -R" : ""} ${dir.uid}:${dir.gid} /target"
      ] : [],
    )
  ])

  copy_commands = [
    for copy in var.copies : "install -m ${copy.mode} ${copy.from} ${copy.to}"
  ]

  commands = concat(local.foreign_dir_guard, local.dir_commands, local.copy_commands)

  spec = sha256(jsonencode({
    dirs        = var.dirs
    copies      = var.copies
    chown_image = var.chown_image
  }))
}

resource "terraform_data" "setup" {
  triggers_replace = {
    spec = local.spec
  }

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = local.commands
  }

  lifecycle {
    precondition {
      condition     = length(local.commands) > 0
      error_message = "Нужен хотя бы один каталог (dirs) или копия (copies)."
    }
  }
}
