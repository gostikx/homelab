variable "ssh_config" {
  type = object({
    host = string
    port = number
    user = string
    key  = string
  })
}

variable "dirs" {
  description = "Каталоги на docker-хосте: mode — chmod, uid/gid — владелец (chown, при необходимости через docker), recursive — chown -R"
  type = list(object({
    path      = string
    mode      = optional(string)
    uid       = optional(number)
    gid       = optional(number)
    recursive = optional(bool, true)
  }))

  validation {
    condition     = alltrue([for dir in var.dirs : startswith(dir.path, "/")])
    error_message = "path — абсолютный путь на docker-хосте, начинающийся с \"/\"."
  }

  validation {
    condition     = alltrue([for dir in var.dirs : dir.mode == null || can(regex("^[0-7]{3,4}$", dir.mode))])
    error_message = "mode — восьмеричные права из 3-4 цифр, например \"700\" или \"0755\"."
  }

  validation {
    condition     = alltrue([for dir in var.dirs : (dir.uid == null) == (dir.gid == null)])
    error_message = "uid и gid задаются только вместе (владелец каталога)."
  }
}

variable "copies" {
  description = "Файлы, которые надо разложить уже на хосте: install -m <mode> <from> <to> (например CA-сертификаты из тома step-ca в каталог Caddy)"
  type = list(object({
    from = string
    to   = string
    mode = optional(string, "600")
  }))
  default = []
}

variable "chown_image" {
  description = "Образ для chown от root — нужен, когда владелец (uid/gid) отличается от SSH-пользователя"
  type        = string
  default     = "alpine:3.22"
}
