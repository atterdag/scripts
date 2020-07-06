#!/bin/sh

echo '***'
echo '*** create kolla inventory templates'
echo '***'
cp \
  ${VIRTUAL_ENV}/share/kolla-ansible/ansible/inventory/* \
  /etc/kolla/

echo '***'
echo '*** deploy openstack kolla'
echo '***'
kolla-ansible \
  --inventory /etc/kolla/all-in-one \
  bootstrap-servers \
&& kolla-ansible \
  --inventory /etc/kolla/all-in-one \
  prechecks \
&& kolla-ansible \
  --inventory /etc/kolla/all-in-one \
  deploy \
&& kolla-ansible \
  --inventory /etc/kolla/all-in-one \
  post-deploy

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
echo '*** add default domain to designate'
echo '***'
ZONE_ID=$(sudo grep id: /etc/kolla/designate-worker/pools.yaml | awk '{print $2}')
sudo mkdir -p /etc/kolla/config/designate/
cat <<EOF | sudo tee /etc/kolla/config/designate/designate-sink.conf
[handler:nova_fixed]
zone_id = $ZONE_ID
[handler:neutron_floatingip]
zone_id = $ZONE_ID
EOF
kolla-ansible --inventory /etc/kolla/all-in-one --tags designate,neutron,nova reconfigure

cat <<EOF | sudo tee /etc/kolla/designate-worker/pools.yaml
- name: default
  description: Default BIND9 Pool
  attributes: {}
  ns_records:
    - hostname: ${OS_DNS_DOMAIN}.
      priority: 1
  nameservers:
    - host: $(hostname -i)
      port: 53
  targets:
    - type: bind9
      description: BIND9 Server $(hostname -i)
      masters:
        - host: $(hostname -i)
          port: 5354
      options:
        host: $(hostname -i)
        port: 53
        rndc_host: $(hostname -i)
        rndc_port: 953
        rndc_key_file: /etc/designate/rndc.key
EOF
docker restart designate_worker
docker exec -t designate_worker designate-manage pool update --file /etc/designate/pools.yaml
openstack zone create \
  --email hostmaster@${OS_DNS_DOMAIN} \
  ${OS_DNS_DOMAIN}.

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
openstack flavor create \
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
