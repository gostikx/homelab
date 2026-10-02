# Цели сервиса Portainer (веб-UI для управления Docker).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-portainer destroy-portainer

deploy-portainer: #? Развернуть Portainer — веб-UI для управления Docker
	tofu workspace select portainer
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-portainer: #? Удалить Portainer (контейнер и ресурсы workspace "portainer")
	tofu workspace select portainer
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
