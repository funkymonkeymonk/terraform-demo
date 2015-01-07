variable "token" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "access_key" {}
variable "secret_key" {}
variable "aws_region" {
    default = "us-east-1"
}

# CoreOS Stable Channel
variable "aws_amis" {
    default = {
        ap-northeast-1 = "ami-decfc0df"
        sa-east-1 =  "ami-cb04b4d6"
        ap-southeast-2 =  "ami-d1e981eb"
        ap-southeast-1 =  "ami-83406fd1"
        us-east-1 = "ami-705d3d18"
        us-west-2 = "ami-4dd4857d"
        us-west-1 = "ami-17fae852"
        eu-west-1 = "ami-783a840f"
        eu-central-1 = "ami-487d4d55"
    }
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.aws_region}"
}

resource "aws_security_group" "coreos-test" {
    name = "coreos-test"
    description = "Allow All inbound traffic on CoreOS Ports"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.inbound_cidr}"]
    }
    
    ingress {
        from_port = 4001
        to_port = 4001
        protocol = "tcp"
        cidr_blocks = ["${var.inbound_cidr}"]
    }

    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.inbound_cidr}"]
    }
}

resource "aws_instance" "docker_host" {
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  count = "${var.count}"
  key_name = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.coreos-test.id}"]
  subnet_id = "${var.subnet_id}"
  tags {
        Name = "CoreOS ${count.index}"
  }
  user_data = "#cloud-config\n\ncoreos:\n  etcd:\n    discovery: ${var.token}\n    addr: $private_ipv4:4001\n    peer-addr: $private_ipv4:7001\n  units:\n    - name: etcd.service\n      command: start\n    - name: fleet.service\n      command: start"
}

output "public_ip_addresses" {
  value = "\n    ${join("\n    ", aws_instance.docker_host.*.public_ip)}"
}

