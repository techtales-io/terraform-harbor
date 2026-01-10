<!-- markdownlint-disable MD041 -->
<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD028 -->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![nix][nix-shield]][nix-url]
[![pre-commit][pre-commit-shield]][pre-commit-url]
[![taskfile][taskfile-shield]][taskfile-url]
[![terraform][terraform-shield]][terraform-url]

# Terraform Harbor for techtales.io

Harbor  as code with Terraform.

<details>
  <summary style="font-size:1.2em;">Table of Contents</summary>
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Concept](#concept)
  - [Policy](#policy)
- [Usage](#usage)
- [Code-Style](#code-style)
  - [Terraform](#terraform)
- [Getting Started](#getting-started)
  - [Prerequisties](#prerequisties)
  - [Initialize repository](#initialize-repository)
- [ENV](#env)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
</details>

## Concept

### Policy

#### Users

Real users will access buckets by the following pattern:

> $BUCKET/$USER/\*

Example: backup/tyriis/android, documents/jazzlyn/

#### Groups

Member of groups will access buckets by the following pattern:

> $BUCKET/$GROUP/\*

Example: documents/techtales/, documents/familly/

#### K8s services and service accounts

K8s services will access buckets by the following pattern:

> $CLUSTER/$SERVICE/\*

Example: k3s.home/node-red/data

ToDo: check if it would be better to create a bucket for each service

## Usage

\*various commands

## Code-Style

### Terraform

#### Best practices

[terraform-best-practices.com][terraform-best-practices]

#### Naming of Terraform resources

- lower-case characters

Pattern: `[a-z_-]+`

## Getting Started

### Prerequisties

- [pre-commit][pre-commit-url]
- [terraform][terraform-url]
- [terraform-docs][terraform-docs]
- [tflint][tflint]
- [tfsec][tfsec]

### Initialize repository

Terraform and pre-commit framework need to get initialized.

```console
task terraform:init
task pre-commit:init
```

## ENV

| Name                    | Description                             |
| ----------------------- | --------------------------------------- |
| `VAULT_TOKEN`           | vault token                             |
| `AWS_ENDPOINT_URL_S3`   | endpoint url for the s3 state backend   |
| `AWS_REGION`            | region for the s3 state backend         |
| `AWS_ACCESS_KEY_ID`     | username for the s3 state backend       |
| `AWS_SECRET_ACCESS_KEY` | password for the s3 state backend       |
| `MINIO_ENDPOINT`        | the minio endpoint FQDN without http(s) |
| `MINIO_USER`            | the minio admin username                |
| `MINIO_PASSWORD`        | the minio admin password                |
| `MINIO_ENABLE_HTTPS`    | should be true                          |

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- Links -->

[terraform-best-practices]: https://www.terraform-best-practices.com/naming
[terraform-docs]: https://github.com/terraform-docs/terraform-docs
[tflint]: https://github.com/terraform-linters/tflint
[tfsec]: https://aquasecurity.github.io/tfsec

<!-- Badges -->

[terraform-shield]: https://img.shields.io/badge/terraform-1.x-844fba?logo=terraform
[terraform-url]: https://www.terraform.io/
[pre-commit-shield]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit
[pre-commit-url]: https://github.com/pre-commit/pre-commit
[taskfile-shield]: https://img.shields.io/badge/taskfile-enabled-brightgreen?logo=task
[taskfile-url]: https://taskfile.dev/
[nix-shield]: https://img.shields.io/badge/nix-enabled-brightgreen?logo=nixos
[nix-url]: https://search.nixos.org/packages
