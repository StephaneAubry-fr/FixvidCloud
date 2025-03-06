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
  host = "ssh://devops-${local.env}"
  cache = "192.168.1.224/"
  //cache = ""
}

///////////////////////
// docker
provider "docker" {
  host = local.host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
