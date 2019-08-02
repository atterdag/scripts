#!/bin/bash

##############################################################################
# Create default SSH key on Controller host if you don't want to forward one
##############################################################################
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  default
