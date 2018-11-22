#!/bin/sh

##############################################################################
# Create VLAN network on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network bond0 \
  --provider-segment 1 \
  --share \
  inside
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network bond0 \
  --provider-segment 2 \
  --share \
  servers
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network bond0 \
  --provider-segment 3 \
  --share \
  dmz
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network bond0 \
  --provider-segment 4 \
  --share \
  outside

openstack network set \
  --default \
  servers

openstack network list

##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
openstack subnet create \
  --allocation-pool start=192.168.1.129,end=192.168.1.196 \
  --dns-nameserver 192.168.1.40 \
  --gateway 192.168.1.254 \
  --ip-version 4 \
  --network inside \
  --no-dhcp \
  --subnet-range 192.168.1.0/24 \
  inside
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

openstack subnet list

##############################################################################
# Create a fixed IP ports on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack port create \
  --fixed-ip ip-address=192.168.1.30 \
  --network inside \
  debian_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.30 \
  --network servers \
  debian_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.30 \
  --network dmz \
  debian_dmz

openstack port create \
  --fixed-ip ip-address=192.168.1.129 \
  --network inside \
  firewall_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.129 \
  --network servers \
  firewall_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.129 \
  --network dmz \
  firewall_dmz

##############################################################################
# Create default SSH key on Controller host
##############################################################################
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  default

##############################################################################
# Create default security on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
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

source /var/lib/openstack/admin-openrc
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
wget \
  --continue \
  --output-document=/var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  http://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2

source /var/lib/openstack/admin-openrc
openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file /var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  --public \
  debian-9-openstack-amd64

##############################################################################
# Create flavor to support debian-jessie-amd64 images on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack flavor create \
  --disk 5 \
  --public \
  --ram 512 \
  --vcpus 2 \
  m1.medium

##############################################################################
# Create volume type on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack volume type create \
  --description 'High speed storage type' \
  --public \
  premium

##############################################################################
# Create volume template on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack volume create \
  --description 'debian-9-openstack-amd64 template volume' \
  --image debian-9-openstack-amd64 \
  --size 5 \
  --type premium \
  debian-9-openstack-amd64

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack subnet list
openstack security group list
openstack port list
openstack volume type list
openstack volume list

##############################################################################
# Create debian server instance on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic net-id=servers \
  --security-group default \
  debian9

openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic port-id=debian_inside \
  --nic port-id=debian_servers \
  --nic port-id=debian_dmz \
  --security-group default \
  debian

openstack server create \
  --flavor m1.medium \
  --key-name default \
  --nic port-id=firewall_inside \
  --nic port-id=firewall_servers \
  --nic port-id=firewall_dmz \
  --nic net-id=outside \
  --security-group default \
  --volume debian-9-openstack-amd64 \
  firewall

openstack server create \
  --flavor m1.medium \
  --key-name default \
  --nic net-id=inside \
  --security-group default \
  --image debian-9-openstack-amd64\
  test

openstack server show test
##############################################################################
# Get URL for connecting to server instance on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack console url show \
  debian9

openstack console url show \
  debian

openstack console url show \
  firewall

openstack console url show \
  test

##############################################################################
# Attach ports with fixed IP to server instance on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
nova interface-attach --port-id debian_dmz debian
nova interface-attach --port-id debian_servers debian

##############################################################################
# Server instance on Controller host
##############################################################################
source /var/lib/openstack/demo-openrc
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  mykey
openstack security group rule create \
  --proto icmp \
  default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  default
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack port list
openstack security group list
openstack port create \
  --fixed-ip ip-address=172.16.0.20 \
  --network servers \
  servers
openstack server create \
  --flavor m1.nano \
  --image cirros-0.4.0 \
  --nic port-id=cirros-0.4.0 \
  --security-group default \
  --key-name mykey \
  cirros-0.4.0
openstack server list
openstack console url show cirros-0.4.0

openstack server create \
  --flavor m1.medium \
  --image debian-8-openstack-amd64 \
  --key-name default \
  --nic net-id=servers \
  --security-group default \
  debian8
openstack server show \
  debian8
openstack console url show \
  debian8
