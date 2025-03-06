//////////////////
// jira
resource "docker_image" "jira" {
  name = "${local.cache}atlassian/jira-software:latest"
  keep_locally = false
}

resource "docker_container" "jira" {
  image         = docker_image.jira.image_id
  name          = "jira"
  network_mode  = "bridge"
  ports {
    internal = 8080
    external = 8081
  }
}