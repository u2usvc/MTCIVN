# resource "libvirt_network" "link-111" {
#   name      = "link-111"
#   mode      = "none"
#   bridge    = "mtcivnbr111"
# }

resource "libvirt_network" "links" {
  for_each = {
    for id in var.network_ids : "link-${id}" => id
  }

  name   = each.key
  mode   = "none"
  bridge = "mtcivnbr${each.value}"
}

