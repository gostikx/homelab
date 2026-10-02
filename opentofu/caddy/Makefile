# Цели сервиса Caddy (reverse proxy с автоматическим HTTPS).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-caddy destroy-caddy

deploy-caddy: #? Развернуть Caddy — reverse proxy с автоматическим HTTPS
	tofu workspace select caddy
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-caddy: #? Удалить Caddy (контейнер и ресурсы workspace "caddy")
	tofu workspace select caddy
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
