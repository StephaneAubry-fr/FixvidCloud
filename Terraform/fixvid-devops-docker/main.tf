terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

///////////////////////
locals {
  env = terraform.workspace
  host = "ssh://devops-${local.env}"
  //cache = "192.168.1.224/"
  cache = ""
}

///////////////////////
// docker
provider "docker" {
  host = local.host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

//////////////////
//nginx
resource "docker_image" "docker-nginx" {
  name = "${local.cache}nginx:latest"
  keep_locally = false
}

resource "docker_container" "docker-nginx" {
  image = docker_image.docker-nginx.image_id
  name  = "nginx"
  ports {
    internal = 80
    external = 8080
  }
}

//////////////////
// jira
resource "docker_image" "jira" {
  name = "${local.cache}atlassian/jira-software:latest"
  keep_locally = false
}

resource "docker_container" "jira" {
  image = docker_image.jira.image_id
  name  = "jira"
  ports {
    internal = 8080
    external = 8081
  }
}

//////////////////
// jenkins
resource "docker_image" "jenkins" {
  name = "${local.cache}jenkins/jenkins:lts-jdk21"
  keep_locally = false
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.image_id
  name  = "jenkins"
  ports {
    internal = 8080
    external = 8082
  }
  ports {
    internal = 50000
    external = 50000
  }
}