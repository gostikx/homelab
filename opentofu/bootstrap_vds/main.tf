variable "NEW_SSH_PORT" { default = "2222" }
variable "NEW_ADMIN" { default = "devops" }
variable "PUBLIC_KEY_PATH" { default = "~/.ssh/id_ed25519.pub" }

resource "null_resource" "vps_bootstrap" {
  connection {
    type        = "ssh"
    host        = "[YOUR_VPS_IP]"
    port        = 22
    user        = "root"
    password    = "[YOUR_VPS_PASSWORD]"
  }

  provisioner "remote-exec" {
    inline = [
      "export NEW_USER='${var.NEW_ADMIN}'",
      "export NEW_SSH_PORT='${var.NEW_SSH_PORT}'",
      "export PUB_KEY='${file(var.PUBLIC_KEY_PATH)}'"
    ]
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/01-user-auth.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/03-firewall-fail2ban.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/02-ssh-hardening.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/04-auto-updates.sh"
  }
}
