#
# cd /srv/git/ibm-docker/build/alpine
# cat /net/main/srv/common-setup/ssl/cacert.pem > ExampleCA.crt
# DATE=$(date +%Y%m%d)
# time docker build --build-arg DATE=$DATE --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg ftp_proxy=$ftp_proxy --build-arg no_proxy=$no_proxy --tag registry.example.com:5000/alpine:$DATE --tag registry.example.com:5000/alpine:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_alpine.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/alpine:$DATE
# docker image push registry.example.com:5000/alpine:latest

FROM alpine

ARG DATE=19700101
ARG http_proxy=http://cache.example.com:3128
ARG https_proxy=http://cache.example.com:3128
ARG ftp_proxy=http://cache.example.com:3128
ARG no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/alpine" \
      version="$DATE"

COPY ["ExampleCA.crt","/usr/local/share/ca-certificates/ExampleCA.crt"]

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy
ENV no_proxy=$no_proxy

RUN echo '*** updating zypper repositories' && \
    apk update && \
    echo '*** installing required packages' && \
    apk add --force --no-cache \
bash-completion \
bind-tools \
bzip2 \
ca-certificates \
curl \
file \
gcc \
iputils \
mksh \
less \
libaio \
lsof \
libstdc++ \
netcat-openbsd \
net-tools \
openssl \
psmisc \
sudo \
tar \
unzip \
wget && \
    echo '**** adding custom CA to trusted list of CAs' && \
    update-ca-certificates && \
    echo '*** changing default shell from dash to bash' && \
    rm -f /bin/sh && ln -s bash /bin/sh

CMD ["/bin/bash","--login"]
