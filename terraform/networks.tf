locals {
  # leave only unique "net" (i.e. L-111, L-112, L-113)
  network_ids = distinct(flatten([
    for d in values(var.domain_map) : d.net
  ]))

  # Create a map of ONLY the primary networks (index 0) to their respective CIDR.
  # The `...` handles duplicates (e.g., if two routers share L-111 as a primary link).
  primary_network_cidrs = {
    for d in values(var.domain_map) : d.net[0] => d.cidr...
  }
}

resource "libvirt_network" "links" {
  for_each = toset(local.network_ids)

  name   = each.key
  mode   = "none"
  bridge = "mtbr${replace(each.key, "L-", "")}"

  # If this network exists in our primary networks map, assign its CIDR.
  # Otherwise, pass `null` to leave it as a pure L2 bridge.
  addresses = contains(keys(local.primary_network_cidrs), each.key) ? [local.primary_network_cidrs[each.key][0]] : null

  # Only render the DHCP block if this network has a CIDR assigned.
  dynamic "dhcp" {
    for_each = contains(keys(local.primary_network_cidrs), each.key) ? [1] : []
    content {
      enabled = true
    }
  }

  xml {
    xslt = file("net_transform.xsl")
  }
}
