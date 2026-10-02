# Цели сервиса Home Assistant (умный дом).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-home-assistant destroy-home-assistant

deploy-home-assistant: #? Развернуть Home Assistant — умный дом
	tofu workspace select home_assistant
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-home-assistant: #? Удалить Home Assistant (контейнер и ресурсы workspace "home_assistant")
	tofu workspace select home_assistant
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
