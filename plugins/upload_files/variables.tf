variable "ssh_config" {
  description = "Параметры SSH-подключения к docker-хосту — тот же объект, что у setup_dirs"
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

variable "local_path" {
  description = "Что заливать: локальный файл или каталог (provisioner file, source). Взаимоисключающе с content. Имя не `source`: `source` в вызове модуля — мета-аргумент"
  type        = string
  default     = null

  validation {
    condition     = var.local_path == null || var.local_path != ""
    error_message = "local_path — либо null (используется content), либо непустой путь к файлу/каталогу."
  }
}

variable "content" {
  description = "Содержимое файла, если он рендерится из конфига (templatefile), а не лежит в репозитории. Взаимоисключающе с local_path"
  type        = string
  default     = null
  sensitive   = true
}

variable "remote_path" {
  description = "Путь на docker-хосте: каталог (если local_path — каталог) либо полный путь файла"
  type        = string

  validation {
    condition     = startswith(var.remote_path, "/")
    error_message = "remote_path — абсолютный путь на docker-хосте, начинающийся с \"/\"."
  }
}

variable "commands" {
  description = "Команды на хосте после заливки (обычно права: find <dir> -type d -exec chmod 700 и т.п.), выполняются по порядку"
  type        = list(string)
  default     = []
}

variable "triggers_replace" {
  description = "Значение переигровки провижна (обычно sha256 конфига). Без него провижн выполнится один раз за жизнь ресурса и молча устареет (.clinerules §7)"
  type        = any
  default     = null
}
