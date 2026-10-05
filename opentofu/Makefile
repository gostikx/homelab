include caddy/Makefile
include forgejo/Makefile
include home-assistant/Makefile
include mosquitto/Makefile
include portainer/Makefile
include postgresql/Makefile
include small-step-ca/Makefile
include adguard/Makefile

# Файлы конфигурации относительно каталога opentofu/ (откуда запускается make).
BACKEND_CONFIG := backend.tfvars
VAR_FILE       := variables.tfvars

.DEFAULT_GOAL := help

.PHONY: help init deploy-network destroy-network lint

init-update: #? Обновить или пересоздать провайдеры
	tofu init -upgrade -backend-config="$(BACKEND_CONFIG)"

init: #? Инициализировать провайдеры и создать все рабочие пространства (workspaces)
	tofu init -backend-config="$(BACKEND_CONFIG)"
	tofu workspace select -or-create network
	tofu workspace select -or-create portainer
	tofu workspace select -or-create caddy
	tofu workspace select -or-create forgejo
	tofu workspace select -or-create postgresql
	tofu workspace select -or-create home_assistant
	tofu workspace select -or-create mosquitto
	tofu workspace select -or-create smallstep-ca
	tofu workspace select -or-create adguard-home

deploy-network: #? Создать общую docker-сеть homelab-network (нужна до запуска сервисов)
	tofu workspace select network
	tofu apply -var-file="$(VAR_FILE)" -auto-approve

destroy-network: #? Удалить общую docker-сеть (сначала остановите все сервисы)
	tofu workspace select network
	tofu apply -destroy -var-file="$(VAR_FILE)" -auto-approve

lint: #? Проверить форматирование и валидность конфигурации
	tofu fmt -check -recursive
	tofu validate

help: #? Показать этот список команд
	@printf "\033[34;01mУправление сервисами homelab (OpenTofu):\033[0m\n"
	@awk 'BEGIN { FS = ":.*#\\? " } /^[a-zA-Z0-9_-]+:.*#\? / { printf "\033[1;31m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
