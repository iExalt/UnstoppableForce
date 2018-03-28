data "terraform_remote_state" "ELK" {
  backend = "local"
  config {
    path = "../ELK/terraform.tfstate"
  }
}

resource "digitalocean_droplet" "instance" {
  image = "ubuntu-16-04-x64"
  name = "instance"
  region = "tor1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  
  
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # set up docker
      "apt-get --yes install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'",
      "apt-get update",
      # install docker v17.12.1
      "apt-get --yes install docker-ce=17.12.1~ce-0~ubuntu"
    ]
  }
  provisioner "file" {
    source = "${path.module}/config/image.tar"
    destination = "/root/image.tar"
  }
  provisioner "file" {
    source = "${path.module}/config/srv.yaml"
    destination = "/root/srv.yaml"
  }
  
  provisioner "remote-exec" {
    inline = [
      "curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube &&  mv minikube /usr/local/bin/",
      "curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/",
      "minikube start --vm-driver=none --extra-config=apiserver.ServiceNodePortRange=1-15000",
      "docker import image.tar a:a",
      "kubectl run dep1 --image=a:a --port 5000 --command -- python3 /root/website.py --image-pull-policy=Never",
      "kubectl create -f srv.yaml",
      "mkdir -p /etc/pki/tls/certs",
      "echo 'deb https://packages.elastic.co/beats/apt stable main' | tee -a /etc/apt/sources.list.d/beats.list",
      "wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -",
      "apt-get update",
      "apt-get install filebeat"
    ]
  }
  
  
  provisioner "file" {
    source = "${path.root}/ELK/config/logstash-forwarder.crt"
    destination = "/etc/pki/tls/certs/logstash-forwarder.crt"
  }
  
  provisioner "file" {
    source = "${path.module}/config/filebeat.yml"
    destination = "/etc/filebeat/filebeat.yml"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sed -i \"s/VAR_REPLACE/${var.server_ip}/g\" /etc/filebeat/filebeat.yml",
      "service filebeat restart"
    ]
  }
}

// "sed -i \"s/VAR_REPLACE/${digitalocean_droplet.ELK-Server.ipv4_address}/g\" /etc/filebeat/filebeat.yml",

output "instance_IP" {
  value ="${digitalocean_droplet.instance.ipv4_address}"
}
