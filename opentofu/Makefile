export TF_VAR_shared_state_dir := $(HOME)/.opentofu/shared-states

.PHONY: deploy-forgejo
deploy-forgejo:
	mkdir -p $(TF_VAR_shared_state_dir)/forgejo
	tofu init
	tofu apply -target=module.forgejo -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-portainer
deploy-portainer:
	mkdir -p $(TF_VAR_shared_state_dir)/portainer
	tofu init
	tofu apply -target=module.portainer -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-caddy
deploy-caddy:
	mkdir -p $(TF_VAR_shared_state_dir)/caddy
	tofu init
	tofu apply -target=module.caddy -var-file="variables.tfvars" -auto-approve

.PHONY: deploy-postgres
deploy-caddy:
	mkdir -p $(TF_VAR_shared_state_dir)/postgres
	tofu init
	tofu apply -target=module.postgres -var-file="variables.tfvars" -auto-approve
