terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "harbor/terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
