terraform {
  backend "gcs" {
    bucket = "terraform_state_bucket7417"
    prefix = "terraform/state"
    skip_credentials_validation = true
  }
}
