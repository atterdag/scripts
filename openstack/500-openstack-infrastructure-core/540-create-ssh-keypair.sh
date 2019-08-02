#!/bin/bash

##############################################################################
# Create default SSH key on Controller host if you don't want to forward one
##############################################################################
if [[ -f ~/.ssh/authorized_keys ]]; then
  openstack keypair create \
    --public-key ~/.ssh/authorized_keys \
    default
else
  echo | ssh-keygen -q -N ""
  openstack keypair create \
    --public-key ~/.ssh/id_rsa.pub \
    default
fi
