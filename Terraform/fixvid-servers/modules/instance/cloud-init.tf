
data "template_file" "meta_data" {
  template = file("${path.module}/cfg/meta-data")
  vars = {
    name = var.name
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cfg/user-data")
}

data "template_file" "network_config" {
  template = file("${path.module}/cfg/network-config")
  vars = {
    address = var.address
    gateway = var.gateway
  }
}

resource "libvirt_cloudinit_disk" "seed_noble" {
  name            = "seed_noble_${var.name}.iso"
  pool            = var.pool
  meta_data       = data.template_file.meta_data.rendered
  user_data       = data.template_file.user_data.rendered
  network_config  = data.template_file.network_config.rendered
}
