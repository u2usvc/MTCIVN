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
