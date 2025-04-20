terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

#################################
### Providers
#################################
provider "libvirt" {
  uri = "qemu:///system"
}

#################################
### Variables
#################################
variable "hosts" {
  default = 5
}

variable "hostname_format" {
  type    = string
  default = "MT-CHR-%02d"
}

#################################
### Resources
#################################
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
  name             = "${format(var.hostname_format, count.index + 1)}.qcow2"
  count            = var.hosts
  source           = "./images/chr-7.18.2.qcow2"
  pool             = "mtcivn_pool"
  format           = "qcow2"
  depends_on       = [libvirt_pool.mtcivn_pool]
}
