#!/bin/bash

mkdir -p $HOME/.config/openstack
cat <<EOF | tee $HOME/.config/openstack/clouds.yaml
clouds:
  k8s_project:
    cacert: "/etc/ssl/certs/ca-certificates.crt"
    auth:
      auth_url: https://openstack.se.lemche.net:5000/v3
      username: "k8sadmin"
      project_name: "k8s_project"
      password: passw0rd
      user_domain_name: "Default"
    region_name: "RegionOne"
    interface: "public"
    identity_api_version: 3
    operation_log:
      logging: TRUE
      file: openstack_client.log
      level: debug
EOF
openstack --os-cloud=k8s_project project list
