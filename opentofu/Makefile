.PHONY: init
init:
	tofu init -backend-config="backend.tfvars"
	tofu workspace new portainer
	tofu workspace new caddy
	tofu workspace new forgejo
	tofu workspace new postgresql

.PHONY: deploy-portainer
deploy-portainer:
	tofu workspace select portainer
	tofu apply -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-caddy
deploy-caddy:
	tofu workspace select caddy
	tofu apply -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-forgejo
deploy-forgejo:
	tofu workspace select forgejo
	tofu apply -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-postgres
deploy-postgres:
	tofu workspace select postgresql
	tofu apply -var-file="variables.tfvars" -auto-approve
