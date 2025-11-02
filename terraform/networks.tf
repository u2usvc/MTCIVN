# locals {
#   # leave only unique "net" (i.e. L-111, L-112, L-113)
#   network_ids = distinct([
#     # extract "net" from each
#     for each in values(var.domain_map) : each.net
#   ])
# }
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

  # key == link-111
  name = each.key
  mode = "none"
  # bridge == mtcivnbr111
  bridge = "mtbr${replace(each.key, "L-", "")}"
  # bridge = replace(each.key, "L-", "mtbr")

  # for initial ip provisioning to hosts for ansible connectivity
  # this block ensures that networks are created with only unique matching CIDRs
  # compact() removes null elements from a list
  # slice(list, start_index, end_index) leaves only specified elements in a list 
  addresses = slice(compact(
    [
      # Access the network configuration based on the net value in the domain_map
      for key, value in var.domain_map :
      # if value.net (var.domain_map.value.net) == each.key (network_ids), then return value.cidr (var.domain_map.value.cidr)
      value.net[0] == each.key ? value.cidr : null
    ]
  ), 0, 1)

  dhcp {
    enabled = true
  }

  xml {
    xslt = file("net_transform.xsl")
  }
}
