#!/bin/sh
vmware-config-tools.pl \
 --clobber-kernel-modules=vmxnet3 \
 --clobber-kernel-modules=pvscsi \
 --clobber-kernel-modules=vmmemctl \
 --clobber-kernel-modules=vmblock \
 --clobber-kernel-modules=vmci \
 --clobber-kernel-modules=vsock \
 --clobber-kernel-modules=vmsync \
 --clobber-kernel-modules=vmwgfx \
 --default

# --clobber-kernel-modules=vmxnet \
#  --clobber-kernel-modules=vmhgfs \

if [ $?=0 ]; then
    cd /usr/src
    if [ -d vmware-tools-distrib ]; then
        rm -fr vmware-tools-distrib
    fi
fi

