# Terraform Demo

A quick demo of [Terraform](http://www.terraform.io/). It creates multiple CoreOS instances in Amazon EC2. This script is still in early development.

You will need to set the following variables either in a terraform.tfvars file or via the commandline:
```
# EC2 Variables
access_key = "YOUR_ACCESS_KEY"
secret_key = "YOUR_SECRET_KEY"
```

Also currently you need to set the count you want in the count_override.tf file. If you want ssh access set the aws_key_name variable to an aws key name or remove all references to it from this count_override.tf

```
variable "aws_key_name" {}

resource "aws_instance" "docker_host" {
  count = 3
  key_name = "${var.aws_key_name}"
}
```

To run:
 - Configure the files in the tf directory. Rename them so that they do not have the .example extension.
 - Build the container
  - ```docker build -t buildingbananas/terraform-demo .```
 - run the testing container interactively
  - ```docker run -i -t --entrypoint=/bin/bash buildingbananas/terraform-demo -s```
 - create the default 3 instance CoreOS cluster
  - ```terraform apply --var-file=terraform.tfvars -var token=$(curl https://discovery.etcd.io/new)```


##ToDo List
- [X] Work out issues with security group
- [ ] Compile terraform from source in the docker container so that it always has the latest patches
- [ ] Move the user_data to a file
- [ ] Set up count so it's an interpolated variable and remove the need for count_override.tf file
- [ ] Work out a better way method to have optional fields like key name
