resource "vcd_catalog" "devops-catalog" {
  name             = "devops-catalog"
  description      = "DevOps unit catalog for ova"
  delete_recursive = true
  delete_force     = true

    provisioner "local-exec" {
      command = <<EOT
        if [ ! -f "${path.root}/files/ova/${var.ubuntu_variant}-server-cloudimg-amd64.ova" ]; then
          curl -o "${path.root}/files/ova/${var.ubuntu_variant}-server-cloudimg-amd64.ova" '${local.ova_url}'
        fi
      EOT
    }
}

resource "vcd_catalog_vapp_template" "ubuntu-focal" {
  org        = var.org 
  catalog_id = vcd_catalog.devops-catalog.id

  name              = "ubuntu-focal"
  description       = "ubuntu-focal"
  ova_path          = "${path.root}/files/ova/${var.ubuntu_variant}-server-cloudimg-amd64.ova"
  upload_piece_size = 10

  metadata_entry {
    key         = "license"
    value       = "public"
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }

  metadata_entry {
    key         = "owner"
    value       = "DevOps unit"
    type        = "MetadataStringValue"
    user_access = "READWRITE"
    is_system   = false
  }
}