# This module runs a one-time SQL setup script on the DB VM after provisioning.
# It creates the application database and user via SSH + psql.
#
# Prerequisites: the SSH agent must have your private key loaded, or
# set TF_VAR_ssh_private_key_path and adjust the connection block below.

resource "null_resource" "pg_setup" {
  triggers = {
    db_vm_id = var.db_vm_id
    db_name  = var.db_name
    db_user  = var.db_user
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for cloud-init to fully complete before doing anything
      "sudo cloud-init status --wait",

      # Wait for PostgreSQL to be ready (up to 5 min)
      "echo 'Waiting for PostgreSQL...'",
      "for i in $(seq 1 30); do pg_isready -h localhost -U postgres && break || sleep 10; done",
      "pg_isready -h localhost -U postgres || (echo 'PostgreSQL did not start in time' && exit 1)",

      # Create user idempotently
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_roles WHERE rolname='${var.db_user}'\" | grep -q 1 || sudo -u postgres psql -c \"CREATE USER ${var.db_user} WITH PASSWORD '${var.db_password}';\"",

      # Create DB idempotently
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_database WHERE datname='${var.db_name}'\" | grep -q 1 || sudo -u postgres createdb -O ${var.db_user} ${var.db_name}",

      # Grant permissions
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${var.db_name} TO ${var.db_user};\"",
      "sudo -u postgres psql -d ${var.db_name} -c \"GRANT ALL ON SCHEMA public TO ${var.db_user};\"",

      "echo 'PostgreSQL setup complete.'"
    ]

    connection {
      type        = "ssh"
      user        = "opc"
      host        = var.db_private_ip
      private_key = file(var.ssh_private_key_path)

      # Timeouts — fail fast instead of hanging forever
      timeout = "10m"
      agent   = false

      # Jump through app VM since DB is in private subnet
      bastion_host        = var.app_public_ip
      bastion_user        = "opc"
      bastion_private_key = file(var.ssh_private_key_path)
      bastion_port        = 22
    }
  }
}
