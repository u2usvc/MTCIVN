locals {
  network_ids = distinct([
    for each in values(var.domain_map) : each.net
  ])
}

resource "libvirt_network" "links" {
  for_each = toset(local.network_ids)

  # key == link-111
  name   = each.key
  mode   = "none"
  # bridge == mtcivnbr111
  bridge = replace(each.key, "link-", "mtcivnbr")
}
