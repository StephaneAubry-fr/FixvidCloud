# Dev environment

## Password Manager

- [KeePass](https://keepass.info/index.html)

## ssh
- sur la source


    $ ssh-keygen -C devops -f devops
    $ ssh-keygen -C provisioner -f provisioner
    $ ssh-keygen -C deployer -f deployer

Puis recopier le id_rsa.pub sur le target dans


    ~/.ssh/authorized_keys


## Oracle VirtualBox
- [VirtualBox Home](https://www.virtualbox.org/)

- CLI


    $ vboxmanage list vms
    $ vboxmanage showvminfo devops_node
    $ vboxmanage list hdds


## KVM
- [KVM Home](https://linux-kvm.org/page/Main_Page)
- [Download](https://www.linux-kvm.org/page/Downloads)

## Vagrant
- [Get Started](https://developer.hashicorp.com/vagrant/tutorials/get-started)
- [Vagrant boxes discovery](https://portal.cloud.hashicorp.com/vagrant/discover)

eg:

	$ vagrant init hashicorp-education/ubuntu-24-04 --box-version 0.1.0 

    $ vagrant up 

 If the machine is already running, apply the provisioning scripts with vagrant provision.

	$ vagrant provision

 If you want to force provisioning when you start the machine, apply the --provision flag.

	$ vagrant up --provision

If you want to delete the VN

    $ vagrant destroy

## Terraform

- [Get Started](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Providers](https://registry.terraform.io/)
- Principales commandes


    $ terraform init    
    $ terraform plan
    $ terraform apply -auto-approve
    $ terraform destroy -auto-approve

- Workspaces

    
    $ terraform workspace show
    $ terraform workspace list
    $ terraform workspace new dev
    $ terraform workspace new prod
    $ terraform workspace select dev
    $ terraform workspace show

- Pool

le pool "local-kvm-img" est à gérer manuellement



- map et triggers : prise en compte de modification de valeur dans une map (modification sur clé prise en compte automatiquement)

```
variable "hosts" {
  default     = {
    "127.0.0.1" = "localhost gitlab.local"
    "192.169.1.168" = "gitlab.test"
    "192.169.1.170" = "prometheus.test"
  }
}
resource "null_resource" "hosts" {
  for_each = var.hosts
  triggers = {
    check_value_changed = each.value
  }
  provisioner "local-exec" {
    command = "echo '${each.key} ${each.value}' >> hosts.txt"
  }
}
```

- liste et triggers

```
variable "hosts" {
  default     = ["127.0.0.1 localhost","192.168.1.133 gitlab.test2"]
}
resource "null_resource" "hosts" {
  count = "${length(var.hosts)}"
  triggers = {
    check_value_changed = element(var.hosts, count.index)
  }
  provisioner "local-exec" {
    command = "echo '${element(var.hosts, count.index)}' >> hosts.txt"
  }
}
```

- fichier de variables *.tfvars


        str="terraform"

- libvirt-local-terraform

dans sudo vim /etc/libvirt/qemu.conf

    security_driver = [ "none" ]

puis

    sudo systemctl restart libvirtd

## virsh

    virsh net-list --all
    virsh net-dumpxml default
    
    virsh net-define network.xml
    virsh net-start test-dhcp
    
    virsh net-dhcp-leases test-dhcp
    
    virsh net-destroy test-dhcp
    virsh net-undefine test-dhcp
    
    ls /var/lib/libvirt/dnsmasq
    
    virsh net-start fixvid-dev
    virsh net-autostart fixvid-dev

## docker

    docker images
    docker pull <img>
    docker rmi <img>
    
    docker ps
    docker stop <ctr>
    docker rm -v <ctr>

## docker proxy - insecure registry
- registry-proxy localhost
    

    docker run -d -p 5000:5000 --restart always --name registry registry
    docker pull nginx
    docker tag nginx localhost:5000/nginx
    docker push localhost:5000/nginx


- VM
modify daemon


    sudo cat /etc/docker/daemon.json
=>
  
    {
        "insecure-registries" : ["192.168.1.224:5000"]
    }

control & pull

    curl 192.168.1.224:5000/v2/_catalog
    docker pull 192.168.1.224:5000/nginx

## docker proxy - self-signed certificates
- configure proxy

      cat /etc/docker/registry/config.yml
=>

      proxy:
        remoteurl: https://registry-1.docker.io



- generate own cert (CN = myregistry.domain.com)

       openssl req \
            -newkey rsa:4096 -nodes -sha256 -keyout ~/W/certs/domain.key \
            -addext "subjectAltName = DNS:myregistry.domain.com" \
            -x509 -days 365 -out ~/W/certs/domain.crt

      openssl req \
            -newkey rsa:4096 -nodes -sha256 -keyout ~/W/certs/domain.key \
            -addext "subjectAltName = IP:192.168.1.224" \
            -x509 -days 365 -out ~/W/certs/domain.crt
    
- registry-proxy localhost


    docker run -d -p 5000:5000 --restart always --name my-registry \
    -v ~/W/certs:/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -p 443:443 \
    registry

delete

    docker container stop my-registry && docker container rm -v my-registry

pull and publish

    docker pull nginx
    docker tag nginx localhost:443/nginx
    docker push localhost:443/nginx

    docker pull atlassian/jira-software
    docker tag atlassian/jira-software localhost:443/atlassian/jira-software
    docker push localhost:443/atlassian/jira-software

    docker pull jenkins/jenkins:lts-jdk21
    docker tag jenkins/jenkins:lts-jdk21 localhost:443/jenkins/jenkins:lts-jdk21
    docker push localhost:443/jenkins/jenkins:lts-jdk21

    docker pull atlassian/confluence:latest
    docker tag atlassian/confluence:latest  localhost:443/atlassian/confluence:latest 
    docker push localhost:443/atlassian/confluence:latest

    docker pull postgres
    docker tag postgres  localhost:443/postgres
    docker push localhost:443/postgres

    docker images
    curl -k https://192.168.1.224/v2/_catalog
    
    docker pull 192.168.1.224/postgres

- VM 
Copy the domain.crt file to /etc/docker/certs.d/myregistrydomain.com:5000/ca.crt on every Docker host. 
You do not need to restart Docker.

ubuntu : 

sudo cp /tmp/domain.crt /usr/local/share/ca-certificates/host-terraform.crt

sudo cp /tmp/domain.crt /usr/share/ca-certificates/host-terraform.crt
sudo echo host-terraform.crt >> /etc/ca-certificates.conf
sudo update-ca-certificates

modify proxy


    sudo cat /etc/docker/daemon.json
=>

    {
      "registry-mirrors": ["https://192.168.1.224"]
    }

docker info
curl -k https://192.168.1.224/v2/_catalog
docker pull 192.168.1.224/my-nginx
docker pull 192.168.1.224/atlassian/jira-software

- postgres


    docker run -d \
    --name fixvid-conflence-db \
    -e POSTGRES_DB=fixvid-conflence-db \
    -e POSTGRES_DB=confluence \
    -e POSTGRES_PASSWORD=confluence \
    postgres
    
    
    docker exec -it fixvid-conflence-db echo toto
    
    
    docker exec -i fixvid-conflence-db psql -v ON_ERROR_STOP=1 --username "confluence" --dbname "fixvid-conflence-db" <<-EOSQL 
    SELECT current_database();
    EOSQL




## github

eval "$(ssh-agent -s)" 
ssh-add ~/.ssh/github
git clone git@github.com:StephaneAubry-fr/FixvidToolboxAnsible.git ~/ansible
git clone -b main --depth 1 --single-branch git@github.com:StephaneAubry-fr/FixvidToolboxAnsible.git ~/ansible


## Ansible
- /etc/ansible/hosts


    [servers]
    devops
    demo1
    demo2
    
    [all:vars]
    ansible_python_interpreter=/usr/bin/python3



- test


    ansible-inventory --list -y
    ansible all -m ping
