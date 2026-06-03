# ─── App VM (public subnet) ───────────────────────────────────────────────────
resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-app"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  freeform_tags       = var.tags

  shape_config {
    ocpus         = var.app_ocpus
    memory_in_gbs = var.app_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = var.arm_image_id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = var.public_subnet_id
    assign_public_ip = true
    nsg_ids          = [var.app_nsg_id]
    hostname_label   = "${var.project_name}-app"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("${path.module}/cloud-init/app.yaml"))
  }

  timeouts {
    create = "20m"
  }
}

# ─── DB VM (private subnet) ───────────────────────────────────────────────────
resource "oci_core_instance" "db" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-db"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  freeform_tags       = var.tags

  shape_config {
    ocpus         = var.db_ocpus
    memory_in_gbs = var.db_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = var.arm_image_id
    boot_volume_size_in_gbs = 100
  }

  create_vnic_details {
    subnet_id        = var.private_subnet_id
    assign_public_ip = false
    nsg_ids          = [var.db_nsg_id]
    hostname_label   = "${var.project_name}-db"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("${path.module}/cloud-init/db.yaml"))
  }

  timeouts {
    create = "20m"
  }
}

# ─── Data sources ─────────────────────────────────────────────────────────────
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
