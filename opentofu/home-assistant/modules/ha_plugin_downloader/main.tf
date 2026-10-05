# 1. Скачиваем архив во временную локальную память
data "http" "download" {
  url             = var.plugin_url
  request_headers = { Accept = "application/octet-stream" }
}

# 2. Сохраняем zip на диск (под уникальным именем для каждого плагина)
resource "local_sensitive_file" "zip" {
  content_base64 = data.http.download.response_body_base64
  filename       = "${path.root}/.tmp_${var.plugin_name}.zip"
}

# 3. Распаковываем zip локально в уникальную папку плагина
data "archive_file" "unzip" {
  type        = "zip"
  source_file = resource.local_sensitive_file.zip.filename
  output_path = "${path.root}/.tmp_extracted_${var.plugin_name}/"
  depends_on  = [resource.local_sensitive_file.zip]
}

# 4. Отправляем распакованную папку на сервер
resource "terraform_data" "deploy" {
  triggers_replace = [data.http.download.response_body_base64]

  connection {
    type     = "ssh"
    host     = var.ssh_host
    user     = var.ssh_user
    password = var.ssh_password
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${var.ha_config_dir}/custom_components/"]
  }

  # Копируем содержимое уникальной временной папки плагина
  provisioner "file" {
    source      = data.archive_file.unzip.output_path
    destination = "${var.ha_config_dir}/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R 755 ${var.ha_config_dir}/custom_components/"
    ]
  }

  depends_on = [data.archive_file.unzip]
}

# 5. Очищаем локальный мусор на ПК именно для этого плагина
resource "terraform_data" "cleanup" {
  triggers_replace = [resource.terraform_data.deploy.id]

  provisioner "local-exec" {
    command = "rm -f ${resource.local_sensitive_file.zip.filename} && rm -rf ${data.archive_file.unzip.output_path}"
  }

  depends_on = [resource.terraform_data.deploy]
}
