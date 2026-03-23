terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

#################
### Providers ###
#################
provider "libvirt" {
  uri = "qemu:///system"
}

#################
### Variables ###
#################
variable "hostname_format" {
  type    = string
  default = "MT-CHR-%02d"
}

variable "domain_map" {
  default = {
    "R07"     = { net = ["L-999", "L-111", "L-121"], vol_index = 0, ip = "192.168.99.107", cidr = "192.168.99.0/24" },
    "R06"     = { net = ["L-999", "L-112", "L-122"], vol_index = 1, ip = "192.168.99.106", cidr = "192.168.99.0/24" },
    "R08"     = { net = ["L-999", "L-113", "L-132"], vol_index = 2, ip = "192.168.99.108", cidr = "192.168.99.0/24" },
    "R09"     = { net = ["L-999", "L-114", "L-131"], vol_index = 3, ip = "192.168.99.109", cidr = "192.168.99.0/24" },
    "R05"     = { net = ["L-999", "L-111", "L-112", "L-113", "L-114"], vol_index = 4, ip = "192.168.99.105", cidr = "192.168.99.0/24" },
    "R03"     = { net = ["L-999", "L-121", "L-122", "L-311", "L-411"], vol_index = 5, ip = "192.168.99.103", cidr = "192.168.99.0/24" },
    "R04"     = { net = ["L-999", "L-131", "L-132", "L-321", "L-421"], vol_index = 6, ip = "192.168.99.104", cidr = "192.168.99.0/24" },

    "R01"     = { net = ["L-999", "L-311", "L-312", "L-313"], vol_index = 7, ip = "192.168.99.101", cidr = "192.168.99.0/24" },
    "R02"     = { net = ["L-999", "L-321", "L-323", "L-322"], vol_index = 8, ip = "192.168.99.102", cidr = "192.168.99.0/24" }

    "R12"     = { net = ["L-999", "L-411"], vol_index = 9, ip = "192.168.99.112", cidr = "192.168.99.0/24" },
    "R13"     = { net = ["L-999", "L-421"], vol_index = 10, ip = "192.168.99.113", cidr = "192.168.99.0/24" }
  }
}

#################
### Resources ###
#################
### POOL
resource "libvirt_pool" "mtcivn_pool" {
  name = "mtcivn_pool"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/mtcivn"
  }
}


### VOLUMES
resource "libvirt_volume" "mt-chr_vol" {
  count      = length(var.domain_map)
  name       = "${format(var.hostname_format, count.index + 1)}.qcow2"
  source     = "./images/chr-7.18.2.qcow2"
  pool       = "mtcivn_pool"
  format     = "qcow2"
  depends_on = [libvirt_pool.mtcivn_pool]
}
