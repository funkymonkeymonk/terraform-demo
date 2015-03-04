variable "token" {}
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
        us-east-1 = "ami-18205670"
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

resource "aws_vpc" "coreos" {
    cidr_block = "10.0.0.0/16"
    tags {
        Name = "CoreOS VPC"
    }
}

resource "aws_subnet" "coreos" {
    vpc_id = "${aws_vpc.coreos.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"

    tags {
        Name = "CoreOS Cluster"
    }
}

resource "aws_security_group" "coreos-test" {
    name = "coreos-test"
    description = "Allow All inbound traffic on CoreOS Ports"
    vpc_id = "${aws_vpc.coreos.id}"

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["${var.inbound_cidr}"]
    }

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
  subnet_id = "${aws_subnet.coreos.id}"
  tags {
        Name = "CoreOS ${count.index}"
  }
  
  #We are using heredoc as interpolation is not yet supported for files. https://github.com/hashicorp/terraform/issues/215
  user_data = <<EOF
#cloud-config
coreos:
  etcd:
    discovery: ${var.token}
    addr: $private_ipv4:4001
    peer-addr: $private_ipv4:7001
  units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
    - name: docker-tcp.socket
      command: start
      enable: yes
      content: |
        [Unit]
        Description=Docker Socket for the API

        [Socket]
        ListenStream=2375
        BindIPv6Only=both
        Service=docker.service

        [Install]
        WantedBy=sockets.target
    - name: enable-docker-tcp.service
      command: start
      content: |
        [Unit]
        Description=Enable the Docker Socket for the API

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/systemctl enable docker-tcp.socket
EOF  
}

output "coreos_public_ip_addresses" {
  value = "\n    ${join("\n    ", aws_instance.docker_host.*.private_ip)}"
}
