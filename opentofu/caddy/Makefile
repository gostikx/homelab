.PHONY: deploy-caddy destroy-caddy

deploy-caddy: deploy-smallstep-ca #? Развернуть Caddy — reverse proxy с автоматическим HTTPS (сначала SmallStepCA)
	tofu workspace select caddy
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-caddy: #? Удалить Caddy (контейнер и ресурсы workspace "caddy")
	tofu workspace select caddy
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
