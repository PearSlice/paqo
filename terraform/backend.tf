# Remote state stored in OCI Object Storage.
# The bucket is created by the terraform-bootstrap workflow.
# Fill in your namespace and region before enabling this.
#
# To enable:
# 1. Run the "Terraform Bootstrap" workflow manually in GitHub Actions
# 2. Copy the backend block it prints into this file and uncomment it
# 3. Run `terraform init -migrate-state` locally (one time) or push to trigger CI

terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "quarkus/prod/terraform.tfstate"
    region = "eu-zurich-1" #Not used in s3 compatible oracle cloud, but tf complains otherwise
    endpoint = "https://zr2oljekdsmp.compat.objectstorage.eu-zurich-1.oraclecloud.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}
