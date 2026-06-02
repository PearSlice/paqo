# OCI Terraform — Quarkus ARM Infrastructure

Provisions two Always-Free ARM VMs on Oracle Cloud:
- **App VM** (public subnet) — runs your Quarkus native container via Docker
- **DB VM** (private subnet) — runs PostgreSQL 16, reachable only from the app VM

## Architecture

```
Internet
   │
   ▼
[App VM] ── public subnet (10.0.1.0/24)
   │         NSG allows: 22 (SSH), 8080 (HTTP)
   │
   │ private subnet (10.0.2.0/24)
   ▼
[DB VM]   NSG allows: 5432 only from app NSG
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- OCI account with Always Free eligible region
- OCI API key configured (`~/.oci/config`)
- SSH key pair for VM access

## Quick start

```bash
# 1. Clone and enter the terraform directory
cd terraform/

# 2. Create your tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCIDs and settings

# 3. Generate an SSH key if you don't have one
ssh-keygen -t ed25519 -f ~/.ssh/oci_quarkus

# 4. Init and apply
terraform init
terraform plan
terraform apply
```

After `apply` completes, Terraform prints:
- `app_public_ip` — SSH to this, deploy your Docker container here
- `db_private_ip` — use in your Quarkus JDBC URL
- `jdbc_url` — copy this into your `application.properties`

## Deploying the Quarkus app

```bash
# SSH into app VM
ssh opc@<app_public_ip>

# Pull and run your container
docker run -d \
  -p 8080:8080 \
  -e DB_HOST=<db_private_ip> \
  -e DB_USER=appuser \
  -e DB_PASSWORD=<your-password> \
  -e DB_NAME=appdb \
  <your-registry>/my-service:latest
```

## Finding your OCIDs

| Value | Where to find it |
|---|---|
| `tenancy_ocid` | OCI Console → top-right profile → Tenancy |
| `user_ocid` | OCI Console → top-right profile → User Settings |
| `fingerprint` | User Settings → API Keys |
| `compartment_ocid` | Identity → Compartments |
| `region` | OCI Console top bar (e.g. `eu-frankfurt-1`) |

## Free tier limits

OCI Always Free ARM gives you a pool of **4 OCPU + 24 GB RAM** total.
Default split in this config:

| VM | OCPU | RAM |
|---|---|---|
| App | 2 | 8 GB |
| DB  | 2 | 16 GB |
| **Total** | **4** | **24 GB** ✅ |

## Teardown

```bash
terraform destroy
```
