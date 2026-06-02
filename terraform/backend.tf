# Remote state stored in OCI Object Storage.
# The bucket is created by the terraform-bootstrap workflow.
# Fill in your namespace and region before enabling this.
#
# To enable:
# 1. Run the "Terraform Bootstrap" workflow manually in GitHub Actions
# 2. Copy the backend block it prints into this file and uncomment it
# 3. Run `terraform init -migrate-state` locally (one time) or push to trigger CI

# terraform {
#   backend "s3" {
#     bucket   = "terraform-state"
#     key      = "quarkus/prod/terraform.tfstate"
#     region   = "<your-region>"           # e.g. eu-zurich-1
#     endpoint = "https://<namespace>.compat.objectstorage.<region>.oraclecloud.com"
#
#     # OCI-specific overrides
#     shared_credentials_file     = "/dev/null"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     force_path_style            = true
#
#     # Credentials via environment variables in CI:
#     # AWS_ACCESS_KEY_ID     = OCI user's access key
#     # AWS_SECRET_ACCESS_KEY = OCI user's secret key
#   }
# }
