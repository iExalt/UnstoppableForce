module "ELK" {
  source = "ELK"
  do_token = "${var.do_token}"
  pub_key = "${var.pub_key}"
  pvt_key = "${var.pvt_key}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  nginx_user = "${var.nginx_user}"
  nginx_pass = "${var.nginx_pass}"
}

module "Kubernetes" {

  source = "Kubernetes"
  do_token = "${var.do_token}"
  pub_key = "${var.pub_key}"
  pvt_key = "${var.pvt_key}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  server_ip = "${module.ELK.ELK_Server_IP}"
}

output "instance ip" {
  value ="${module.Kubernetes.instance_IP}"
}  
