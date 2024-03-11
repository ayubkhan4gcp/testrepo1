terraform {
  backend "gcs" {
    bucket = "terraform_state_bucket7417"
    prefix = "terraform/state"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}
