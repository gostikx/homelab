# Цели сервиса PostgreSQL (база данных).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-postgres destroy-postgres

deploy-postgres: #? Развернуть PostgreSQL — база данных
	tofu workspace select postgresql
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-postgres: #? Удалить PostgreSQL (контейнер и ресурсы workspace "postgresql")
	tofu workspace select postgresql
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
