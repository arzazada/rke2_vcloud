variable "domain" {}
variable "username" {}
variable "password" {}
variable "org" {}
variable "vdc" {}
variable "url" {}
variable "hashed_pass" {}
variable "token_secret_key" {}
variable "vcd_network_direct_name" {}

variable "ansible_password" {
  sensitive = true
}

variable "cluster_cidr" {
  default = "10.253.0.0/16"
}

variable "service_cidr" {
  default = "10.254.0.0/16"
}

variable "vcd_gw_ip" {
  default = "10.0.209.254/24"
}

variable "vcd_cidr" {
  default = "10.0.209.0/24"
}