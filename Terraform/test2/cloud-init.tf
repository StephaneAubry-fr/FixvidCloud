//cloud-init
data "template_file" "meta_data" {
  template = file("${path.module}/cfg/meta-data")
  vars = {
    name = "test"
  }
}


data "template_file" "user_data" {
  //template = file("${path.module}/cfg/${var.name}-user-data")
  template = file("${path.module}/cfg/user-data")
}

/*
data "template_file" "network_config" {
  template = file("${path.module}/cfg/network-config")
  vars = {
    ip = "10.0.1.5"
  }
}
*/


resource "libvirt_cloudinit_disk" "seed_test" {
  name            = "seed_test.iso"
  meta_data       = data.template_file.meta_data.rendered
  user_data       = data.template_file.user_data.rendered
  //network_config  = data.template_file.network_config.rendered
}