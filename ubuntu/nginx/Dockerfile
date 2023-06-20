FROM ubuntu:23.10 as build

WORKDIR /app

RUN apt-get update -y 

ADD setup.sh setup.sh
ADD _ubuntu.sh _ubuntu.sh

RUN ./_ubuntu.sh

ADD nginx.service nginx.service
RUN ./setup.sh


# FROM ubuntu:23.10

