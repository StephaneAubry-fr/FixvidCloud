
#################################################################
## common
data "template_file" "meta_data" {
  template = file("${path.module}/cfg/meta-data")
  vars = {
    name = "test"
  }
}

#################################################################
## alpine
data "template_file" "user_data_alpine" {
  //template = file("${path.module}/cfg/${var.name}-user-data")
  template = file("${path.module}/cfg/alpine/user-data")
}

# data "template_file" "network_config_alpine_test1" {
#   template = file("${path.module}/cfg/alpine/network-config-test1")
# }

resource "libvirt_cloudinit_disk" "seed_alpine_test1" {
  name            = "seed_alpine_test1.iso"
  meta_data       = data.template_file.meta_data.rendered
  user_data       = data.template_file.user_data_alpine.rendered
  #network_config  = data.template_file.network_config_alpine_test1.rendered
}
#################################################################
## Ubuntu noble


data "template_file" "user_data_noble" {
  //template = file("${path.module}/cfg/${var.name}-user-data")
  template = file("${path.module}/cfg/noble/user-data")
}

data "template_file" "network_config_test1" {
  template = file("${path.module}/cfg/noble/network-config-test1")
}

resource "libvirt_cloudinit_disk" "seed_noble_test1" {
  name            = "seed_noble_test1.iso"
  meta_data       = data.template_file.meta_data.rendered
  user_data       = data.template_file.user_data_noble.rendered
  network_config  = data.template_file.network_config_test1.rendered
}