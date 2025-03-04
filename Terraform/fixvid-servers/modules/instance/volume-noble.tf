resource "libvirt_volume" "noble" {
  name             = "noble-${var.name}"
  pool             = var.pool
  base_volume_pool = var.basepool
  size             = var.size * 1024 * 1024 * 1024
  base_volume_name = "noble-server-cloudimg-amd64.img"
  format           = "qcow2"

}