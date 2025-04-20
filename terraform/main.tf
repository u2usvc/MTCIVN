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
  pool             = "fcos_k8s_lab_pool"
  format           = "qcow2"
  depends_on       = [libvirt_pool.mtcivn_pool]
}


### DOMAIN
resource "libvirt_domain" "mt-ros" {
  count  = var.hosts
  name   = format(var.hostname_format, count.index + 1)
  # vcpu =
  # memory =

  cpu {
      mode = "host-passthrough"
    }

  coreos_ignition = element(libvirt_ignition.ignition.*.id, count.index)

  disk {
    volume_id = element(libvirt_volume.coreos-disk.*.id, count.index)
  }

  # Makes the tty0 available via `virsh console`
  console {
    type = "pty"
    target_port = "0"
  }

  network_interface {
    network_name   = "fcos_k8s_lab"
    wait_for_lease = true
    mac            = element(var.mac_addresses, count.index)
  }
}

### NETWORK
resource "libvirt_network" "fcos_k8s_lab" {
  name      = "fcos_k8s_lab"
  mode      = "nat"
  bridge    = "k8sbr0"
  domain    = "k8s.local"
  addresses = ["192.168.122.0/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
    forwarders {
      address = "1.1.1.1"
    }
  }
}
