output "compartment_ocid" {
  description = "OCID of the created compartment"
  value       = oci_identity_compartment.main.id
}

output "app_public_ip" {
  description = "Public IP of the app VM — SSH and HTTP entry point"
  value       = module.compute.app_public_ip
}

output "db_private_ip" {
  description = "Private IP of the DB VM (reachable only from within the VCN)"
  value       = module.compute.db_private_ip
}

output "ssh_app" {
  description = "SSH command for the app VM"
  value       = "ssh opc@${module.compute.app_public_ip}"
}

output "ssh_db_via_app" {
  description = "SSH to DB VM via app VM (jump host)"
  value       = "ssh -J opc@${module.compute.app_public_ip} opc@${module.compute.db_private_ip}"
}

output "jdbc_url" {
  description = "JDBC URL to use in your Quarkus application.properties"
  value       = "jdbc:postgresql://${module.compute.db_private_ip}:5432/${var.db_name}"
}

output "object_storage_namespace" {
  description = "Tenancy namespace — use this for OCIR_NAMESPACE"
  value       = data.oci_objectstorage_namespace.ns.namespace
}
