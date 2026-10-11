locals {
  commands = length(var.commands) > 0 ? var.commands : ["true"]
}

resource "terraform_data" "upload_path" {
  count = var.content == null ? 1 : 0

  triggers_replace = var.triggers_replace

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    port        = var.ssh_config.port
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    source      = var.local_path
    destination = var.remote_path
  }

  provisioner "remote-exec" {
    inline = local.commands
  }

  lifecycle {
    precondition {
      condition     = var.local_path != null
      error_message = "Задайте ровно одно: local_path (файл/каталог из репозитория) или content (рендер из конфига)."
    }
  }
}

resource "terraform_data" "upload_content" {
  count = var.content != null ? 1 : 0

  triggers_replace = var.triggers_replace

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    port        = var.ssh_config.port
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "file" {
    content     = var.content
    destination = var.remote_path
  }

  provisioner "remote-exec" {
    inline = local.commands
  }

  lifecycle {
    precondition {
      condition     = var.local_path == null
      error_message = "Задайте ровно одно: local_path (файл/каталог из репозитория) или content (рендер из конфига), но не оба."
    }
  }
}
