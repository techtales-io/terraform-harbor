# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIGURE TERRAFORM
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 1.11.0, <= 1.17.1"
  required_providers {
    # https://registry.terraform.io/providers/goharbor/harbor/latest/docs
    harbor = {
      source  = "goharbor/harbor"
      version = "3.12.5"
    }
    # https://registry.terraform.io/providers/hashicorp/random/latest/docs
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.0"
    }
    # https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    vault = {
      source  = "hashicorp/vault"
      version = "5.13.0"
    }
  }
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "docker_hub_proxy" {
  provider_name = "docker-hub"
  name          = "docker-hub"
  endpoint_url  = "https://hub.docker.com"
  # TODO: use docker credentials
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "ghcr_proxy" {
  provider_name = "github"
  name          = "github"
  endpoint_url  = "https://ghcr.io"
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "quay_proxy" {
  provider_name = "quay"
  name          = "quay"
  endpoint_url  = "https://quay.io"
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
resource "harbor_project" "main" {
  name                        = "main"
  public                      = true
  vulnerability_scanning      = true
  enable_content_trust        = false
  enable_content_trust_cosign = false
  auto_sbom_generation        = true
  storage_quota               = -1
  deployment_security         = null
  cve_allowlist               = []
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
resource "harbor_project" "library" {
  name                        = "library"
  public                      = true
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  auto_sbom_generation        = false
  force_destroy               = false
  storage_quota               = -1
  deployment_security         = null
  cve_allowlist               = []
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
# import existing project
import {
  to = harbor_project.library
  id = "/projects/1"
}

# TODO: configure oidc

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
resource "harbor_project" "proxy-docker-io" {
  name                        = "proxy-docker.io"
  public                      = true
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  auto_sbom_generation        = true
  storage_quota               = -1
  deployment_security         = null
  cve_allowlist               = []
  registry_id                 = harbor_registry.docker_hub_proxy.registry_id
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
# not working anymore out of the box
# FIXME: quay.io has been deprectated in harbor
# resource "harbor_project" "proxy-quay-io" {
#   name                        = "proxy-quay.io"
#   public                      = true
#   vulnerability_scanning      = false
#   enable_content_trust        = false
#   enable_content_trust_cosign = false
#   auto_sbom_generation        = true
#   storage_quota               = -1
#   deployment_security         = null
#   cve_allowlist               = []
#   registry_id                 = harbor_registry.quay_proxy.registry_id
# }

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project
resource "harbor_project" "proxy-ghcr-io" {
  name                        = "proxy-ghcr.io"
  public                      = true
  vulnerability_scanning      = false
  enable_content_trust        = false
  enable_content_trust_cosign = false
  auto_sbom_generation        = true
  storage_quota               = -1
  deployment_security         = null
  cve_allowlist               = []
  registry_id                 = harbor_registry.ghcr_proxy.registry_id
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROBOT ACCOUNTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# the secret is generated on every run and never persisted: it only reaches the
# write-only arguments below (harbor secret_wo and vault data_json_wo)
ephemeral "random_password" "main_ci_pusher" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/robot_account
# login name is not `name` but `full_name`, e.g. robot$main+ci-pusher
resource "harbor_robot_account" "main_ci_pusher" {
  name              = "ci-pusher"
  description       = "agent robot account: build and push images into main"
  level             = "project"
  secret_wo         = ephemeral.random_password.main_ci_pusher.result
  secret_wo_version = 1
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    access {
      action   = "push"
      resource = "repository"
    }
    kind      = "project"
    namespace = harbor_project.main.name
  }
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2
resource "vault_kv_secret_v2" "harbor_robot_main_ci_pusher" {
  mount               = "infra"
  name                = "harbor"
  delete_all_versions = true
  data_json_wo = jsonencode({
    username = harbor_robot_account.main_ci_pusher.full_name
    password = ephemeral.random_password.main_ci_pusher.result
    registry = data.vault_generic_secret.terraform_harbor.data["url"]
  })
  data_json_wo_version = 1
}
