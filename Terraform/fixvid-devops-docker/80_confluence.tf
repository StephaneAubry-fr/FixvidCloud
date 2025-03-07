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

resource "time_sleep" "wait_30_seconds" {
  depends_on = [docker_container.docker-confluence]
  create_duration = "30s"
}

resource "null_resource" "docker-confluence-idsever" {
  depends_on = [time_sleep.wait_30_seconds]

  connection {
    type        = "ssh"
    host        = local.ip
    user        = var.ssh_user
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "docker exec -i confluence sed -i 's;<properties>;<properties><property name=\"confluence.setup.server.id\">${var.confluence_idserver}</property>;' confluence.cfg.xml",
      "docker restart confluence"
    ]
  }
}
