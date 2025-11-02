locals {
  # leave only unique "net" (i.e. L-111, L-112, L-113)
  # flatten merges all recursive list into a flat list 
  # distinct removes duplicates
  network_ids = distinct(flatten([
    for d in values(var.domain_map) : d.net
  ]))
}


resource "libvirt_network" "links" {
  for_each = toset(local.network_ids)

  name   = each.key
  mode   = "none"
  bridge = "mtbr${replace(each.key, "L-", "")}"

  # pick the CIDR that corresponds to this network (as a single string)
  addresses = slice(compact([
    for key, value in var.domain_map :
    contains(value.net, each.key) ? value.cidr[index(value.net, each.key)] : null
  ]), 0, 1)

  dhcp {
    enabled = true
  }

  xml {
    xslt = file("net_transform.xsl")
  }
}
