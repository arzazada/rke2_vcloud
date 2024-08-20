resource "vcd_vapp_vm" "haproxy_lb" {
  count            = local.ha_enabled ? 1 : 0
  name             = "${var.env}-cp-lb"
  computer_name    = "${var.env}-cp-lb"
  vapp_name        = vcd_vapp.rke2_cluster.name
  vapp_template_id = vcd_catalog_vapp_template.ubuntu-focal.id
  memory           = var.haproxy_lb_memory
  cpus             = var.haproxy_lb_cpus
  cpu_cores        = var.haproxy_lb_cpu_cores

  guest_properties = {
    "user-data" = base64encode(templatefile("${path.root}/files/userdata/haproxy-lb.yml.tpl", {
      master_endpoints = local.master_endpoints
      worker_endpoints = local.worker_endpoints
      env                  = var.env
      hashed_pass          = var.hashed_pass
    }))
    "local-hostname" = "${var.env}-cp-lb"
  }

  lifecycle {
    ignore_changes = [
      guest_properties["user-data"],
      override_template_disk,
      vapp_template_id
    ]
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.org_network.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.cp_lb_ip
    is_primary         = true
  }

  override_template_disk {
    bus_number      = 0
    bus_type        = "paravirtual"
    size_in_mb      = 102400
    unit_number     = 0
    storage_profile = var.storage_profile
  }

  metadata_entry {
    key         = "environment"
    value       = var.env
    type        = "MetadataStringValue"
    is_system   = false
    user_access = "READWRITE"
  }

  metadata_entry {
    key         = "owner"
    value       = "DevOps"
    type        = "MetadataStringValue"
    is_system   = false
    user_access = "READWRITE"
  }

}