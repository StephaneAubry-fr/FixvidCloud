//////////////////
//confluence
resource "docker_image" "docker-confluence" {
  name = "${local.cache}atlassian/confluence:latest"
  keep_locally = false
}

resource "docker_container" "docker-confluence" {
  image         = docker_image.docker-confluence.image_id
  name          = "confluence"
  network_mode  = "bridge"
  ports {
    internal = 8090
    external = 80
  }
  ports {
    internal = 8091
    external = 81
  }
}