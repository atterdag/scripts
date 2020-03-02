#!/bin/bash

declare -a CONFIGURATION_FILES=(/etc/keystone/keystone.conf \
/etc/glance/glance-api.conf \
/etc/placement/placement.conf \
/etc/nova/nova.conf \
/etc/neutron/neutron.conf \
/etc/neutron/plugins/ml2/ml2_conf.ini \
/etc/neutron/plugins/ml2/linuxbridge_agent.ini \
/etc/neutron/l3_agent.ini \
/etc/neutron/dhcp_agent.ini \
/etc/neutron/metadata_agent.ini \
/etc/cinder/cinder.conf)

for CONFIGURATON_FILE in "${CONFIGURATION_FILES[@]}"; do
  echo
  echo "------------------------------------------------------------------------------"
  echo $CONFIGURATON_FILE
  echo "------------------------------------------------------------------------------"
  sudo grep -v -E '^$|^#' $CONFIGURATON_FILE
done
