# cd /srv/git/ibm-docker/build/ubuntu-trusty
# cat /net/main/srv/common-setup/ssl/cacert.pem > ExampleCA.crt
# DATE=$(date +%Y%m%d)
# time docker build --build-arg DATE=$DATE --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg ftp_proxy=$ftp_proxy --build-arg no_proxy=$no_proxy --tag registry.example.com:5000/ubuntu-trusty:$DATE --tag registry.example.com:5000/ubuntu-trusty:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty:$DATE
# docker image push registry.example.com:5000/ubuntu-trusty:latest

FROM ubuntu:trusty

ARG DATE=19700101
ARG http_proxy=http://cache.example.com:3128
ARG https_proxy=http://cache.example.com:3128
ARG ftp_proxy=http://cache.example.com:3128
ARG no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-trusty" \
      version="$DATE"

COPY ["ExampleCA.crt","/usr/local/share/ca-certificates/ExampleCA.crt"]

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy
ENV no_proxy=$no_proxy

RUN echo '*** adding 32-bit package list to apt' && \
    dpkg --add-architecture i386 && \
    echo '*** updating apt package list' && \
    apt-get update && \
    echo '*** installing required packages' && \
    TERM=linux apt-get install -y \
bash-completion \
bzip2 \
ca-certificates \
curl \
dialog \
file \
gcc \
host \
iputils-ping \
ksh \
less \
libaio1 \
libaio1:i386 \
libpam0g \
libpam0g:i386 \
librdmacm1 \
lsof \
libstdc++6 \
libstdc++6:i386 \
netcat-openbsd \
net-tools \
nfs-common \
openssh-client \
openssl \
psmisc \
sudo \
tar \
telnet \
unzip \
wget && \
    echo '**** cleaning out cached apt archive' && \
    apt-get clean && \
    echo '**** adding custom CA to trusted list of CAs' && \
    update-ca-certificates && \
    echo '*** changing default shell from dash to bash' && \
    rm -f /bin/sh && ln -s /bin/bash /bin/sh && \
    echo "Done ...."

CMD ["/bin/bash","--login"]
