provider "vault" {
  # ATLANTIS_INJECT_VAULT_CONFIG
}

data "vault_generic_secret" "terraform_harbor" {
  path = "infra/techtales/terraform-harbor"
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs
provider "harbor" {
  username = data.vault_generic_secret.terraform_harbor.data["username"]
  password = data.vault_generic_secret.terraform_harbor.data["password"]
  url = data.vault_generic_secret.terraform_harbor.data["url"]
}
