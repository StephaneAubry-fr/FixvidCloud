terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.1"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}
////////////////////////////////////
/*resource "libvirt_network" "network_test" {
  name = "networktest"
  addresses = ["10.0.1.0/24"]
  mode = "nat"
  dhcp {
    enabled = false
  }
}*/

////////////////////////////////////
// Main image
resource "libvirt_volume" "alpine" {
  name   = "alpine"
  pool   = "default"
  source = "/home/dadou/W/FixvidCloud/cloud-init/img/noble-server-cloudimg-amd64.img"
  //source = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/cloud/nocloud_alpine-3.21.2-x86_64-bios-cloudinit-r0.qcow2"
  //source = "/home/dadou/W/FixvidCloud/cloud-init/img/nocloud_alpine-3.21.2-x86_64-bios-cloudinit-r0.qcow2"
  //source = "/home/dadou/W/FixvidCloud/cloud-init/img/nocloud_alpine-3.19.6-x86_64-bios-cloudinit-r0.qcow2"
  format = "qcow2"
}

//cloud-init
/*
data "template_file" "meta_data" {
  template = file("${path.module}/cfg/meta-data")
  vars = {
    name = "test"
  }
}
*/

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
  //meta_data       = data.template_file.meta_data.rendered
  user_data       = data.template_file.user_data.rendered
  //network_config  = data.template_file.network_config.rendered
}

////
//Instance
resource "libvirt_domain" "instance_test" {
  name   = "instance_test"

  disk {
    volume_id = libvirt_volume.alpine.id
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  memory = 1024
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.seed_test.id

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type ="spice"
    listen_type = "address"
    autoport = true
  }
}

output "ip" {
  value = libvirt_domain.instance_test.network_interface[0].addresses[0]
}

