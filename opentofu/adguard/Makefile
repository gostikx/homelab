.PHONY: deploy-adguard destroy-adguard

deploy-adguard: #? Развернуть AdGuard Home — веб-UI для управления AdGuard Home
	tofu workspace select adguard-home
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-adguard: #? Удалить AdGuard Home (контейнер и ресурсы workspace "adguard")
	tofu workspace select adguard-home
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
