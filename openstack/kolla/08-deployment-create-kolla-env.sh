#!/bin/sh

echo '***'
echo '*** create kolla inventory templates'
echo '***'
cp \
  ${VIRTUAL_ENV}/share/kolla-ansible/ansible/inventory/* \
  /etc/kolla/

cat > /etc/kolla/inventory <<EOF
${CONTROLLER_FQDN} ansible_host=${CONTROLLER_IP_ADDRESS} ansible_user=${DEPLOY_USER_NAME}
${COMPUTE_FQDN} ansible_host=${COMPUTE_IP_ADDRESS} ansible_user=${DEPLOY_USER_NAME}

[control]
${COMPUTE_FQDN}

[network]
${COMPUTE_FQDN}

[compute]
${COMPUTE_FQDN}

[monitoring]
${CONTROLLER_FQDN}

[storage]
${COMPUTE_FQDN}

[deployment]
localhost       ansible_connection=local

[baremetal:children]
control
network
compute
storage
monitoring

[tls-backend:children]
control

# You can explicitly specify which hosts run each project by updating the
# groups in the sections below. Common services are grouped together.

[common:children]
control
network
compute
storage
monitoring

[chrony-server:children]
haproxy

[chrony:children]
control
network
compute
storage
monitoring

[collectd:children]
compute

[grafana:children]
monitoring

[etcd:children]
control

[influxdb:children]
monitoring

[prometheus:children]
monitoring

[kafka:children]
control

[karbor:children]
control

[kibana:children]
control

[telegraf:children]
compute
control
monitoring
network
storage

[elasticsearch:children]
control

[haproxy:children]
network

[mariadb:children]
control

[rabbitmq:children]
control

[outward-rabbitmq:children]
control

[qdrouterd:children]
control

[monasca-agent:children]
compute
control
monitoring
network
storage

[monasca:children]
monitoring

[storm:children]
monitoring

[keystone:children]
control

[glance:children]
control

[nova:children]
control

[neutron:children]
network

[openvswitch:children]
network
compute
manila-share

[cinder:children]
control

[cloudkitty:children]
control

[freezer:children]
control

[memcached:children]
control

[horizon:children]
control

[swift:children]
control

[barbican:children]
control

[heat:children]
control

[murano:children]
control

[solum:children]
control

[ironic:children]
control

[magnum:children]
control

[qinling:children]
control

[sahara:children]
control

[mistral:children]
control

[manila:children]
control

[ceilometer:children]
control

[aodh:children]
control

[cyborg:children]
control
compute

[panko:children]
control

[gnocchi:children]
control

[tacker:children]
control

[trove:children]
control

# Tempest
[tempest:children]
control

[senlin:children]
control

[vmtp:children]
control

[vitrage:children]
control

[watcher:children]
control

[rally:children]
control

[searchlight:children]
control

[octavia:children]
control

[designate:children]
control

[placement:children]
control

[bifrost:children]
deployment

[zookeeper:children]
control

[zun:children]
control

[skydive:children]
monitoring

[redis:children]
control

[blazar:children]
control

# Additional control implemented here. These groups allow you to control which
# services run on which hosts at a per-service level.
#
# Word of caution: Some services are required to run on the same host to
# function appropriately. For example, neutron-metadata-agent must run on the
# same host as the l3-agent and (depending on configuration) the dhcp-agent.

# Common
[cron:children]
common

[fluentd:children]
common

[kolla-logs:children]
common

[kolla-toolbox:children]
common

# Elasticsearch Curator
[elasticsearch-curator:children]
elasticsearch

# Glance
[glance-api:children]
glance

# Nova
[nova-api:children]
nova

[nova-conductor:children]
nova

[nova-super-conductor:children]
nova

[nova-novncproxy:children]
nova

[nova-scheduler:children]
nova

[nova-spicehtml5proxy:children]
nova

[nova-compute-ironic:children]
nova

[nova-serialproxy:children]
nova

# Neutron
[neutron-server:children]
control

[neutron-dhcp-agent:children]
neutron

[neutron-l3-agent:children]
neutron

[neutron-metadata-agent:children]
neutron

[neutron-ovn-metadata-agent:children]
compute

[neutron-bgp-dragent:children]
neutron

[neutron-infoblox-ipam-agent:children]
neutron

[neutron-metering-agent:children]
neutron

[ironic-neutron-agent:children]
neutron

# Cinder
[cinder-api:children]
cinder

[cinder-backup:children]
storage

[cinder-scheduler:children]
cinder

[cinder-volume:children]
storage

# Cloudkitty
[cloudkitty-api:children]
cloudkitty

[cloudkitty-processor:children]
cloudkitty

# Freezer
[freezer-api:children]
freezer

[freezer-scheduler:children]
freezer

# iSCSI
[iscsid:children]
compute
storage
ironic

[tgtd:children]
storage

# Karbor
[karbor-api:children]
karbor

[karbor-protection:children]
karbor

[karbor-operationengine:children]
karbor

# Manila
[manila-api:children]
manila

[manila-scheduler:children]
manila

[manila-share:children]
network

[manila-data:children]
manila

# Swift
[swift-proxy-server:children]
swift

[swift-account-server:children]
storage

[swift-container-server:children]
storage

[swift-object-server:children]
storage

# Barbican
[barbican-api:children]
barbican

[barbican-keystone-listener:children]
barbican

[barbican-worker:children]
barbican

# Heat
[heat-api:children]
heat

[heat-api-cfn:children]
heat

[heat-engine:children]
heat

# Murano
[murano-api:children]
murano

[murano-engine:children]
murano

# Monasca
[monasca-agent-collector:children]
monasca-agent

[monasca-agent-forwarder:children]
monasca-agent

[monasca-agent-statsd:children]
monasca-agent

[monasca-api:children]
monasca

[monasca-grafana:children]
monasca

[monasca-log-transformer:children]
monasca

[monasca-log-persister:children]
monasca

[monasca-log-metrics:children]
monasca

[monasca-thresh:children]
monasca

[monasca-notification:children]
monasca

[monasca-persister:children]
monasca

# Storm
[storm-worker:children]
storm

[storm-nimbus:children]
storm

# Ironic
[ironic-api:children]
ironic

[ironic-conductor:children]
ironic

[ironic-inspector:children]
ironic

[ironic-pxe:children]
ironic

[ironic-ipxe:children]
ironic

# Magnum
[magnum-api:children]
magnum

[magnum-conductor:children]
magnum

# Qinling
[qinling-api:children]
qinling

[qinling-engine:children]
qinling

# Sahara
[sahara-api:children]
sahara

[sahara-engine:children]
sahara

# Solum
[solum-api:children]
solum

[solum-worker:children]
solum

[solum-deployer:children]
solum

[solum-conductor:children]
solum

[solum-application-deployment:children]
solum

[solum-image-builder:children]
solum

# Mistral
[mistral-api:children]
mistral

[mistral-executor:children]
mistral

[mistral-engine:children]
mistral

[mistral-event-engine:children]
mistral

# Ceilometer
[ceilometer-central:children]
ceilometer

[ceilometer-notification:children]
ceilometer

[ceilometer-compute:children]
compute

[ceilometer-ipmi:children]
compute

# Aodh
[aodh-api:children]
aodh

[aodh-evaluator:children]
aodh

[aodh-listener:children]
aodh

[aodh-notifier:children]
aodh

# Cyborg
[cyborg-api:children]
cyborg

[cyborg-agent:children]
compute

[cyborg-conductor:children]
cyborg

# Panko
[panko-api:children]
panko

# Gnocchi
[gnocchi-api:children]
gnocchi

[gnocchi-statsd:children]
gnocchi

[gnocchi-metricd:children]
gnocchi

# Trove
[trove-api:children]
trove

[trove-conductor:children]
trove

[trove-taskmanager:children]
trove

# Multipathd
[multipathd:children]
compute
storage

# Watcher
[watcher-api:children]
watcher

[watcher-engine:children]
watcher

[watcher-applier:children]
watcher

# Senlin
[senlin-api:children]
senlin

[senlin-conductor:children]
senlin

[senlin-engine:children]
senlin

[senlin-health-manager:children]
senlin

# Searchlight
[searchlight-api:children]
searchlight

[searchlight-listener:children]
searchlight

# Octavia
[octavia-api:children]
octavia

[octavia-health-manager:children]
octavia

[octavia-housekeeping:children]
octavia

[octavia-worker:children]
octavia

# Designate
[designate-api:children]
designate

[designate-central:children]
designate

[designate-producer:children]
designate

[designate-mdns:children]
network

[designate-worker:children]
designate

[designate-sink:children]
designate

[designate-backend-bind9:children]
designate

# Placement
[placement-api:children]
placement

# Zun
[zun-api:children]
zun

[zun-wsproxy:children]
zun

[zun-compute:children]
compute

[zun-cni-daemon:children]
compute

# Skydive
[skydive-analyzer:children]
skydive

[skydive-agent:children]
compute
network

# Tacker
[tacker-server:children]
tacker

[tacker-conductor:children]
tacker

# Vitrage
[vitrage-api:children]
vitrage

[vitrage-notifier:children]
vitrage

[vitrage-graph:children]
vitrage

[vitrage-ml:children]
vitrage

[vitrage-persistor:children]
vitrage

# Blazar
[blazar-api:children]
blazar

[blazar-manager:children]
blazar

# Prometheus
[prometheus-node-exporter:children]
monitoring
control
compute
network
storage

[prometheus-mysqld-exporter:children]
mariadb

[prometheus-haproxy-exporter:children]
haproxy

[prometheus-memcached-exporter:children]
memcached

[prometheus-cadvisor:children]
monitoring
control
compute
network
storage

[prometheus-alertmanager:children]
monitoring

[prometheus-openstack-exporter:children]
monitoring

[prometheus-elasticsearch-exporter:children]
elasticsearch

[prometheus-blackbox-exporter:children]
monitoring

[masakari-api:children]
control

[masakari-engine:children]
control

[masakari-monitors:children]
compute

[ovn-controller:children]
ovn-controller-compute
ovn-controller-network

[ovn-controller-compute:children]
compute

[ovn-controller-network:children]
network

[ovn-database:children]
control

[ovn-northd:children]
ovn-database

[ovn-nb-db:children]
ovn-database

[ovn-sb-db:children]
ovn-database
EOF

echo '***'
echo '*** deploy openstack kolla'
echo '***'
kolla-ansible \
  --inventory /etc/kolla/inventory \
  bootstrap-servers \
&& kolla-ansible \
  --inventory /etc/kolla/inventory \
  prechecks \
&& kolla-ansible \
  --inventory /etc/kolla/inventory \
  deploy \
&& kolla-ansible \
  --inventory /etc/kolla/inventory \
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
kolla-ansible --inventory /etc/kolla/inventory --tags designate,neutron,nova reconfigure

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
