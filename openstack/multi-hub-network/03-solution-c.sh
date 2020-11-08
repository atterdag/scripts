# Create Solution C Hub

openstack project create \
  --description "Solution C" \
  --parent solutions \
  solution_c

openstack role add \
  --project solution_c \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --external \
  --no-default \
  --no-share \
  --project solution_c \
  solution_c_network_hub

openstack subnet create \
  --allocation-pool start=172.16.1.1,end=172.16.1.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.1.254 \
  --network solution_c_network_hub \
  --subnet-range 172.16.1.0/24 \
  --project solution_c \
  solution_c_subnet

openstack router create \
  --project solution_c \
  solution_c_router

openstack router add subnet \
  solution_c_router \
  solution_c_subnet

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.220 \
  solution_c_router

---

openstack project create \
  --description "Solution C TST" \
  --parent solution_c \
  solution_c_tst

openstack role add \
  --project solution_c_tst \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_c_tst \
  solution_c_network_vpc_tst

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_c_network_vpc_tst \
  --subnet-range 172.16.2.0/24 \
  --project solution_c_tst \
  solution_c_subnet_tst

openstack router create \
  --project solution_c_tst \
  solution_c_router_tst

openstack router add subnet \
  solution_c_router_tst \
  solution_c_subnet_tst

openstack router set \
  --external-gateway solution_c_network_hub \
  --fixed-ip subnet=solution_c_subnet,ip-address=172.16.1.30 \
  solution_c_router_tst

---

openstack project create \
  --description "Solution A QA" \
  --parent solution_c \
  solution_c_qa

openstack role add \
  --project solution_c_qa \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_c_qa \
  solution_c_network_vpc_qa

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_c_network_vpc_qa \
  --subnet-range 172.16.2.0/24 \
  --project solution_c_qa \
  solution_c_subnet_qa

openstack router create \
  --project solution_c_qa \
  solution_c_router_qa

openstack router add subnet \
  solution_c_router_qa \
  solution_c_subnet_qa

openstack router set \
  --external-gateway solution_c_network_hub \
  --fixed-ip subnet=solution_c_subnet,ip-address=172.16.1.40 \
  solution_c_router_qa
