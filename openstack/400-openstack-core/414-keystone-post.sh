#!/bin/bash

##############################################################################
# Ensure Keystone works on Controller host
##############################################################################
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
# export OS_AUTH_URL=http://${CONTROLLER_FQDN}:5000/v3
export OS_IDENTITY_API_VERSION=3

openstack project create \
  --domain default \
  --description "Service Project" \
  service
openstack project create \
  --domain default \
  --description "Demo Project" \
  demo
openstack user create \
  --domain default \
  --password $DEMO_PASS \
  demo
openstack role create \
  user
openstack role add \
  --project demo \
  --user demo \
  user

unset OS_AUTH_URL OS_PASSWORD
openstack \
  --os-auth-url https://${CONTROLLER_FQDN}:5000/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name admin \
  --os-password $ADMIN_PASS \
  --os-username admin \
  token \
    issue
# openstack \
#   --os-auth-url http://${CONTROLLER_FQDN}:5000/v3 \
#   --os-project-domain-name Default \
#   --os-user-domain-name Default \
#   --os-project-name admin \
#   --os-password $ADMIN_PASS \
#   --os-username admin \
#   token \
#     issue
openstack \
  --os-auth-url https://${CONTROLLER_FQDN}:5000/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name demo \
  --os-username demo \
  --os-password $DEMO_PASS \
  token \
    issue
# openstack \
#   --os-auth-url http://${CONTROLLER_FQDN}:5000/v3 \
#   --os-project-domain-name Default \
#   --os-user-domain-name Default \
#   --os-project-name demo \
#   --os-username demo \
#   --os-password $DEMO_PASS \
#   token \
#     issue

cat << EOF | sudo tee /var/lib/openstack/admin-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
# cat << EOF | sudo tee /var/lib/openstack/admin-openrc
# export OS_PROJECT_DOMAIN_NAME=Default
# export OS_USER_DOMAIN_NAME=Default
# export OS_PROJECT_NAME=admin
# export OS_USERNAME=admin
# export OS_PASSWORD=$ADMIN_PASS
# export OS_AUTH_URL=http://${CONTROLLER_FQDN}:5000/v3
# export OS_IDENTITY_API_VERSION=3
# export OS_IMAGE_API_VERSION=2
# EOF

cat << EOF | sudo tee /var/lib/openstack/demo-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
# cat << EOF | sudo tee /var/lib/openstack/demo-openrc
# export OS_PROJECT_DOMAIN_NAME=Default
# export OS_USER_DOMAIN_NAME=Default
# export OS_PROJECT_NAME=demo
# export OS_USERNAME=demo
# export OS_PASSWORD=$DEMO_PASS
# export OS_AUTH_URL=http://${CONTROLLER_FQDN}:5000/v3
# export OS_IDENTITY_API_VERSION=3
# export OS_IMAGE_API_VERSION=2
# EOF
source <(sudo cat /var/lib/openstack/admin-openrc)

openstack token issue
