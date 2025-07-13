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

############ "cidr" can be *any of* the networks' host is connected to (should match CIDR of the first network in the "net" array)
############ "net" should be an array of networks' host is connected to
#                                                     L-2 34 -2
# "L-234-2" = { net = "L-234", vol_index = X, ip = "10.12.34.12", cidr = "10.12.34.0/24" },
# "L-345-1" = { net = "L-345", vol_index = X, ip = "10.13.45.11", cidr = "10.13.45.0/24" },
variable "domain_map" {
  default = {
    "L-111-2" = { net = ["L-111"], vol_index = 0, ip = ["10.11.11.12"], cidr = "10.11.11.0/24" },
    "L-112-2" = { net = ["L-112"], vol_index = 1, ip = ["10.11.12.12"], cidr = "10.11.12.0/24" },
    "L-113-2" = { net = ["L-113"], vol_index = 2, ip = ["10.11.13.12"], cidr = "10.11.13.0/24" },
    "L-114-2" = { net = ["L-114"], vol_index = 3, ip = ["10.11.14.12"], cidr = "10.11.14.0/24" },
    "L-111_2_3_4-1" = { net = ["L-111","L-112","L-113","L-114"], vol_index = 4, ip = ["10.11.11.11","10.11.12.11","10.11.13.11","10.11.14.11"], cidr = "10.11.11.0/24" },

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
  count       = length(var.domain_map)
  name        = "${format(var.hostname_format, count.index + 1)}.qcow2"
  source      = "./images/chr-7.18.2.qcow2"
  pool        = "mtcivn_pool"
  format      = "qcow2"
  depends_on  = [libvirt_pool.mtcivn_pool]
}
