variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "nginx_user" {}
variable "nginx_pass" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
