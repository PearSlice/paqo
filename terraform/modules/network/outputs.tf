output "public_subnet_id"  { value = oci_core_subnet.public.id }
output "private_subnet_id" { value = oci_core_subnet.private.id }
output "app_nsg_id"        { value = oci_core_network_security_group.app.id }
output "db_nsg_id"         { value = oci_core_network_security_group.db.id }
