locals {
  dbname = "fixvid-confluence-db"
  dbuser = "confluence"
  dbpwd  = "confluence"
}


//////////////////
//postgres
resource "docker_image" "docker-postgres" {
  name = "${local.cache}postgres"
  keep_locally = false
}

resource "docker_container" "docker-postgres" {
  image         = docker_image.docker-postgres.image_id
  name          = local.dbname
  network_mode  = "bridge"
  ports {
    internal = 5432
    external = 8060
  }
  env = [
    "POSTGRES_DB=${local.dbname}",
    "POSTGRES_USER=${local.dbuser}",
    "POSTGRES_PASSWORD=${local.dbpwd}"
  ]
}