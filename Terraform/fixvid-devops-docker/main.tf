terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
/*
Pour utiliser un cache : see docker registry
Load:
    docker pull nginx
    docker tag nginx localhost:5000/nginx
    docker push localhost:5000/nginx

List:
    curl -k -X GET https://localhost/v2/_catalog
 */
///////////////////////
locals {
  env = terraform.workspace

  net = {
    default = "10.0.1"
    dev     = "10.0.2"
    qa      = "10.0.3"
    prod    = "10.0.5"
  }
  subnet  = lookup(local.net,local.env)
  ip = "${local.subnet}.10"

  host = "ssh://devops-${local.env}"
  cache = "192.168.1.224/"
  //cache = ""
}

///////////////////////
variable confluence_idserver {}
variable "ssh_user" {}
variable "ssh_key" {}

///////////////////////
// docker
provider "docker" {
  host = local.host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
