.PHONY: deploy-smallstep-ca destroy-smallstep-ca

deploy-smallstep-ca: #? Развернуть SmallStepCA — альтернатива let`s encrypt
	tofu workspace select smallstep-ca
	tofu apply -var-file="variables.tfvars" -auto-approve

destroy-smallstep-ca: #? Удалить SmallStepCA (контейнер и ресурсы workspace "smallstep-ca")
	tofu workspace select smallstep-ca
	tofu apply -destroy -var-file="variables.tfvars" -auto-approve
