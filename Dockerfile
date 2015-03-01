# BUILD-USING:    docker build -t buildingbananas/terraform-demo .
# TEST-USING:     docker run --rm -i -t -v $(pwd)/tf/:/home/terraform/demo/ --name=terraform-demo --entrypoint=/bin/bash buildingbananas/terraform-demo -s
# RUN-USING:      docker run --rm -v $(pwd)/tf/:/home/terraform/demo/ --name=terraform-demo buildingbananas/terraform-demo

FROM ubuntu:latest
MAINTAINER Will Weaver <monkey@buildingbananas.com>

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y unzip ca-certificates curl

WORKDIR /usr/local/bin

ADD http://dl.bintray.com/mitchellh/terraform/terraform_0.3.5_linux_amd64.zip /usr/local/bin/terraform.zip
RUN unzip terraform.zip; rm terraform.zip

# User setup
RUN useradd -m terraform
USER terraform
WORKDIR /home/terraform/demo

ADD ./tf/ /home/terraform/demo/

ENTRYPOINT ["terraform"]

CMD ["version"]
