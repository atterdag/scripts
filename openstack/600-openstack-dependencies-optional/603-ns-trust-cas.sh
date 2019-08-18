#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
# Get list of CA certifiates
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
  CA_CERTIFICATES=$(curl \
    --silent \
  	http://${SSL_ROOT_CA_FQDN}/ \
  | html2text \
  | grep .crt \
  | awk '{print $3}')

  # Download each CA certificate
  for ca_certificate in $CA_CERTIFICATES; do
  	$$ssh_cmd sudo curl \
  	  --output /usr/local/share/ca-certificates/${ca_certificate} \
  		--silent \
  	  http://${SSL_ROOT_CA_FQDN}/${ca_certificate}
  done

  # Install CA certifiates
  $$ssh_cmd sudo update-ca-certificates
fi
