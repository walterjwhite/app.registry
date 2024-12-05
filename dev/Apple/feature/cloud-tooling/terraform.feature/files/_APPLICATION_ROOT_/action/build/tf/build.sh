_require "$VAULT_TOKEN" VAULT_TOKEN
_require "$VAULT_ADDR" VAULT_ADDR
terraform init && terraform plan && terraform apply
