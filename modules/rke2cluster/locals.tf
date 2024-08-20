locals {

  ova_url = "https://cloud-images.ubuntu.com/${var.ubuntu_variant}/current/${var.ubuntu_variant}-server-cloudimg-amd64.ova"


  master_endpoints = slice(var.master_ip_range, 0, var.master_node_count)


  worker_endpoints = slice(var.worker_ip_range, 0, var.worker_node_count)

  #
# master_endpoints =  local.master_endpoints #  concat(local.master_endpoints, local.master_endpoints_az3, local.master_endpoints_az2)
  #    worker_endpoints = concat(local.worker_endpoints, local.worker_endpoints_az3)
  #    all_endpoints = concat(local.master_endpoints, local.worker_endpoints, [var.app_lb_ip], var.env == "prod" ?
  #    [var.app_lb_ip_az3, var.cp_lb_ip, "10.0.211.3", "10.0.211.4"] : []) # included standalone hosts ( except vcs )

  ha_enabled = var.master_node_count > 1 && var.ha_enabled

  #    prod_app_lb_ip = var.env == "prod" ? var.app_lb_ip : var.prod_lb_ip
  #    prod_app_lb_ip_az3 = var.env == "prod" ? var.app_lb_ip_az3 : var.prod_lb_ip_az3
  #

}

#
#locals {
#
#  ova_url = "https://cloud-images.ubuntu.com/${var.ubuntu_variant}/current/${var.ubuntu_variant}-server-cloudimg-amd64.ova"
#
#
#  master_endpoints = slice(var.master_ip_range, 0, var.master_node_count)
#
#
#  worker_endpoints = slice(var.worker_ip_range, 0, var.worker_node_count)
#
#  #
#  #    master_endpoints = concat(local.master_endpoints, local.master_endpoints_az3, local.master_endpoints_az2)
#  #    worker_endpoints = concat(local.worker_endpoints, local.worker_endpoints_az3)
#  #    all_endpoints = concat(local.master_endpoints, local.worker_endpoints, [var.app_lb_ip], var.env == "prod" ?
#  #    [var.app_lb_ip_az3, var.cp_lb_ip, "10.0.211.3", "10.0.211.4"] : []) # included standalone hosts ( except vcs )
#
#  ha_enabled = var.master_node_count > 1 && var.multi_az == false || var.multi_az
#
#  #    prod_app_lb_ip = var.env == "prod" ? var.app_lb_ip : var.prod_lb_ip
#  #    prod_app_lb_ip_az3 = var.env == "prod" ? var.app_lb_ip_az3 : var.prod_lb_ip_az3
#  #
#
#}