FROM ubuntu:23.10 as build

WORKDIR /app

RUN apt-get update -y 

ADD _ubuntu.sh _ubuntu.sh

RUN ./_ubuntu.sh

RUN apt-get install -y git wget patch make mercurial ninja-build
RUN apt-get install -y jq curl unzip
ADD nginx.service nginx.service
ADD setup.sh setup.sh
RUN ./setup.sh


FROM ubuntu:23.10

COPY --from=build /usr/local/nginx /usr/local/nginx
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
# ADD nginx.service /lib/systemd/system/

RUN /usr/sbin/nginx -g "daemon off;" 

# FROM ubuntu:23.10

