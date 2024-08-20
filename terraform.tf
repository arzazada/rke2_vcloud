terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "~> 3.10"
    }
  }
#  backend "http" {}
}

provider "vcd" {
  user                 = var.username
  password             = var.password
  org                  = var.org
  vdc                  = var.vdc
  url                  = var.url
  max_retry_timeout    = 60
  allow_unverified_ssl = false
}

