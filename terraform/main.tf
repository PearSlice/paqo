terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Uncomment to store state in OCI Object Storage (recommended for teams)
  # backend "s3" {
  #   bucket                      = "terraform-state"
  #   key                         = "quarkus/prod/terraform.tfstate"
  #   region                      = "eu-frankfurt-1"
  #   endpoint                    = "https://<namespace>.compat.objectstorage.<region>.oraclecloud.com"
  #   shared_credentials_file     = "/dev/null"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   force_path_style            = true
  # }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

provider "github" {
  token = var.gh_token
  owner = var.gh_owner
}

# ─── Compartment ──────────────────────────────────────────────────────────────
# Created under the root compartment (tenancy). All other resources use this.
resource "oci_identity_compartment" "main" {
  compartment_id = var.tenancy_ocid # parent = root
  name           = "${var.project_name}-${var.environment}"
  description    = "Compartment for ${var.project_name} ${var.environment} resources"
  enable_delete  = true # allows `terraform destroy` to remove it
  freeform_tags  = local.common_tags
}

# ─── Resolve the latest ARM-compatible Oracle Linux 8 image ──────────────────
data "oci_core_images" "arm_ol8" {
  compartment_id           = oci_identity_compartment.main.id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ─── Resolve tenancy namespace (used for OCIR and Object Storage) ─────────────
data "oci_objectstorage_namespace" "ns" {
  compartment_id = oci_identity_compartment.main.id
}

locals {
  arm_image_id = data.oci_core_images.arm_ol8.images[0].id
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ─── Modules ──────────────────────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  compartment_ocid    = oci_identity_compartment.main.id
  project_name        = var.project_name
  vcn_cidr            = var.vcn_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  tags                = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  compartment_ocid    = oci_identity_compartment.main.id
  project_name        = var.project_name
  arm_image_id        = local.arm_image_id
  ssh_public_key_path = var.ssh_public_key_path
  public_subnet_id    = module.network.public_subnet_id
  private_subnet_id   = module.network.private_subnet_id
  app_nsg_id          = module.network.app_nsg_id
  db_nsg_id           = module.network.db_nsg_id
  app_ocpus           = var.app_ocpus
  app_memory_gb       = var.app_memory_gb
  db_ocpus            = var.db_ocpus
  db_memory_gb        = var.db_memory_gb
  tags                = local.common_tags
}

module "database" {
  source = "./modules/database"

  db_vm_id             = module.compute.db_vm_id
  db_private_ip        = module.compute.db_private_ip
  app_public_ip        = module.compute.app_public_ip
  ssh_private_key_path = replace(var.ssh_public_key_path, ".pub", "")
  db_name              = var.db_name
  db_user              = var.db_user
  db_password          = var.db_password
}

# ─── Object Storage Bucket ────────────────────────────────────────────────────
resource "oci_objectstorage_bucket" "main" {
  compartment_id = oci_identity_compartment.main.id
  namespace      = data.oci_objectstorage_namespace.ns.name
  name           = "${var.project_name}-${var.environment}-bucket"
  access_type    = "NoPublicAccess"
  freeform_tags  = local.common_tags
}

# ─── GitHub Secrets ───────────────────────────────────────────────────────────
module "github_secrets" {
  source = "./modules/github"

  github_repo      = var.gh_repo
  environment_name = "production"

  # Repository secrets
  repo_secrets = {
    OCIR_REGION         = var.ocir_region
    OCIR_NAMESPACE      = data.oci_objectstorage_namespace.ns.name
    OCIR_USERNAME       = var.ocir_username
    OCIR_TOKEN          = var.ocir_token
    OCI_SSH_PRIVATE_KEY = file(replace(var.ssh_public_key_path, ".pub", ""))
    OCI_SSH_PUBLIC_KEY  = file(var.ssh_public_key_path)
    OCI_API_KEY_PEM     = file(var.private_key_path)
    TF_TENANCY_OCID     = var.tenancy_ocid
    TF_USER_OCID        = var.user_ocid
    TF_FINGERPRINT      = var.fingerprint
    TF_REGION           = var.region
    TF_COMPARTMENT_OCID = oci_identity_compartment.main.id
  }

  # Environment secrets (production only)
  env_secrets = {
    OCI_APP_IP    = module.compute.app_public_ip
    DB_PRIVATE_IP = module.compute.db_private_ip
    DB_NAME       = var.db_name
    DB_USER       = var.db_user
    DB_PASSWORD   = var.db_password
  }
}
