openstack project create \
  --description "Solution A" \
  --parent solutions \
  solution_a

openstack role add \
  --project solution_a \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --external \
  --no-default \
  --no-share \
  --project solution_a \
  solution_a_network_hub

openstack subnet create \
  --allocation-pool start=172.16.1.1,end=172.16.1.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.1.254 \
  --network solution_a_network_hub \
  --subnet-range 172.16.1.0/24 \
  --project solution_a \
  solution_a_subnet

openstack router create \
  --project solution_a \
  solution_a_router

openstack router add subnet \
  solution_a_router \
  solution_a_subnet

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.20 \
  solution_a_router

# ----------------------------------------------------------------------------

openstack project create \
  --description "Solution A TST" \
  --parent solution_a \
  solution_a_tst

openstack role add \
  --project solution_a_tst \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_a_tst \
  solution_a_network_vpc_tst

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_a_network_vpc_tst \
  --subnet-range 172.16.2.0/24 \
  --project solution_a_tst \
  solution_a_subnet_tst

openstack router create \
  --project solution_a_tst \
  solution_a_router_tst

openstack router add subnet \
  solution_a_router_tst \
  solution_a_subnet_tst

openstack router set \
  --external-gateway solution_a_network_hub \
  --fixed-ip subnet=solution_a_subnet,ip-address=172.16.1.30 \
  solution_a_router_tst

# ----------------------------------------------------------------------------

openstack project create \
  --description "Solution A QA" \
  --parent solution_a \
  solution_a_qa

openstack role add \
  --project solution_a_qa \
  --user solutions_admin \
  admin

openstack user create \
  --project solution_a_qa \
  --password passw0rd \
  solution_a_qa_admin

openstack role add \
  --project solution_a_qa \
  --user solution_a_qa_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_a_qa \
  solution_a_network_vpc_qa

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_a_network_vpc_qa \
  --subnet-range 172.16.2.0/24 \
  --project solution_a_qa \
  solution_a_subnet_qa

openstack router create \
  --project solution_a_qa \
  solution_a_router_qa

openstack router add subnet \
  solution_a_router_qa \
  solution_a_subnet_qa

openstack router set \
  --external-gateway solution_a_network_hub \
  --fixed-ip subnet=solution_a_subnet,ip-address=172.16.1.40 \
  solution_a_router_qa

cat > ~/os_solution_a_qa.sh <<EOF
for key in \$( set | awk '{FS="="}  /^OS_/ {print \$1}' ); do unset \$key ; done
export OS_AUTH_PLUGIN=password
export OS_AUTH_URL=https://openstack.se.lemche.net:35357/v3
export OS_CACERT=/etc/ssl/certs/ca-certificates.crt
export OS_ENDPOINT_TYPE=internalURL
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=internal
export OS_PASSWORD=passw0rd
export OS_PLACEMENT_API_VERSION=1.28
export OS_PROJECT_DOMAIN_NAME=Default
export OS_PROJECT_NAME=solution_a_qa
export OS_REGION_NAME=RegionOne
export OS_TENANT_NAME=solution_a_qa
export OS_USER_DOMAIN_NAME=Default
export OS_USERNAME=solution_a_qa_admin
EOF
source ~/os_solution_a_qa.sh

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
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=solution_a_network_vpc_qa \
  --wait \
  solution_a_server_qa

openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=solution_a_network_vpc_qa \
  --wait \
  solution_a_loadbalancer_qa

openstack floating ip create \
  --floating-ip-address 172.16.1.21 \
  solution_a_network_hub

openstack server add floating ip \
  solution_a_loadbalancer_qa \
  172.16.1.21

ping \
  -c 4 \
  192.168.254.88
