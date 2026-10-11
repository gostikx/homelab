STACKS         := $(notdir $(wildcard stacks/*))
VAR_FILE       := $(abspath variables.tfvars)
BACKEND_CONFIG := backend.tfvars

.DEFAULT_GOAL := help

.PHONY: help init init-update lint

init: $(addprefix init-,$(STACKS)) #? Инициализировать все стеки (провайдеры + свой backend)

init-%: #? Инициализировать стек % (backend из stacks/%/backend.tfvars)
	tofu -chdir=stacks/$* init -input=false -backend-config="$(BACKEND_CONFIG)"

plan-%: init-% #? Показать план стека % (реальный хост не меняется)
	tofu -chdir=stacks/$* plan -var-file="$(VAR_FILE)" -compact-warnings

deploy-%: init-% #? Применить стек % (МЕНЯЕТ реальный хост)
	tofu -chdir=stacks/$* apply -var-file="$(VAR_FILE)" -compact-warnings -auto-approve

destroy-%: init-% #? Удалить стек % (МЕНЯЕТ реальный хост)
	tofu -chdir=stacks/$* apply -destroy -var-file="$(VAR_FILE)" -compact-warnings -auto-approve

init-update: #? Обновить провайдеры во всех стеках (tofu init -upgrade)
	@set -e; for stack in $(STACKS); do echo "→ $$stack"; tofu -chdir=stacks/$$stack init -upgrade -input=false -backend-config="$(BACKEND_CONFIG)"; done

lint: #? Проверить форматирование и валидность всех стеков (сначала — make init)
	tofu fmt -check -recursive
	@set -e; for stack in $(STACKS); do echo "→ validate stacks/$$stack"; tofu -chdir=stacks/$$stack validate; done

help: #? Показать этот список команд
	@printf "\033[34;01mУправление стеками homelab (OpenTofu):\033[0m\n"
	@awk 'BEGIN { FS = ":.*#\\? " } /^[a-zA-Z0-9_%-]+:.*#\? / { printf "\033[1;31m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n\033[34;01mСтеки:\033[0m\n"; for stack in $(STACKS); do printf " - %s\n" "$$stack"; done
