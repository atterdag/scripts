#!/bin/bash

. `dirname $0`/properties.sh

echo 'adding proxy environment'
/host/bin/add-proxyenv.sh $PROXYHOST $PROXYPORT $PROXYUSER $PROXYPASS || exit 1
. /etc/profile.d/proxyenv.sh

echo '*** adding 32-bit package list to apt'
dpkg --add-architecture i386 || exit 1

echo '*** updating apt package list'
apt-get update || exit 1

echo '*** installing required packages'
apt-get install -y \
bash-completion \
bzip2 \
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
openssh-server \
openssl \
psmisc \
sudo \
telnet \
unzip \
wget \
|| exit 1

echo '*** changing default shell from dash to bash'
rm -f /bin/sh && ln -s /bin/bash /bin/sh || exit 1

