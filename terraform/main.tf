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
    "R07_MT_AS6200_111-2_121-1"             = { net = ["L-999", "L-111", "L-121"], vol_index = 0, ip = "192.168.99.107", cidr = "192.168.99.0/24" },
    "R06_MT_AS6200_112-2_122-1"             = { net = ["L-999", "L-112", "L-122"], vol_index = 1, ip = "192.168.99.106", cidr = "192.168.99.0/24" },
    "R08_MT_AS6200_113-2_132-1"             = { net = ["L-999", "L-113", "L-132"], vol_index = 2, ip = "192.168.99.108", cidr = "192.168.99.0/24" },
    "R09_MT_AS6200_114-2_131-1"             = { net = ["L-999", "L-114", "L-131"], vol_index = 3, ip = "192.168.99.109", cidr = "192.168.99.0/24" },
    "R05_MT_AS6200_111-1_112-1_113-1_114-1" = { net = ["L-999", "L-111", "L-112", "L-113", "L-114"], vol_index = 4, ip = "192.168.99.105", cidr = "192.168.99.0/24" },
    "R03_MT_AS6200_121-2_122-2_311-x"       = { net = ["L-999", "L-121", "L-122", "L-311"], vol_index = 5, ip = "192.168.99.103", cidr = "192.168.99.0/24" },
    "R04_MT_AS6200_131-2_132-2_321-x"       = { net = ["L-999", "L-131", "L-132", "L-321"], vol_index = 6, ip = "192.168.99.104", cidr = "192.168.99.0/24" },
    "R01_MT_AS6200_311-1_312-1_313-1"       = { net = ["L-999", "L-311", "L-312", "L-313"], vol_index = 7, ip = "192.168.99.101", cidr = "192.168.99.0/24" },
    "R02_MT_AS6200_323-1_321-2_322-1"       = { net = ["L-999", "L-323", "L-321", "L-322"], vol_index = 8, ip = "192.168.99.102", cidr = "192.168.99.0/24" }
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
