terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.1"
    }
  }
}

////
resource "libvirt_domain" "instance" {
  name   = var.name
  disk {
    volume_id = libvirt_volume.noble.id
  }
  network_interface {
    network_name = var.network
  }
  memory = var.memory
  vcpu   = var.cpu
  cloudinit = libvirt_cloudinit_disk.seed_noble.id
}