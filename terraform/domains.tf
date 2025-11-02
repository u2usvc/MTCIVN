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
    # e.g. { "L-111" = "10.11.11.11", "L-112" = "10.11.12.11", ... }
    for_each = zipmap(each.value.net, each.value.ip)
    content {
      network_id = libvirt_network.links[network_interface.key].id
      addresses  = [network_interface.value]
      # because some nodes have multiple addresses assigned
      # and by default MT-CHR only has dhcp-client on ether1 
      # by default if wait_for_lease is set to `true` it will 
      # result in an indefinite domain creation
      wait_for_lease = false
    }
  }
}

