resource "digitalocean_droplet" "ELK-Server" {
    image = "ubuntu-16-04-x64"
    name = "ELK-Server"
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
      "add-apt-repository -y ppa:webupd8team/java",
      "echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections",
      "wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -",
      "echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list",
      "echo 'deb http://packages.elastic.co/kibana/4.5/debian stable main' | tee -a /etc/apt/sources.list",
      "echo 'deb http://packages.elastic.co/logstash/2.3/debian stable main' | sudo tee -a /etc/apt/sources.list",
      "apt-get update",
      "apt-get --yes install oracle-java8-installer elasticsearch kibana nginx logstash unzip"
    ]
  }
  
  provisioner "file" {
    source = "${path.module}/config/elasticsearch.yml"
    destination = "/etc/elasticsearch/elasticsearch.yml"
  }
  provisioner "file" {
    source = "${path.module}/config/kibana.yml"
    destination = "/opt/kibana/config/kibana.yml"
  }
  provisioner "file" {
    source = "${path.module}/config/default"
    destination = "/etc/nginx/sites-available/default"
  }
  provisioner "file" {
    source = "${path.module}/config/10-syslog-filter.conf"
    destination = "/etc/logstash/conf.d/10-syslog-filter.conf"
  }
  provisioner "file" {
    source = "${path.module}/config/20-beats-input.conf"
    destination = "/etc/logstash/conf.d/20-beats-input.conf"
  }
  provisioner "file" {
    source = "${path.module}/config/30-elasticsearch-output.conf"
    destination = "/etc/logstash/conf.d/30-elasticsearch-output.conf"
  }
  provisioner "file" {
    source = "${path.module}/config/openssl.cnf"
    destination = "/etc/ssl/openssl.cnf"
  }
  /*
  provisioner "file" {
    source = "${path.module}/config/extras.sh"
    destination = "/root/extras.sh"
  }
  */
  
  provisioner "remote-exec" {
    inline = [
      "echo \"${var.nginx_user}:`echo ${var.nginx_pass} | openssl passwd -apr1 -stdin`\" | tee -a /etc/nginx/htpasswd.users",
      "service elasticsearch restart",
      "service kibana restart",
      "service nginx restart",
      "service logstash restart",
      "ufw allow 'Nginx Full'",
      "sed -i \"s/VAR_REPLACE/`hostname -I | cut -d' ' -f1`/g\" /etc/ssl/openssl.cnf",
      "mkdir -p /etc/pki/tls/certs",
      "mkdir /etc/pki/tls/private",
      "cd /etc/pki/tls",
      "openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt",
      "ufw allow 5044"
      #"/opt/logstash/bin/logstash --configtest -f /etc/logstash/conf.d/"
    ]
  }
  
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no root@${digitalocean_droplet.ELK-Server.ipv4_address}:/etc/pki/tls/certs/logstash-forwarder.crt ${path.module}/config/logstash-forwarder.crt"
  }
  provisioner "remote-exec" {
    script = "${path.module}/config/extras.sh"
  }

}

  

output "ELK_Server_IP" {
  value ="${digitalocean_droplet.ELK-Server.ipv4_address}"
}

