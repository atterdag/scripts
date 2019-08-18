#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack security group create \
  --description "Bind 9 RNDC communication" \
  rndc
openstack security group rule create \
  --proto tcp \
  --dst-port 953 \
  rndc

openstack security group create \
  --description "Designate MDNS" \
  designate
openstack security group rule create \
  --proto tcp \
  --dst-port 5354 \
  designate
openstack security group rule create \
  --proto tcp \
  --dst-port 5358 \
  designate
openstack security group rule create \
  --proto tcp \
  --dst-port 9001 \
  designate

openstack security group create \
  --description "DNS zone transfer" \
  domain_xfer
openstack security group rule create \
  --proto tcp \
  --dst-port 53 \
  domain_xfer

openstack security group create \
  --description "DNS query" \
  domain
openstack security group rule create \
  --proto udp \
  --dst-port 53 \
  domain
