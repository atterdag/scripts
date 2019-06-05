#!/bin/sh

##############################################################################
# Import environment variables, and passwords
##############################################################################
source <(sudo cat /var/lib/openstack/admin-openrc)
source <(sudo cat /var/lib/openstack/os_password.env)
source <(sudo cat /var/lib/openstack/os_environment.env)

##############################################################################
# Create VLAN network on Controller host
##############################################################################
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 1 \
  --share \
  default
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 5 \
  --share \
  servers
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 6 \
  --share \
  dmz
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 4 \
  --share \
  outside

##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
openstack subnet create \
  --allocation-pool start=192.168.1.129,end=192.168.1.196 \
  --dns-nameserver 192.168.1.40 \
  --gateway 192.168.1.254 \
  --ip-version 4 \
  --network default \
  --no-dhcp \
  --subnet-range 192.168.1.0/24 \
  default
openstack subnet create \
  --allocation-pool start=172.16.0.2,end=172.16.0.253 \
  --dhcp \
  --dns-nameserver 192.168.1.40 \
  --gateway 172.16.0.254 \
  --ip-version 4 \
  --network servers \
  --subnet-range 172.16.0.0/24 \
  servers
openstack subnet create \
  --allocation-pool start=10.0.0.2,end=10.0.0.253 \
  --dns-nameserver 192.168.1.40 \
  --gateway 10.0.0.254 \
  --ip-version 4 \
  --network dmz \
  --no-dhcp \
  --subnet-range 10.0.0.0/24 \
  dmz

##############################################################################
# Create DNS zones
##############################################################################
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  servers.${DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  dmz.${DNS_DOMAIN}.

openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  1.168.192.in-addr.arpa.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  0.16.172.in-addr.arpa.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  0.0.10.in-addr.arpa.

##############################################################################
# Create a fixed IP ports on Controller host
##############################################################################
openstack port create \
  --fixed-ip ip-address=192.168.1.130 \
  --network default \
  test2_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.130 \
  --network servers \
  test2_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.130 \
  --network dmz \
  test2_dmz

##############################################################################
# Create DNZ records for test2
##############################################################################
openstack recordset create \
  --record '192.168.1.130' \
  --type A ${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.se.lemche.net.' \
  --type PTR 1.168.192.in-addr.arpa. \
  130
openstack recordset create \
  --record '172.16.0.130' \
  --type A servers.${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.servers.se.lemche.net.' \
  --type PTR 0.16.172.in-addr.arpa. \
  130
openstack recordset create \
  --record '10.0.0.130' \
  --type A dmz.${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.dmz.se.lemche.net.' \
  --type PTR 0.0.10.in-addr.arpa. \
  130

##############################################################################
# Create default SSH key on Controller host if you don't want to forward one
##############################################################################
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  default

##############################################################################
# Create default security on Controller host
##############################################################################
openstack security group rule create \
  --proto icmp \
  default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  default

##############################################################################
# Create Debian Jessie amd64 images on Controller host
##############################################################################
apt-get --yes install openstack-debian-images
# add packages
# qemu-guest-agent
# cloud-init

pushd .
cd /var/lib/openstack/
ROOT_PASSWORD=$(apg -m 8 -q -n 1 -a 1 -M NCL)
build-openstack-debian-image \
  --release jessie \
  --minimal \
  --automatic-resize \
  --password $ROOT_PASSWORD \
  --architecture amd64
DEBIAN_IMAGE=$(ls -1 debian-jessie-*-amd64.raw | tail -1 | sed 's|\.raw||')
qemu-img convert -f raw -O qcow2 ${DEBIAN_IMAGE}.raw ${DEBIAN_IMAGE}.qcow2
echo $ROOT_PASSWORD > ${DEBIAN_IMAGE}.rootpw
popd

openstack image create \
  --file /var/lib/openstack/${DEBIAN_IMAGE}.qcow2 \
  --disk-format qcow2 \
  --container-format bare \
  --public \
  debian-8-openstack-amd64

##############################################################################
# Create debian-stretch-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=/var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  http://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2

sudo -E openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file /var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  --public \
  debian-9-openstack-amd64

##############################################################################
# Create flavor on Controller host
##############################################################################
openstack flavor create \
  --disk 1 \
  --public \
  --ram 56 \
  --vcpus 1 \
  m1.tiny
openstack flavor create \
  --disk 1 \
  --public \
  --ram 128 \
  --vcpus 1 \
  m1.small
openstack flavor create \
  --disk 5 \
  --public \
  --ram 256 \
  --vcpus 1 \
  m1.medium
openstack flavor create \
  --disk 10 \
  --public \
  --ram 512 \
  --vcpus 1 \
  m1.large
openstack flavor create \
  --disk 10 \
  --public \
  --ram 1024 \
  --vcpus 2 \
  m1.huge

##############################################################################
# Create volume template on Controller host
##############################################################################
openstack volume create \
  --description 'debian-9-openstack-amd64 template volume' \
  --image debian-9-openstack-amd64 \
  --size 5 \
  --type standard \
  debian-9-openstack-amd64

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack subnet list
openstack security group list
openstack port list
openstack zone list
openstack recordset list ${DNS_DOMAIN}.
openstack recordset list 1.168.192.in-addr.arpa.
openstack recordset list servers.${DNS_DOMAIN}.
openstack recordset list 0.16.172.in-addr.arpa.
openstack recordset list dmz.${DNS_DOMAIN}.
openstack recordset list 0.0.10.in-addr.arpa.
openstack volume type list
openstack volume list

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.small \
  --image cirros-0.4.0 \
  --key-name default \
  --nic net-id=servers \
  --security-group default \
  test1

openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic port-id=test2_inside \
  --nic port-id=test2_servers \
  --security-group default \
  test2

openstack server show \
  test1
openstack server show \
  test2
##############################################################################
# Get URL for connecting to server instance on Controller host
##############################################################################
openstack console url show \
  test1
openstack console url show \
  test2

##############################################################################
# Attach ports with fixed IP to existing server instance on Controller host
##############################################################################
export $(openstack port show test2_dmz -f shell -c id | sed 's|"||g')
nova interface-attach \
  --port-id $id \
  test2

##############################################################################
# Create volumes on Controller host
##############################################################################
openstack volume create \
  --description 'test2 database volume' \
  --size 10 \
  --type premium \
  test2_database
openstack server add volume \
  test2 \
  test2_database

openstack volume create \
--description 'test2 files volume' \
--size 10 \
--type standard \
test2_files
openstack server add volume \
  test2 \
  test2_files
