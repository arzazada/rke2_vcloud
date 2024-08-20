variable "domain" {}
variable "cp_lb_ip" {}
variable "cluster_cidr" {}
variable "hashed_pass" {}
variable "service_cidr" {}
variable "env" {}
variable "org" {}
variable "org_network_name" {}
variable "master_ip_range" {}
variable "worker_ip_range" {}
variable "token_secret_key" {}
variable "master_node_count" {}
variable "worker_node_count" {}
variable "storage_profile" {}
variable "ha_enabled" {
  default = true
}

variable "ansible_user" {
  default = "ci-user"
}

variable "ansible_password" {
  sensitive = true
}

variable "ubuntu_variant" {}

variable "master_node_cpus" {
  default = 4
}

variable "master_node_memory" {
  default = 8192
}

variable "master_node_cpu_cores" {
  default = 1
}

variable "master_node_disk_size" {
  default = 40960
}

variable "worker_node_cpus" {
  default = 7
}

variable "worker_node_memory" {
  default = 14336
}

variable "worker_node_cpu_cores" {
  default = 1
}

variable "worker_node_disk_size" {
  default = 61440
}


variable "haproxy_lb_cpus" {
  default = 2
}

variable "haproxy_lb_memory" {
  default = 4096
}

variable "haproxy_lb_cpu_cores" {
  default = 1
}


