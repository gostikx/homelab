terraform {
  backend "local" {}
}

resource "null_resource" "remote_commands" {

  connection {
    type        = "ssh"
    host        = var.ssh_host
    user        = var.ssh_user
    password    = var.ssh_password
    timeout     = "60s"
  }

  provisioner "remote-exec" {
    inline = [
      "whoami",
    ]
  }
}