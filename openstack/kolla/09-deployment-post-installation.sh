#!/bin/sh

echo '***'
echo '*** source in OS configuration'
echo '***'
echo "export OS_CACERT=/etc/ssl/certs/ca-certificates.crt" \
| sudo tee -a /etc/kolla/admin-openrc.sh
source /etc/kolla/admin-openrc.sh

echo '***'
echo '*** add additional cinder volume types'
echo '***'
openstack volume type create \
  --property volume_backend_name='premium' \
  premium
openstack volume type create \
  --property volume_backend_name='standard' \
  standard

echo '***'
echo '*** Retrieve cirros test image'
echo '***'
if [[ ! -d $OS_IMAGES_DIRECTORY ]]; then
  sudo mkdir -p $OS_IMAGES_DIRECTORY
fi

CIRROS_RELEASE=$(curl http://download.cirros-cloud.net/version/released)
sudo wget \
  --continue \
  --output-document=${OS_IMAGES_DIRECTORY}/cirros-${CIRROS_RELEASE}-x86_64-disk.img \
  http://download.cirros-cloud.net/${CIRROS_RELEASE}/cirros-${CIRROS_RELEASE}-x86_64-disk.img

openstack image create "cirros-${CIRROS_RELEASE}" \
  --file ${OS_IMAGES_DIRECTORY}/cirros-${CIRROS_RELEASE}-x86_64-disk.img \
  --disk-format qcow2 \
  --container-format bare \
  --public

openstack image list

echo '***'
echo '*** add default domain to designate'
echo '***'
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_DNS_REVERSE_ZONE}.

ZONE_ID=$(sudo grep id: /etc/kolla/config/designate-worker/pools.yaml | awk '{print $2}')
sudo mkdir -p /etc/kolla/config/designate/
cat <<EOF | sudo tee /etc/kolla/config/designate/designate-sink.conf
[handler:nova_fixed]
zone_id = $ZONE_ID
[handler:neutron_floatingip]
zone_id = $ZONE_ID
EOF
kolla-ansible --inventory /etc/kolla/inventory --tags designate,neutron,nova reconfigure

# cat <<EOF | sudo tee /etc/kolla/config/designate-worker/pools.yaml
# - name: default
#   description: Default BIND9 Pool
#   attributes: {}
#   ns_records:
#     - hostname: ${OS_DNS_DOMAIN}.
#       priority: 1
#   nameservers:
#     - host: ${OS_COMPUTE_IP_ADDRESS}
#       port: 53
#   targets:
#     - type: bind9
#       description: BIND9 Server ${OS_COMPUTE_IP_ADDRESS}
#       masters:
#         - host: ${OS_COMPUTE_IP_ADDRESS}
#           port: 5354
#       options:
#         host: ${OS_COMPUTE_IP_ADDRESS}
#         port: 53
#         rndc_host: ${OS_COMPUTE_IP_ADDRESS}
#         rndc_port: 953
#         rndc_key_file: /etc/designate/rndc.key
# EOF
# ssh ${OS_COMPUTE_IP_ADDRESS} sudo docker restart designate_worker
# ssh ${OS_COMPUTE_IP_ADDRESS} sudo docker exec -t designate_worker designate-manage pool update --file /etc/designate/pools.yaml

echo '***'
echo '*** create routing network provider'
echo '***'
openstack network create \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${OS_OS_COMPUTE_PROVIDER_VIRTUAL_NIC} \
  --provider-segment ${OS_PROVIDER_VLAN} \
  --share \
  ${OS_PROVIDER_NAME}

openstack subnet create \
  --allocation-pool start=${OS_PROVIDER_ALLOCATION_START},end=${OS_PROVIDER_ALLOCATION_STOP} \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway ${OS_PROVIDER_GATEWAY} \
  --network ${OS_PROVIDER_NAME} \
  --subnet-range ${OS_PROVIDER_NETWORK_CIDR} \
  ${OS_PROVIDER_NAME}

echo '***'
echo '*** Routing to subnet of vxlan network'
echo '***'
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_HUB_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_HUB_DNS_REVERSE_ZONE}.

openstack network create \
  --dns-domain ${OS_HUB_DNS_DOMAIN}. \
  --external \
  --tag hub \
  ${OS_HUB_NETWORK_NAME}

openstack subnet create \
  --allocation-pool start=${OS_HUB_ALLOCATION_START},end=${OS_HUB_ALLOCATION_STOP} \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway ${OS_HUB_GATEWAY} \
  --network ${OS_HUB_NETWORK_NAME} \
  --subnet-range ${OS_HUB_NETWORK_CIDR} \
  --tag hub \
  ${OS_HUB_NETWORK_NAME}

openstack router create \
  --tag hub \
  ${OS_HUB_NETWORK_NAME}

openstack router add subnet \
  ${OS_HUB_NETWORK_NAME} \
  ${OS_HUB_NETWORK_NAME}

openstack router set \
  --external-gateway ${OS_PROVIDER_NAME} \
  --disable-snat \
  --fixed-ip subnet=${OS_PROVIDER_NAME},ip-address=${OS_PROVIDER_ROUTER_IP_ADDRESS} \
  ${OS_HUB_NETWORK_NAME}

# Add static routes on routers in infrastructure
# Network Address: 10.0.0.0
# Subnet Mask: 255.255.255.0
# Next Hop IP Address: 192.168.254.10
# Preference: 1

ping \
  -c 4 \
  ${OS_PROVIDER_ROUTER_IP_ADDRESS}

##############################################################################
# Create flavors on Controller host
##############################################################################
openstack flavor create \
  --disk 1 \
  --public \
  --ram 128 \
  --vcpus 1 \
  --property hw:cpu_policy=shared \
  --property hw:cpu_cores=1 \
  --property hw:cpu_sockets=1 \
  --property hw:cpu_threads=1 \
  m1.tiny
