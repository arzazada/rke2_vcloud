resource "vcd_vapp" "rke2_cluster" {
  name = "${var.env}-rke2-cluster"
}

resource "vcd_vapp_org_network" "org_network" {
  org_network_name = var.org_network_name
  vapp_name        = vcd_vapp.rke2_cluster.name
}

resource "vcd_vapp_vm" "control_plane" {
  depends_on       = [null_resource.ansible_haproxy_config]
  count            = var.master_node_count
  name             = "${var.env}-master-node-${count.index + 1}"
  computer_name    = "${var.env}-master-node-${count.index + 1}"
  vapp_name        = vcd_vapp.rke2_cluster.name
  vapp_template_id = vcd_catalog_vapp_template.ubuntu-focal.id
  memory           = var.master_node_memory
  cpus             = var.master_node_cpus
  cpu_cores        = var.master_node_cpu_cores

  guest_properties = {
    "user-data" = count.index == 0 ? base64encode(templatefile("${path.root}/files/userdata/master-node-init.yml.tpl", {
      master_endpoints = local.master_endpoints
      worker_endpoints = local.worker_endpoints
      lb_ip            = local.ha_enabled ? var.cp_lb_ip : var.master_ip_range[0]
      domain           = var.domain
      env              = var.env
      token_secret_key = var.token_secret_key
      service_cidr     = var.service_cidr
      cluster_cidr     = var.cluster_cidr
      hashed_pass      = var.hashed_pass
      })) : base64encode(templatefile("${path.root}/files/userdata/master-node.yml.tpl", {
      master_endpoints = local.master_endpoints
      worker_endpoints = local.worker_endpoints
      lb_ip            = local.ha_enabled ? var.cp_lb_ip : var.master_ip_range[0]
      domain           = var.domain
      env              = var.env
      token_secret_key = var.token_secret_key
      service_cidr     = var.service_cidr
      cluster_cidr     = var.cluster_cidr
      hashed_pass      = var.hashed_pass
    }))
    "local-hostname" = "${var.env}-master-node-${count.index + 1}"
  }

  lifecycle {
    ignore_changes = [guest_properties["user-data"]]
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.org_network.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.master_ip_range[count.index]
    is_primary         = true
  }

  override_template_disk {
    bus_number      = 0
    bus_type        = "paravirtual"
    size_in_mb      = var.master_node_disk_size
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






resource "vcd_vapp_vm" "worker_nodes" {
  depends_on = [
    vcd_vapp_vm.control_plane[0],
  ]
  count            = var.worker_node_count
  name             = "${var.env}-worker-node-${count.index + 1}"
  computer_name    = "${var.env}-worker-node-${count.index + 1}"
  vapp_name        = vcd_vapp.rke2_cluster.name
  vapp_template_id = vcd_catalog_vapp_template.ubuntu-focal.id
  memory           = var.worker_node_memory
  cpus             = var.worker_node_cpus
  cpu_cores        = var.worker_node_cpu_cores


  guest_properties = {
    "user-data" = base64encode(templatefile("${path.root}/files/userdata/worker-node.yml.tpl", {
      master_endpoints = local.master_endpoints
      worker_endpoints = local.worker_endpoints
      lb_ip            = local.ha_enabled ? var.cp_lb_ip : var.master_ip_range[0] #var.master_ip_range [0] #
      domain           = var.domain
      env              = var.env
      token_secret_key = var.token_secret_key
      hashed_pass      = var.hashed_pass
    }))
    "local-hostname" = "worker-node-${count.index + 1}"
  }


  network {
    type               = "org"
    name               = vcd_vapp_org_network.org_network.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.worker_ip_range[count.index]
    is_primary         = true
  }

  override_template_disk {
    bus_number      = 0
    bus_type        = "paravirtual"
    size_in_mb      = var.worker_node_disk_size
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
