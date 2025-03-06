//////////////////
//nginx
resource "docker_image" "docker-nginx" {
  name = "${local.cache}nginx:latest"
  keep_locally = false
}

resource "docker_container" "docker-nginx" {
  image         = docker_image.docker-nginx.image_id
  name          = "nginx"
  network_mode  = "bridge"
  ports {
    internal = 80
    external = 8080
  }
}