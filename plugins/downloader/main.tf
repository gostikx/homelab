locals {
  tmp_dir      = "${path.root}/.tmp"
  archive_path = "${local.tmp_dir}/${var.plugin.name}.archive"
  extract_path = "${local.tmp_dir}/extracted/${var.plugin.name}"

  stage_path = "${local.extract_path}.stage"

  plugin_path = var.plugin.subdir == "" ? local.extract_path : "${local.extract_path}/${var.plugin.subdir}"
}

data "http" "download" {
  url = var.plugin.url

  request_headers = {
    Accept = "application/octet-stream"
  }

  retry {
    attempts     = 3
    min_delay_ms = 500
    max_delay_ms = 5000
  }
}

resource "local_sensitive_file" "archive" {
  content_base64  = data.http.download.response_body_base64
  filename        = local.archive_path
  file_permission = "0600"
}

resource "terraform_data" "unpack" {
  triggers_replace = {
    archive_sha256 = local_sensitive_file.archive.content_sha256
    extract_path   = local.extract_path
    subdir         = var.plugin.subdir
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -eu

      rm -rf "${local.extract_path}" "${local.stage_path}"
      mkdir -p "${local.stage_path}"

      # Расширения у скачанного файла нет (<имя>.archive), тип определяем по содержимому:
      # zip проверяет сам unzip, tar — сам tar, всё третье (HTML вместо архива) — явная ошибка
      if unzip -tqq "${local.archive_path}" > /dev/null 2>&1; then
        unzip -qq "${local.archive_path}" -d "${local.stage_path}"
      elif tar -tf "${local.archive_path}" > /dev/null 2>&1; then
        tar -xf "${local.archive_path}" -C "${local.stage_path}"
      else
        echo "ОШИБКА: ${local.archive_path} не распознан ни как zip, ни как tar — проверьте plugin.url: ссылка должна вести на файл архива, а не на HTML-страницу" >&2
        exit 1
      fi

      # Архивы GitHub (archive/refs/heads/<branch>.zip, archive/refs/tags/<tag>.tar.gz) кладут всё
      # в единственный каталог <repo>-<ref>/, имя которого зависит от ветки/хеша коммита. Снимаем
      # этот «обёрточный» уровень, иначе plugin.subdir пришлось бы писать вместе с ним.
      if [ "$(find "${local.stage_path}" -mindepth 1 -maxdepth 1 | wc -l)" = "1" ]; then
        only="$(find "${local.stage_path}" -mindepth 1 -maxdepth 1)"
        if [ -d "$only" ]; then
          mv "$only" "${local.extract_path}"
        else
          mv "${local.stage_path}" "${local.extract_path}"
        fi
      else
        mv "${local.stage_path}" "${local.extract_path}"
      fi
      rm -rf "${local.stage_path}"

      if [ ! -d "${local.plugin_path}" ]; then
        echo "ОШИБКА: в архиве ${var.plugin.name} нет каталога plugin_path=${local.plugin_path} — проверьте plugin.subdir. Содержимое распакованного архива:" >&2
        find "${local.extract_path}" -maxdepth 2 >&2
        exit 1
      fi

      echo "✔ ${var.plugin.name}: распаковано в ${local.extract_path}, каталог для заливки — ${local.plugin_path}"
    EOT
  }
}

output "plugin_path" {
  description = "Локальный каталог, содержимое которого уходит на хост (local_path для upload_files)"
  value       = local.plugin_path
}

output "archive_path" {
  description = "Локальный файл скачанного архива — нужен вызывающему модулю для уборки после заливки"
  value       = local.archive_path
}

output "extract_path" {
  description = "Локальный каталог распаковки — нужен вызывающему модулю для уборки после заливки"
  value       = local.extract_path
}

output "archive_sha256" {
  description = "sha256 скачанного архива: меняется содержимое по ссылке — переигрываются распаковка, заливка и уборка (triggers_replace)"
  value       = local_sensitive_file.archive.content_sha256
}