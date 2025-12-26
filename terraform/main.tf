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

############ "net" should be an array of networks' host is connected to
variable "domain_map" {
  default = {
    "R07_MT_AS6200_111-2_121-1"             = { net = ["L-111", "L-121"], vol_index = 0, ip = ["10.11.11.12", "10.11.21.11"], cidr = ["10.11.11.0/24", "10.11.21.0/24"] },
    "R06_MT_AS6200_112-2_122-1"             = { net = ["L-112", "L-122"], vol_index = 1, ip = ["10.11.12.12", "10.11.22.11"], cidr = ["10.11.12.0/24", "10.11.22.0/24"] },
    "R08_MT_AS6200_113-2_132-1"             = { net = ["L-113", "L-132"], vol_index = 2, ip = ["10.11.13.12", "10.11.32.11"], cidr = ["10.11.13.0/24", "10.11.32.0/24"] },
    "R09_MT_AS6200_114-2_131-1"             = { net = ["L-114", "L-131"], vol_index = 3, ip = ["10.11.14.12", "10.11.31.11"], cidr = ["10.11.14.0/24", "10.11.31.0/24"] },
    "R05_MT_AS6200_111-1_112-1_113-1_114-1" = { net = ["L-111", "L-112", "L-113", "L-114"], vol_index = 4, ip = ["10.11.11.11", "10.11.12.11", "10.11.13.11", "10.11.14.11"], cidr = ["10.11.11.0/24", "10.11.12.0/24", "10.11.13.0/24", "10.11.14.0/24"] },
    "R03_MT_AS6200_121-2_122-2"             = { net = ["L-121", "L-122"], vol_index = 5, ip = ["10.11.21.12", "10.11.22.12"], cidr = ["10.11.21.0/24", "10.11.22.0/24"] },
    "R04_MT_AS6200_131-2_132-2"             = { net = ["L-131", "L-132"], vol_index = 6, ip = ["10.11.31.12", "10.11.32.12"], cidr = ["10.11.31.0/24", "10.11.32.0/24"] }
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
