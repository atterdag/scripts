
#!/bin/bash
##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
openstack subnet create \
  --allocation-pool start=192.168.2.2,end=192.168.2.253 \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway 192.168.2.254 \
  --network autovoip \
  --subnet-range 192.168.2.0/24 \
  autovoip
openstack subnet create \
  --allocation-pool start=192.168.3.2,end=192.168.3.253 \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway 192.168.3.254 \
  --network autovideo \
  --subnet-range 192.168.3.0/24 \
  autovideo
openstack subnet create \
  --allocation-pool start=172.16.0.2,end=172.16.0.253 \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway 172.16.0.254 \
  --network servers \
  --subnet-range 172.16.0.0/24 \
  servers
openstack subnet create \
  --allocation-pool start=10.0.0.2,end=10.0.0.253 \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway 10.0.0.1 \
  --network dmz \
  --subnet-range 10.0.0.0/24 \
  dmz
openstack subnet create \
  --allocation-pool start=192.168.254.2,end=192.168.254.253 \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  --gateway 192.168.254.1 \
  --network routing \
  --subnet-range 192.168.254.0/24 \
  routing
