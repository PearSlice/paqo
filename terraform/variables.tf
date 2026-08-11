# ─── OCI Auth ────────────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy (also the root compartment)"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user running Terraform"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key (.pem)"
  type        = string
}

variable "region" {
  description = "OCI region (e.g. eu-frankfurt-1)"
  type        = string
}

# ─── Project ──────────────────────────────────────────────────────────────────
variable "project_name" {
  description = "Short name used to prefix all resources"
  type        = string
  default     = "quarkus"
}

variable "environment" {
  description = "Environment label (prod, staging, dev)"
  type        = string
  default     = "prod"
}

# ─── Network ─────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (app VM)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet (DB VM)"
  type        = string
  default     = "10.0.2.0/24"
}

# ─── Compute ─────────────────────────────────────────────────────────────────
variable "ssh_public_key_path" {
  description = "Path to your SSH public key for VM access"
  type        = string
}

variable "app_ocpus" {
  description = "OCPUs for the app VM (A1 free tier: max 2 total, 1 per VM)"
  type        = number
  default     = 1
}

variable "app_memory_gb" {
  description = "Memory in GB for the app VM"
  type        = number
  default     = 4
}

variable "db_ocpus" {
  description = "OCPUs for the DB VM"
  type        = number
  default     = 1
}

variable "db_memory_gb" {
  description = "Memory in GB for the DB VM"
  type        = number
  default     = 8
}

# ─── Database ────────────────────────────────────────────────────────────────
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "PostgreSQL application user"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "PostgreSQL application user password"
  type        = string
  sensitive   = true
}

# ─── GitHub ───────────────────────────────────────────────────────────────────
variable "gh_token" {
  description = "GitHub Fine-grained PAT with Secrets and Environments (read/write)"
  type        = string
  sensitive   = true
}

variable "gh_owner" {
  description = "GitHub username or organisation name"
  type        = string
}

variable "gh_repo" {
  description = "Repository name (without owner prefix)"
  type        = string
}

# ─── OCIR ─────────────────────────────────────────────────────────────────────
variable "ocir_region" {
  description = "OCIR hostname (e.g. fra.ocir.io)"
  type        = string
}

variable "ocir_username" {
  description = "OCIR login: <tenancy-namespace>/<oci-username>"
  type        = string
}

variable "ocir_token" {
  description = "OCI Auth Token used as OCIR password"
  type        = string
  sensitive   = true
}
