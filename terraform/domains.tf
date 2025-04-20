resource "libvirt_domain" "mt_ros" {
  for_each = var.domain_map

  name = each.key

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.mt-chr_vol[each.value.vol_index].id
  }

  console {
    type = "pty"
    target_port = "0"
  }

  network_interface {
    network_id = libvirt_network.links[each.value.net].id
  }
}
