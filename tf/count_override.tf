variable "aws_key_name" {}
variable "inbound_cidr" {
	default = "0.0.0.0/0"
}
variable "count" {
	default = 3
}
resource "aws_instance" "docker_host" {
  key_name = "${var.aws_key_name}"
}