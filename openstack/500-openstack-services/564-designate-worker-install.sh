#!/bin/sh

##############################################################################
# Install Designate Worker on Controller host
##############################################################################
cat << EOF | sudo tee /etc/designate/pools.yaml
- name: default
  # The name is immutable. There will be no option to change the name after
  # creation and the only way will to change it will be to delete it
  # (and all zones associated with it) and recreate it.
  description: Default Pool

  attributes: {}

  # List out the NS records for zones hosted within this pool
  # This should be a record that is created outside of designate, that
  # points to the public IP of the controller node.
  ns_records:
    - hostname: ${CONTROLLER_FQDN}.
      priority: 1

  # List out the nameservers for this pool. These are the actual BIND servers.
  # We use these to verify changes have propagated to all nameservers.
  nameservers:
    - host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
      port: 53

  # List out the targets for this pool. For BIND there will be one
  # entry for each BIND server, as we have to run rndc command on each server
  targets:
    - type: bind9
      description: BIND9 Server 1

      # List out the designate-mdns servers from which BIND servers should
      # request zone transfers (AXFRs) from.
      # This should be the IP of the controller node.
      # If you have multiple controllers you can add multiple masters
      # by running designate-mdns on them, and adding them here.
      masters:
        - host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
          port: 5354

      # BIND Configuration options
      options:
        host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
        port: 53
        rndc_host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
        rndc_port: 953
        rndc_key_file: /etc/bind/designate.key
EOF
sudo chmod 0660 /etc/designate/designate.conf
sudo chown designate:designate /etc/designate/designate.conf

sudo su -s /bin/sh -c "designate-manage pool update" designate

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate-worker \
  designate-producer \
  designate-mdns

sudo systemctl restart \
  designate-worker \
  designate-producer \
  designate-mdns
