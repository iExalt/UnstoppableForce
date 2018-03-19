variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "server_ip" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
