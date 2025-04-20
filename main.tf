# Remote state data source for AWS organization structure
data "terraform_remote_state" "org_structure" {
  backend = "s3"
  config = {
    bucket = "terraform-state-asl-foundation"
    key    = "organization/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  account_ids = data.terraform_remote_state.org_structure.outputs.account_ids
}