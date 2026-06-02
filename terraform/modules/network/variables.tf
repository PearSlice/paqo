variable "compartment_ocid" { type = string }
variable "project_name"     { type = string }
variable "vcn_cidr"         { type = string }
variable "public_subnet_cidr"  { type = string }
variable "private_subnet_cidr" { type = string }
variable "tags"             { type = map(string) }
