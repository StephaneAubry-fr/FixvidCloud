resource "libvirt_volume" "noble" {
  name   = "noble"
  pool   = "default"
  source = "/home/dadou/W/FixvidCloud/cloud-init/img/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}