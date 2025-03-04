resource "libvirt_network" "test" {
  name = "network-test"
  addresses = ["10.0.1.0/24"]
  mode = "nat"
  dhcp {
    enabled = false
  }
}
