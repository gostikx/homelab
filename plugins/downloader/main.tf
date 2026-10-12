locals {
  tmp_dir      = "${path.root}/.tmp"
  archive_path = "${local.tmp_dir}/${var.plugin.name}.archive"
  extract_path = "${local.tmp_dir}/extracted/${var.plugin.name}"

  stage_path = "${local.extract_path}.stage"

  plugin_path = var.plugin.subdir == "" ? local.extract_path : "${local.extract_path}/${var.plugin.subdir}"

  spec_hash = sha256(jsonencode(var.plugin))
}

resource "terraform_data" "fetch" {
  triggers_replace = {
    spec         = local.spec_hash
    extract_path = local.extract_path
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -eu

      mkdir -p "$(dirname "${local.archive_path}")"

      # -f: HTTP-ошибка роняет apply, а не оставляет на диске HTML вместо архива;
      # --retry: транзиентные сбои GitHub/CDN не требуют повторного apply
      curl -fsSL --retry 3 --retry-delay 1 --retry-connrefused \
        -H 'Accept: application/octet-stream' \
        -o "${local.archive_path}" "${var.plugin.url}"

      rm -rf "${local.extract_path}" "${local.stage_path}"
      mkdir -p "${local.stage_path}"

      # Тип архива определяется по содержимому (`unzip -tqq`/`tar -tf`), а не по расширению:
      # файл скачан как <имя>.archive, расширения у него нет.
      if unzip -tqq "${local.archive_path}" > /dev/null 2>&1; then
        unzip -qq "${local.archive_path}" -d "${local.stage_path}"
      elif tar -tf "${local.archive_path}" > /dev/null 2>&1; then
        tar -xf "${local.archive_path}" -C "${local.stage_path}"
      else
        echo "ОШИБКА: ${local.archive_path} не распознан ни как zip, ни как tar — проверьте plugin.url: ссылка должна вести на файл архива, а не на HTML-страницу" >&2
        exit 1
      fi

      # Архивы GitHub (archive/refs/heads|tags/<ref>.zip) кладут всё в единственный каталог
      # <repo>-<ref>/ с именем ветки/тега: снимаем этот «обёрточный» уровень, иначе plugin.subdir
      # пришлось бы писать вместе с ним.
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

      echo "✔ ${var.plugin.name}: скачано в ${local.archive_path}, распаковано в ${local.extract_path}, каталог для заливки — ${local.plugin_path}"
    EOT
  }
}

output "plugin_path" {
  description = "Локальный каталог, содержимое которого уходит на хост (local_path для upload_files)"
  value       = local.plugin_path
}

output "archive_path" {
  description = "Локальный файл скачанного архива — кэш скачивания в .tmp/ (в .gitignore), переживает apply"
  value       = local.archive_path
}

output "extract_path" {
  description = "Локальный каталог распаковки — кэш в .tmp/ (в .gitignore), переживает apply"
  value       = local.extract_path
}

output "spec_hash" {
  description = "Отпечаток запрошенной версии плагина (url + subdir) — вход для triggers_replace у заливки и метки ревизии контейнера"
  value       = local.spec_hash
}
