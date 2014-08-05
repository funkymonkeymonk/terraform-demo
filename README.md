# Terraform Demo

A quick demo of [Terraform](http://www.terraform.io/). It creates multiple CoreOS instances in Amazon EC2. This script is still in early development.

EC2 Instaces require a coreos-testing group to be set up as per [CoreOS EC2 Instructions](http://coreos.com/docs/running-coreos/cloud-providers/ec2/#creating-the-security-group)

You will need to set the following variables either in a terraform.tfvars file or via the commandline:
```
# EC2 Variables
access_key = "YOUR_ACCESS_KEY"
secret_key = "YOUR_SECRET_KEY"
aws_key_name = "YOUR_AWS_KEY_FOR_SSH_ACCESS"

#CoreOS Variables - https://discovery.etcd.io/new
token = "YOUR_COREOS_TOKEN"
```

To run:
 - Configure the files in the tf directory. Rename them so that they do not have the .example extension.
 - Build the container
 ```docker build -t buildingbananas/terraform-demo .```
 - remaining instructions to come soon. Feel free to run the container interactively to test

