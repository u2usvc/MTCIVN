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

  # network_interface {
  #   network_id = libvirt_network.links[each.value.net].id
  #   addresses  = each.value.ip
  #   wait_for_lease = true
  # }
  #

  dynamic "network_interface" {
    # Iterate directly over the 'net' array to preserve exact order
    for_each = each.value.net

    content {
      # network_interface.value is the network name (e.g., "L-323")
      network_id = libvirt_network.links[network_interface.value].id

      # network_interface.key is the index (e.g., 0). 
      # We use it to grab the matching IP from the 'ip' array!
      addresses  = [each.value.ip[network_interface.key]]

      # because some nodes have multiple addresses assigned
      # and by default MT-CHR only has dhcp-client on ether1 
      # by default if wait_for_lease is set to `true` it will 
      # result in an indefinite domain creation
      wait_for_lease = false
    }
  }
}

