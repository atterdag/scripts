openstack network create \
  --internal \
  testvxlan

openstack subnet create \
  --allocation-pool start=192.168.11.129,end=192.168.11.196 \
  --dns-nameserver ${DNS_ONE_IP_ADDRESS} \
  --dns-nameserver ${DNS_TWO_IP_ADDRESS} \
  --gateway 192.168.11.254 \
  --network testvxlan \
  --subnet-range 192.168.11.0/24 \
  testvxlan

openstack router create \
  testvxlan

openstack router add subnet \
  testvxlan \
  testvxlan

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.252 \
  testvxlan

openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=testvxlan \
  --security-group global_default \
  --wait \
  testvxlan

# Add static routes on routers in infrastructure
# Network Address: 192.168.11.0
# Subnet Mask: 255.255.255.0
# Next Hop IP Address: 192.168.254.252
# Preference: 1

ping \
  -c 4 \
  $(openstack server show -c addresses -f value testvxlan | cut -d '=' -f 2)