openstack flavor create \
  --disk 5 \
  --public \
  --ram 256 \
  --vcpus 1 \
  --property hw:cpu_policy=shared \
  m1.small
openstack flavor create \
  --disk 5 \
  --public \
  --ram 512 \
  --vcpus 2 \
  --property hw:cpu_policy=shared \
  m1.medium
openstack flavor create \
  --disk 5 \
  --public \
  --ram 1024 \
  --vcpus 2 \
  --property hw:cpu_policy=shared \
  m1.large
openstack flavor create \
  --disk 5 \
  --public \
  --ram 2048 \
  --vcpus 4 \
  --property hw:cpu_policy=shared \
  m1.huge

##############################################################################
# Create default security on Controller host
##############################################################################
# The default group is created for all projects, but that means that you
# cannot just refer to it by its name, because there are multiple default
# groups. So to workaround that, just create a global default group that will
# have a unique name.
openstack security group create \
  --description "Global default rule" \
  global_default
openstack security group rule create \
  --ingress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  global_default
openstack security group rule create \
  --ingress \
  --ethertype IPv6 \
  --remote-ip "::/0" \
  global_default
openstack security group rule create \
  --proto icmp \
  global_default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  global_default

openstack security group create \
  --description "DHCP client" \
  dhcp_client
openstack security group rule create \
  --egress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  --proto udp \
  --dst-port 67 \
  dhcp_client
openstack security group rule create \
  --ingress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  --proto udp \
  --dst-port 68 \
  dhcp_client

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

openstack server create \
  --flavor m1.tiny \
  --image cirros-${CIRROS_RELEASE} \
  --key-name default \
  --nic net-id=${OS_HUB_NETWORK_NAME} \
  --security-group global_default \
  --wait \
  ${OS_HUB_NETWORK_NAME}

ping \
  -c 4 \
  $(openstack server show -c addresses -f value ${OS_HUB_NETWORK_NAME} | cut -d '=' -f 2)

ssh cirros@$(openstack server show -c addresses -f value ${OS_HUB_NETWORK_NAME} | cut -d '=' -f 2)

echo '***'
echo '*** Create spoke network'
echo '***'
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_SPOKE_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_SPOKE_DNS_REVERSE_ZONE}.

openstack network create \
  --dns-domain ${OS_SPOKE_DNS_DOMAIN}. \
  --internal \
  --no-default \
  --no-share \
  --tag spoke \
  ${OS_SPOKE_NETWORK_NAME}

openstack subnet create \
  --allocation-pool start=${OS_SPOKE_ALLOCATION_START},end=${OS_SPOKE_ALLOCATION_STOP} \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway ${OS_SPOKE_GATEWAY} \
  --network ${OS_SPOKE_NETWORK_NAME} \
  --subnet-range ${OS_SPOKE_NETWORK_CIDR} \
  --tag ${OS_SPOKE_NETWORK_NAME} \
  ${OS_SPOKE_NETWORK_NAME}

openstack router create \
  --tag spoke \
  ${OS_SPOKE_NETWORK_NAME}

openstack router add subnet \
  ${OS_SPOKE_NETWORK_NAME} \
  ${OS_SPOKE_NETWORK_NAME}

openstack router set \
  --enable-snat \
  --external-gateway ${OS_HUB_NETWORK_NAME} \
  --fixed-ip subnet=${OS_HUB_NETWORK_NAME},ip-address=10.0.0.30 \
  ${OS_SPOKE_NETWORK_NAME}

openstack server create \
  --flavor m1.tiny \
  --image cirros-${CIRROS_RELEASE} \
  --key-name default \
  --nic net-id=${OS_SPOKE_NETWORK_NAME} \
  --security-group global_default \
  --wait \
  ${OS_SPOKE_NETWORK_NAME}

openstack floating ip create \
  --floating-ip-address ${OS_SPOKE_FLOATING_IP_ADDRESS} \
  --description "spoke jumpserver" \
  --tag spoke \
  ${OS_HUB_NETWORK_NAME}

openstack server add floating ip \
  ${OS_SPOKE_NETWORK_NAME} \
  ${OS_SPOKE_FLOATING_IP_ADDRESS}

ping \
  -c 4 \
  ${OS_SPOKE_FLOATING_IP_ADDRESS}

ssh cirros@${OS_SPOKE_FLOATING_IP_ADDRESS}

echo '***'
echo '*** In case we just want to run a test configuration'
echo '***'
${VIRTUAL_ENV}/share/kolla-ansible/init-runonce

echo '***'
echo '*** connect to OpenStack as the octavia service user'
echo '***'
cat << EOF >> $HOME/octavia-openrc
export OS_PROJECT_NAME=service
export OS_USERNAME=octavia
export OS_PASSWORD=$OCTAVIA_PASS
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=3
EOF
source $HOME/octavia-openrc

echo '***'
echo '*** create amphora image'
echo '***'
openstack image create \
  --disk-format qcow2 \
  --container-format bare \
  --tag octavia-amphora-image \
  --file $HOME/amphora-x64-haproxy.qcow2 \
  --private \
  --project service amphora-x64-haproxy

echo '***'
echo '*** create amphora flavor'
echo '***'
openstack loadbalancer flavor create \
  --id 200 \
  --vcpus 1 \
  --ram 1024 \
  --disk 2 \
  --private \
  "amphora"

openstack security group create \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol icmp \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol tcp \
  --dst-port 22 \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol tcp \
  --dst-port 9443 \
  lb-mgmt-sec-grp
openstack security group create \
  lb-health-mgr-sec-grp
openstack security group rule create \
  --protocol udp \
  --dst-port 5555 \
  lb-health-mgr-sec-grp
