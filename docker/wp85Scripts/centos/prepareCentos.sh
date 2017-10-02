#!/bin/bash

. `dirname $0`/properties.sh


echo 'adding proxy environment'
/host/bin/add-proxyenv.sh $PROXYHOST $PROXYPORT $PROXYUSER $PROXYPASS || exit 1

. /etc/profile.d/proxyenv.sh

echo '*** installing required packages'
yum -y install \
	bash-completion\
	bzip2 \
	compat-libstdc++-33.i686 compat-libstdc++-33.x86_64 \
	curl \
	file \
	gcc* \
	ksh.x86_64 \
	less \
	libaio.i686 \
	libaio.x86_64 \
	librdmacm.i686 \
	librdmacm-static.i686 \
	librdmacm-static.x86_64 \
	librdmacm.x86_64 \
	libstdc++.i686 \
	libstdc++-static.i686 \
	libstdc++-static.x86_64 \
	libstdc++.x86_64 \
	nc \
	net-tools \
	nfs-utils.x86_64 \
	openibd \
	openssh-clients.x86_64 \
	openssh-server.x86_64 \
	openssl.x86_64 \
	pam.i686 \
	pam.x86_64 \
	rdma-ndd.x86_64 \
	rdma.noarch \
	sudo \
	telnet \
	unzip \
	wget
