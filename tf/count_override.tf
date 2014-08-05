resource "aws_instance" "docker_host" {
  count = 1
}