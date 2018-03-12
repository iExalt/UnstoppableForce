resource "digitalocean_droplet" "instance" {
    image = "32343861"
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
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      # install docker v17.12.1
      "apt-get --yes install docker-ce=17.12.1~ce-0~ubuntu"
    ]
  }
}

output "ip" {
  value ="${digitalocean_droplet.instance.ipv4_address}"
}
