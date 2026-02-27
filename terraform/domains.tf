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
    type        = "pty"
    target_port = "0"
  }

  dynamic "network_interface" {
    for_each = each.value.net

    content {
      # network_interface.value is the network name
      network_id = libvirt_network.links[network_interface.value].id

      # network_interface.key is the index (0, 1, 2, etc.)
      # We only assign the IP if this is the first network (index 0). 
      # Passing `null` tells Terraform to omit this attribute entirely for other interfaces.
      addresses  = network_interface.key == 0 ? [each.value.ip] : null

      wait_for_lease = false
    }
  }
}
