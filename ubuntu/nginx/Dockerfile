FROM ubuntu:23.10 as build

WORKDIR /app

RUN apt-get update -y 

ADD _ubuntu.sh .

RUN ./_ubuntu.sh

ADD nginx.service nginx.service
ADD nginx nginx
ENV NGINX_USER root
ADD nginx.conf nginx.conf
ADD setup.sh .

RUN ./setup.sh
ADD cpso.sh .
RUN ./cpso.sh

FROM ubuntu:23.10

COPY --from=build /usr/local/nginx /usr/local/nginx
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /usr/sbin/_nginx /usr/sbin/_nginx
COPY --from=build /usr/local/src/LuaJIT/lib /usr/local/src/LuaJIT/lib

RUN mkdir -p /var/log/nginx &&\
grep -qF -- "root " /etc/security/limits.conf || echo -e "\nwww-data soft nofile 252144\nwww-data hard nofile 262144\n" >>/etc/security/limits.conf 

ENV LD_LIBRARY_PATH=/lib
COPY --from=build /so/ /lib/
CMD ["/usr/sbin/nginx","-g","daemon off;"]
