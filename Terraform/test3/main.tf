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


//Instance
resource "libvirt_domain" "alpine_test" {
  name   = "alpine_test"

  disk {
    volume_id = libvirt_volume.alpine.id
  }

  network_interface {
    network_name = "test-dhcp"
    wait_for_lease = true
    mac = "52:54:00:20:3f:03"
  }

  memory = 1024
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.seed_test.id
}

# resource "libvirt_domain" "alpine_test_2" {
#   name   = "alpine_test_2"
#
#   disk {
#     volume_id = libvirt_volume.alpine_2.id
#   }
#
#   network_interface {
#     network_name = "default"
#     wait_for_lease = true
#   }
#
#   memory = 1024
#   vcpu   = 1
#   cloudinit = libvirt_cloudinit_disk.seed_test.id
# }

resource "libvirt_domain" "noble_test" {
  name   = "noble_test"

  disk {
    volume_id = libvirt_volume.noble.id
  }

  network_interface {
    network_name = "test-dhcp"
    wait_for_lease = true
    mac = "52:54:00:20:3f:02"
  }

  memory = 1024
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.seed_test.id
}

////

# output "ip_noble" {
#   value = libvirt_domain.noble_test.network_interface[0].addresses[0]
# }

# output "ip_alpine" {
#   value = libvirt_domain.alpine_test.network_interface[0].addresses[0]
# }

# output "ip_alpine_2" {
#   value = libvirt_domain.alpine_test_2.network_interface[0].addresses[0]
# }
