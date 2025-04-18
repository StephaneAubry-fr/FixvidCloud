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

///////////////////////

variable "ssh_user" {}
variable "ssh_key" {}

locals {
  env = terraform.workspace
}
///////////////////////
// img pool

// basepool "local-base-img" manually managed

resource "libvirt_pool" "local-kvm-img" {
  name = "local-kvm-img-${local.env}"
  type = "dir"
  target {
    path = "/home/dadou/W/images/local-kvm-img-${local.env}"
  }
}
///////////////////////
// workspace
locals {

  envpool     = libvirt_pool.local-kvm-img.name
  envbasepool = "local-base-img"
  net = {
    default = "10.0.1"
    dev     = "10.0.2"
    qa      = "10.0.3"
    prod    = "10.0.5"
  }
  subnet  = lookup(local.net,local.env)
  gateway = "${local.subnet}.1"
}

///////////////////////
// network

resource "libvirt_network" "fixvid-net" {
  name = "fixvid-${local.env}"
  addresses = ["${local.subnet}.0/24"]
  mode = "nat"
  dhcp {
    enabled = false
  }
}

///////////////////////
// VM
module "devops" {
  source    = "../fixvid-modules/instance"
  name      = "devops-${local.env}"
  cpu       = 4
  memory    = 8*1024
  size      = 15
  address   = "${local.subnet}.10/24"
  gateway   = local.gateway
  pool      = local.envpool
  basepool  = local.envbasepool
  network   = libvirt_network.fixvid-net.name
}

module "toolbox" {
  source    = "../fixvid-modules/instance"
  name      = "toolbox-${local.env}"
  memory    = 512
  size      = 5
  address   = "${local.subnet}.11/24"
  gateway   = local.gateway
  pool      = local.envpool
  basepool  = local.envbasepool
  network   = libvirt_network.fixvid-net.name
  }

module "demo1" {
  source    = "../fixvid-modules/instance"
  name      = "demo-1-${local.env}"
  memory    = 512
  address   = "${local.subnet}.20/24"
  gateway   = local.gateway
  pool      = local.envpool
  basepool  = local.envbasepool
  network   = libvirt_network.fixvid-net.name
}

module "demo2" {
  source    = "../fixvid-modules/instance"
  name      = "demo-2-${local.env}"
  memory    = 512
  address   = "${local.subnet}.30/24"
  gateway   = local.gateway
  pool      = local.envpool
  basepool  = local.envbasepool
  network   = libvirt_network.fixvid-net.name
}

///////////////////////
// nginx
module "demo1-nginx" {
  source    = "../fixvid-modules/install-nginx"
  ip        = module.demo1.ip
  ssh_user  = var.ssh_user
  ssh_key   = var.ssh_key
}
///////////////////////
// docker
module "devops-docker" {
  source     = "../fixvid-modules/install-docker"
  ip         = module.devops.ip
  ssh_user   = var.ssh_user
  ssh_key    = var.ssh_key
}

///////////////////////
// ansible
module "toolbox-ansible" {
  source     = "../fixvid-modules/config-ansible"
  ip         = module.toolbox.ip
  ssh_user   = var.ssh_user
  ssh_key    = var.ssh_key
  subnet     = local.subnet
}

///////////////////////
// clean local
resource "null_resource" "clean" {
  provisioner "local-exec" {
    command = "rm ~/.ssh/known_hosts 2>&1 >/dev/null || echo 0"
  }
}

///////////////////////
// output
# output "network" {
#   value = libvirt_network.fixvid-net
# }
#
# output "pool" {
#   value = local.envpool
# }
#
# output "basepool" {
#   value = local.envbasepool
# }


