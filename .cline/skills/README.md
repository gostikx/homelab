# Agent Skills проекта homelab

Каталог `.cline/skills/<name>/` — проектные (не глобальные) Agent Skills для Cline.
Ожидаемая раскладка: `<name>/SKILL.md` с фронтматтером `name` + `description`, вспомогательные
файлы рядом (`references/*.md`, `SECURITY.md`, `LICENSE`) — Cline читает их по ссылкам из `SKILL.md`.
Наличие и приоритет описаны в `.clinerules` §5: скиллы задают upstream best practice, правила проекта —
проектные уточнения к ним. Расходится код со скиллом — приводим **код** к скиллу; осознанные отступления
перечислены в `NOTES.md` («осознанные исключения»).

## terraform-skill

* Источник: <https://github.com/antonbabenko/terraform-skill> (каталог `skills/terraform-skill/`).
* Автор: Anton Babenko · лицензия Apache-2.0 (`LICENSE`).
* Версия в файле: `metadata.version: 1.17.1` (`SKILL.md`).
* Что внутри: `SKILL.md` (workflow «diagnose-first») + `references/`: `code-patterns`,
  `module-patterns`, `state-management`, `testing-frameworks`, `ci-cd-workflows`,
  `security-compliance`, `code-intelligence-lsp`, `quick-reference`.
* Профиль проекта: файл ориентирован на Terraform/AWS, но failure-mode, `moved`/`for_each`,
  провижны, state и работа с секретами применимы к нашему OpenTofu. Полезен при разборе
  replace/дрейфа и при правках `terraform_data`/`plugins/*`.

## terraform-style-guide

* Источник: <https://github.com/hashicorp/agent-skills> (каталог `plugins/terraform/skills/terraform-style-guide`).
* Лицензия MPL-2.0 (`LICENSE`), официальный гайд:
  <https://developer.hashicorp.com/terraform/language/style>.
* Что внутри: `SKILL.md` (конвенции HCL: именование, порядок блоков, `variable`/`output`,
  `dynamic`, форматирование) + `SECURITY.md` (вложенный скилл `terraform-style-guide-security`:
  шифрование, least privilege, `sensitive`, `ephemeral`/write-only).
* Профиль проекта: сверяться при генерации нового HCL. Отклонения от гайда не «закрепляем» — приводим код к
  гайду; разбор и порядок правок — в `NOTES.md` (ревью P1-3, P2-*, §4 «осознанные исключения»).

## Обновление

Перезаписать файлы скилла из upstream (тот же относительный путь внутри каталога скилла) — `SKILL.md`
и `references/` обновляются вместе. Версию/лицензию после обновления сверить с `SKILL.md`/`LICENSE`
и, если менялось поведение, поправить §5 в `.clinerules`.
