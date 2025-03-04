resource "null_resource" "nginx" {
  connection {
    type        = "ssh"
    host        = var.ip
    user        = var.ssh_user
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -qq >/dev/null",
      "sudo apt-get install -qq -y nginx >/dev/null"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/nginx.conf"
    destination = "/tmp/default"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp -a /tmp/default /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
  }
  provisioner "local-exec" {
    command = "curl ${var.ip}:8080"
  }
}