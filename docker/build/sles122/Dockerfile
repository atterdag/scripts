#
# sle2docker activate sles12sp2-docker.x86_64-1.0.0-Build3.2
# cd /srv/git/ibm-docker/build/sles122
# cat /net/main/srv/common-setup/ssl/cacert.pem > ExampleCA.crt
# (cd /net/main/srv/bin; tar --verbose --create --file ${OLDPWD}/sles12-repositories.tar.gz --gzip add-sles12-SLE-*)
# DATE=$(date +%Y%m%d)
# time docker build --build-arg DATE=$DATE --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg ftp_proxy=$ftp_proxy --build-arg no_proxy=$no_proxy --tag registry.example.com:5000/sles122:$DATE --tag registry.example.com:5000/sles122:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122:$DATE
# docker image push registry.example.com:5000/sles122:latest

FROM suse/sles12sp2

ARG DATE=19700101
ARG http_proxy=http://cache.example.com:3128
ARG https_proxy=http://cache.example.com:3128
ARG ftp_proxy=http://cache.example.com:3128
ARG no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/sles122" \
      version="$DATE"

COPY ["ExampleCA.crt","/usr/share/pki/trust/anchors/ExampleCA.crt"]
ADD ["sles12-repositories.tar.gz","/usr/local/sbin"]

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy
ENV no_proxy=$no_proxy

RUN echo '**** adding custom CA to trusted list of CAs' && \
    update-ca-certificates && \
    echo '*** updating zypper repositories' && \
    yes | /usr/local/sbin/add-sles12-SLE-SERVER.sh && \
    echo '*** installing required packages' && \
    zypper install --no-confirm \
bash-completion \
bind-utils \
bzip2 \
ca-certificates \
curl \
file \
gcc \
iputils \
mksh \
less \
libaio1 \
libaio1-32bit \
pam \
pam-32bit \
lsof \
libstdc++6 \
libstdc++6-32bit \
netcat-openbsd \
net-tools \
nfs-client \
openssh \
openssl \
psmisc \
sudo \
tar \
telnet \
unzip \
wget && \
    echo '**** cleaning out zypper repositories' && \
    zypper clean && \
    echo '*** changing default shell from dash to bash' && \
    rm -f /bin/sh && ln -s bash /bin/sh

CMD ["/bin/bash","--login"]
