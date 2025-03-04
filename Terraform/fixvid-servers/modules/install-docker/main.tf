#docker avec socket
# data "template_file" "docker-startup" {
#   template = file("${path.module}/startup-options.conf")
#   vars = {
#     ip = var.ip
#   }
# }

resource "null_resource" "docker-ssh" {
  connection {
    type = "ssh"
    host = var.ip
    user = var.ssh_user
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo chmod 755 get-docker.sh",
      "sudo ./get-docker.sh >/dev/null"
    ]
  }
  # provisioner "file" {
  #   content     = data.template_file.docker-startup.rendered
  #   destination = "/tmp/startup-options.conf"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo mkdir -p /etc/systemd/system/docker.service.d/",
  #     "sudo cp /tmp/startup-options.conf /etc/systemd/system/docker.service.d/startup_options.conf",
  #     "sudo systemctl daemon-reload",
  #     "sudo systemctl restart docker"
  #   ]
  # }
  provisioner "file" {
    source      = "${path.module}/cert/domain.crt"
    destination = "/tmp/domain.crt"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/docker/certs.d/192.168.1.224:5000/",
      "sudo cp /tmp/domain.crt /etc/docker/certs.d/192.168.1.224:5000/ca.crt",
      "sudo cp /tmp/domain.crt /usr/share/ca-certificates/host-terraform.crt",
      "sudo chmod 666 /etc/ca-certificates.conf",
      "sudo echo host-terraform.crt >> /etc/ca-certificates.conf",
      "sudo chmod 644 /etc/ca-certificates.conf",
      "sudo update-ca-certificates"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/daemon.json /etc/docker/daemon.json"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker",
      "sudo usermod -aG docker ${var.ssh_user}"
    ]
  }


  # provisioner "remote-exec" {
  #   inline = ["sudo apt-get install openjdk-21-jre-headless"]
  # }
}