//////////////////
// jenkins
resource "docker_image" "jenkins" {
  name = "${local.cache}jenkins/jenkins:lts-jdk21"
  keep_locally = false
}

resource "docker_container" "jenkins" {
  image         = docker_image.jenkins.image_id
  name          = "jenkins"
  network_mode  = "bridge"
  ports {
    internal = 8080
    external = 8082
  }
  ports {
    internal = 50000
    external = 50000
  }
}