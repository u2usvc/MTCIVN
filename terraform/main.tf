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
variable "hosts" {
  default = 5
}

variable "hostname_format" {
  type    = string
  default = "MT-CHR-%02d"
}

variable "network_ids" {
  default = [
    112, 113, 114,
    121, 122,
    131, 132,
    211,
    221
  ]
}

variable "domain_map" {
  default = {
    "link-112-1" = { net = "link-112", vol_index = 0 },
    "link-112-2" = { net = "link-112", vol_index = 1 },
    "link-113-1" = { net = "link-113", vol_index = 2 },
    "link-113-2" = { net = "link-113", vol_index = 3 },
    # ...
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
