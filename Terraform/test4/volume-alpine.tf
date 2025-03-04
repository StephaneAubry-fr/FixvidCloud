resource "libvirt_volume" "alpine" {
  name   = "alpine"
  pool   = "default"
  source = "/home/dadou/W/FixvidCloud/cloud-init/img/nocloud_alpine-3.21.2-x86_64-bios-cloudinit-r0.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "alpine_2" {
  name   = "alpine_2"
  pool   = "default"
  source = "/home/dadou/W/FixvidCloud/cloud-init/img/nocloud_alpine-3.21.2-x86_64-bios-cloudinit-r0.qcow2"
  format = "qcow2"
}