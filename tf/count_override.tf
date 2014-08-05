variable "aws_key_name" {}

resource "aws_instance" "docker_host" {
  count = 2
  key_name = "${var.aws_key_name}"
}