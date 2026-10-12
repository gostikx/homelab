variable "plugin" {
  description = <<-EOT
    Плагин, архив которого надо скачать и распаковать локально.
    name   — короткое уникальное имя: идёт в имена файлов и каталогов .tmp/, поэтому без слешей;
    url    — прямая ссылка на архив (zip или tar.gz: GitHub archive/refs/..., releases/.../asset),
             версию обязательно пинить (тег/номер релиза/commit): отпечаток url+subdir переигрывает
             скачивание и заливку, а плавающая ссылка (ветка, `latest`) не меняется и обновлений не даст;
    subdir — относительный путь внутри архива, который уходит на хост (у интеграций HA —
             custom_components/<домен>); пусто — заливать корень архива целиком.
  EOT

  type = object({
    name   = string
    url    = string
    subdir = optional(string, "")
  })

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9._-]*$", var.plugin.name))
    error_message = "plugin.name попадает в пути (.tmp/<name>.archive, .tmp/extracted/<name>): нужны буквы/цифры/точка/дефис/подчёркивание, без слешей и \"..\" — иначе распаковка пишет вне .tmp/."
  }

  validation {
    condition     = can(regex("^https?://", var.plugin.url))
    error_message = "plugin.url — прямая http/https-ссылка на архив (пустая строка или относительный путь скачать нельзя)."
  }

  validation {
    condition     = var.plugin.subdir == "" || can(regex("^[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$", var.plugin.subdir))
    error_message = "plugin.subdir — относительный путь внутри архива (например \"custom_components/hacs\"): без ведущего и замыкающего слеша, без пустых сегментов (\"//\") и без \"..\"."
  }
}
