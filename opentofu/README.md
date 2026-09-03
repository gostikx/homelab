# Opentofu scripts

```sh
$ tofu init \
  -backend-config="path=$HOME/.opentofu/tofu.tfstate" \
  -backend-config="workspace_dir=$HOME/.opentofu/terraform"

$ tofu plan
$ tofu apply
  # Опциональные параметры:
  # -var-file="environment.tfvars" - файл с переменными. По умолчанию *.auto.tfvars
  # --auto-approve - автоматическое подтверждение изменений (не рекомендуется)
```