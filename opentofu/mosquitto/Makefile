# Цели сервиса Mosquitto (MQTT-брокер).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-mosquitto destroy-mosquitto

deploy-mosquitto: #? Развернуть Mosquitto — MQTT-брокер
	tofu workspace select mosquitto
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-mosquitto: #? Удалить Mosquitto (контейнер и ресурсы workspace "mosquitto")
	tofu workspace select mosquitto
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
