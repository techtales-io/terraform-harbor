# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIGURE TERRAFORM
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 1.9.0, <= 1.14.3"
  required_providers {
    # https://registry.terraform.io/providers/goharbor/harbor/latest/docs
    harbor = {
      source  = "goharbor/harbor"
      version = "3.11.3"
    }
    # https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
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
