variable "name" {}
variable "network" {}
variable "address" {}
variable "gateway" {}
variable "pool" {}
variable "basepool" {}
variable "size" {
    default = null
}

variable "cpu" {
    type    = string
    default = 1
}
variable "memory" {
    type    = string
    default = 1024
}
