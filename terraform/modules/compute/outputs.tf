output "app_public_ip"  { value = oci_core_instance.app.public_ip }
output "db_private_ip"  { value = oci_core_instance.db.private_ip }
output "app_vm_id"      { value = oci_core_instance.app.id }
output "db_vm_id"       { value = oci_core_instance.db.id }
