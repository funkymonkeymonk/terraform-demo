# BUILD-USING:    docker build -t buildingbananas/terraform-demo .
# TEST-USING:     docker run --rm -i -t -v $(pwd)/tf/:/home/terraform/demo/ -h=terraform-demo --name=terraform-demo --entrypoint=/bin/bash buildingbananas/terraform-demo -s
# RUN-USING:      docker run --rm -h=terraform-demo --name=terraform-demo buildingbananas/terraform-demo

FROM ubuntu:latest
MAINTAINER Will Weaver <monkey@buildingbananas.com>

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y unzip ca-certificates

WORKDIR /usr/local/bin

ADD https://dl.bintray.com/mitchellh/terraform/0.1.0_linux_amd64.zip /usr/local/bin/
RUN unzip 0.1.0_linux_amd64.zip; rm 0.1.0_linux_amd64.zip

# User setup
RUN useradd -m terraform
USER terraform
WORKDIR /home/terraform/demo

ADD ./tf/ /home/terraform/demo/

ENTRYPOINT ["terraform"]

CMD ["version"]
