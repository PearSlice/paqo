# This module runs a one-time SQL setup script on the DB VM after provisioning.
# It creates the application database and user via SSH + psql.
#
# Prerequisites: the SSH agent must have your private key loaded, or
# set TF_VAR_ssh_private_key_path and adjust the connection block below.

resource "null_resource" "pg_setup" {
  # Re-run if any of these change
  triggers = {
    db_vm_id    = var.db_vm_id
    db_name     = var.db_name
    db_user     = var.db_user
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for PostgreSQL to be fully up
      "until pg_isready -h localhost -U postgres; do sleep 2; done",

      # Create DB and user idempotently
      "sudo -u postgres psql -c \"SELECT 1 FROM pg_roles WHERE rolname='${var.db_user}'\" | grep -q 1 || sudo -u postgres psql -c \"CREATE USER ${var.db_user} WITH PASSWORD '${var.db_password}';\"",
      "sudo -u postgres psql -c \"SELECT 1 FROM pg_database WHERE datname='${var.db_name}'\" | grep -q 1 || sudo -u postgres createdb -O ${var.db_user} ${var.db_name}",
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${var.db_name} TO ${var.db_user};\"",
      "sudo -u postgres psql -d ${var.db_name} -c \"GRANT ALL ON SCHEMA public TO ${var.db_user};\"",

      "echo 'PostgreSQL setup complete.'"
    ]

    connection {
      type        = "ssh"
      user        = "opc"
      host        = var.db_private_ip
      private_key = file(var.ssh_private_key_path)

      # Tunnel through the app VM since the DB is in the private subnet
      bastion_host        = var.app_public_ip
      bastion_user        = "opc"
      bastion_private_key = file(var.ssh_private_key_path)
    }
  }
}
