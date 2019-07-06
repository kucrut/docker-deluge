FROM alpine:edge

RUN \
  echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk update && \
  apk add --upgrade apk-tools && \
  apk add supervisor shadow bash py2-pip deluge@testing && \
  apk add --no-cache --virtual .pip-build-deps make g++ autoconf python2-dev python3-dev libffi-dev libressl-dev && \
  pip install automat incremental constantly service_identity && \
  apk del .pip-build-deps && \
  rm -rf /var/cache/apk/*

# add supervisor conf file for app
ADD setup/*.ini /etc/supervisor.d/

# add install bash script
ADD setup/root/*.sh /root/

# add bash script to run deluge
ADD apps/nobody/*.sh /home/nobody/

# add pre-configured config files for nobody
ADD config/nobody/ /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh && \
  /bin/bash /root/install.sh

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store data from app)
VOLUME /data

# expose port for http
EXPOSE 8112

# expose port for deluge daemon
EXPOSE 58846

# expose port for incoming torrent data (tcp and udp)
EXPOSE 58946
EXPOSE 58946/udp

CMD ["/bin/bash", "/root/init.sh"]
