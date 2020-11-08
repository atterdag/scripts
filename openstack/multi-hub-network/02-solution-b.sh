---

openstack project create \
  --description "Solution B" \
  --parent solutions \
  solution_b

openstack role add \
  --project solution_b \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --external \
  --no-default \
  --no-share \
  --project solution_b \
  solution_b_network_hub

openstack subnet create \
  --allocation-pool start=172.16.1.1,end=172.16.1.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.1.254 \
  --network solution_b_network_hub \
  --subnet-range 172.16.1.0/24 \
  --project solution_b \
  solution_b_subnet

openstack router create \
  --project solution_b \
  solution_b_router

openstack router add subnet \
  solution_b_router \
  solution_b_subnet

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.120 \
  solution_b_router

---

openstack project create \
  --description "Solution A TST" \
  --parent solution_b \
  solution_b_tst

openstack role add \
  --project solution_b_tst \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_b_tst \
  solution_b_network_vpc_tst

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_b_network_vpc_tst \
  --subnet-range 172.16.2.0/24 \
  --project solution_b_tst \
  solution_b_subnet_tst

openstack router create \
  --project solution_b_tst \
  solution_b_router_tst

openstack router add subnet \
  solution_b_router_tst \
  solution_b_subnet_tst

openstack router set \
  --external-gateway solution_b_network_hub \
  --fixed-ip subnet=solution_b_subnet,ip-address=172.16.1.30 \
  solution_b_router_tst

---

openstack project create \
  --description "Solution A QA" \
  --parent solution_b \
  solution_b_qa

openstack role add \
  --project solution_b_qa \
  --user solutions_admin \
  admin

openstack network create \
  --dns-domain os.se.lemche.net. \
  --internal \
  --no-default \
  --no-share \
  --project solution_b_qa \
  solution_b_network_vpc_qa

openstack subnet create \
  --allocation-pool start=172.16.2.1,end=172.16.2.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 172.16.2.254 \
  --network solution_b_network_vpc_qa \
  --subnet-range 172.16.2.0/24 \
  --project solution_b_qa \
  solution_b_subnet_qa

openstack router create \
  --project solution_b_qa \
  solution_b_router_qa

openstack router add subnet \
  solution_b_router_qa \
  solution_b_subnet_qa

openstack router set \
  --external-gateway solution_b_network_hub \
  --fixed-ip subnet=solution_b_subnet,ip-address=172.16.1.40 \
  solution_b_router_qa
