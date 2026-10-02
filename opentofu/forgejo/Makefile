# Цели сервиса Forgejo (self-hosted Git).
# Подключается из ../Makefile — запускать из каталога opentofu/.
.PHONY: deploy-forgejo destroy-forgejo

deploy-forgejo: #? Развернуть Forgejo — self-hosted Git
	tofu workspace select forgejo
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-forgejo: #? Удалить Forgejo (контейнер и ресурсы workspace "forgejo")
	tofu workspace select forgejo
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
