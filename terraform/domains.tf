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

