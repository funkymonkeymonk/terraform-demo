variable "inbound_cidr" {
	default = "0.0.0.0/0"
}
variable "count" {
	default = 3
}
resource "aws_instance" "docker_host" {
  key_name = "${var.aws_key_name}"
}

variable "token" {
  default = "https://discovery.etcd.io/51d9c62d9e294e9b1c989fdc513d8b35"
}

variable "aws_key_name" {
  default = "Work Laptop"
}