variable "db_vm_id" { type = string }
variable "db_private_ip" { type = string }
variable "app_public_ip" { type = string }
variable "ssh_private_key_path" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
