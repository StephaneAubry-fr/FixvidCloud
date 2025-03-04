output "name" {
  value = var.name
}

output "ip" {
  value = split("/", var.address)[0]
}