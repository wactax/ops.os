FROM ubuntu:23.10 as build

WORKDIR /app

RUN apt-get update -y 

ADD _ubuntu.sh _ubuntu.sh

RUN ./_ubuntu.sh

ADD nginx.service nginx.service
ADD nginx nginx
ADD setup.sh setup.sh

# RUN ./setup.sh


# FROM ubuntu:23.10
#
# COPY --from=build /usr/local/nginx /usr/local/nginx
# COPY --from=build /etc/nginx /etc/nginx
# COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
# COPY --from=build /usr/local/src/LuaJIT/lib /usr/local/src/LuaJIT/lib
# ADD nginx.service /lib/systemd/system/

# RUN /usr/sbin/nginx -g "daemon off;" 

# FROM ubuntu:23.10

