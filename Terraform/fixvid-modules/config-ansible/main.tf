
data "template_file" "config" {
  template = file("${path.module}/config")
  vars = {
    subnet = var.subnet
  }
}

resource "null_resource" "ansible_ctrl" {
  connection {
    type        = "ssh"
    host        = var.ip
    user        = var.ssh_user
    private_key = file(var.ssh_key)
  }

  provisioner "file" {
    source        = "${path.module}/../../certs/deployer"
    destination   = "/tmp/deployer"
  }

  provisioner "file" {
    source        = "${path.module}/../../certs/github"
    destination   = "/tmp/github"
  }

  provisioner "file" {
    source        = "${path.module}/hosts"
    destination   = "/tmp/hosts"
  }

  provisioner "file" {
    content       = data.template_file.config.rendered
    destination   = "/tmp/config"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -H -u deployer bash -c 'echo \"cd ~\" > /home/deployer/.bash_aliases'",
      "sudo -H -u deployer bash -c 'echo \"eval $(ssh-agent -s)\" >> /home/deployer/.bash_aliases'",
      "sudo -H -u deployer bash -c 'echo \"ssh-add ~/.ssh/github\" >> /home/deployer/.bash_aliases'",

      "sudo mkdir -p /home/deployer/.ssh",
      "sudo cp -a /tmp/config /home/deployer/.ssh",
      "sudo cp -a /tmp/deployer /home/deployer/.ssh",
      "sudo cp -a /tmp/github /home/deployer/.ssh",
      "sudo chown -R deployer: /home/deployer/.ssh",
      "sudo chmod 600 /home/deployer/.ssh/config",
      "sudo chmod 600 /home/deployer/.ssh/deployer",
      "sudo chmod 600 /home/deployer/.ssh/github",
      "sudo mkdir -p /etc/ansible",
      "sudo cp -a /tmp/hosts /etc/ansible",
      "sudo chown -R deployer: /etc/ansible",
      "sudo chmod 600 /etc/ansible/hosts"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -H -u deployer bash -c 'ssh-keyscan -t ed25519 ${var.subnet}.10 > ~/.ssh/known_hosts'",
      "sudo -H -u deployer bash -c 'ssh-keyscan -t ed25519 ${var.subnet}.20 >> ~/.ssh/known_hosts'",
      "sudo -H -u deployer bash -c 'ssh-keyscan -t ed25519 ${var.subnet}.30 >> ~/.ssh/known_hosts'",
      "sudo -H -u deployer bash -c 'ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts'"
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo -H -u deployer bash -c 'ansible-inventory --list -y'",
  #     "sudo -H -u deployer bash -c 'ansible all -m ping'",
  #     ]
  # }


}

resource "null_resource" "git_clone_playbook" {
  connection {
    type        = "ssh"
    host        = var.ip
    user        = var.ssh_user
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -H -u deployer bash -c 'rm -rf ~/ansible'",
      "sudo -H -u deployer bash -c 'eval $(ssh-agent -s) && ssh-add ~/.ssh/github && git clone -b main --depth 1 --single-branch git@github.com:StephaneAubry-fr/FixvidToolboxAnsible.git ~/ansible'"
    ]
  }

  depends_on = [
    null_resource.ansible_ctrl
  ]

}