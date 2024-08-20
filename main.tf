module "rke2-prod-cluster" {
  source = "./modules/rke2cluster"
  env    = "prod"
  org    = var.org
  domain = var.domain

  ha_enabled            = false
  hashed_pass           = var.hashed_pass
  cluster_cidr          = var.cluster_cidr
  service_cidr          = var.service_cidr
  ansible_password      = var.ansible_password
  token_secret_key      = var.token_secret_key
  org_network_name      = var.vcd_network_direct_name

  master_node_count     = 3
  worker_node_count     = 1

  master_node_cpus      = 4
  master_node_memory    = 8192
  master_node_disk_size = 40960

  worker_node_cpus      = 8
  worker_node_memory    = 14336
  worker_node_disk_size = 61440

  ubuntu_variant  = "focal"
  storage_profile = "Premium-Endurance-01"
  cp_lb_ip        = cidrhost(var.vcd_cidr, 10)
  master_ip_range = [for i in range(11, 19) : cidrhost(var.vcd_cidr, i)]
  worker_ip_range = [for i in range(21, 29) : cidrhost(var.vcd_cidr, i)]
}