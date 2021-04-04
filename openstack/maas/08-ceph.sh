echo '***'
echo '*** Install packages to build and run CEPH cluster on Workstation'
echo '***'
sudo apt-get install --yes \
  ceph-common \
  ceph-fuse \
  libffi-dev \
  libssl-dev \
  python3-dev

echo '***'
echo '*** Download CEPH ansible'
echo '***'
mkdir $HOME/src/github/ceph
git clone \
  https://github.com/ceph/ceph-ansible.git \
  $HOME/src/github/ceph
cd $HOME/src/github/ceph/ceph-ansible

echo '***'
echo '*** Create Python virtualenv'
echo '***'
mkvirtualenv \
  --python=/usr/bin/python3 \
  ceph
pip3 install \
  -r requirements.txt

echo '***'
echo '*** Configure environment in Ansible'
echo '***'
cat <<EOF | tee inventory
${CEPH_MON_ONE_HOST_NAME}   ansible_host=${CEPH_MON_ONE_IP_ADDRESS}
${CEPH_MON_TWO_HOST_NAME}   ansible_host=${CEPH_MON_TWO_IP_ADDRESS}
${CEPH_OSD_ONE_HOST_NAME}   ansible_host=${CEPH_OSD_ONE_IP_ADDRESS}
${CEPH_OSD_TWO_HOST_NAME}   ansible_host=${CEPH_OSD_TWO_IP_ADDRESS}
${CEPH_OSD_THREE_HOST_NAME} ansible_host=${CEPH_OSD_THREE_IP_ADDRESS}
${CEPH_OSD_FOUR_HOST_NAME}  ansible_host=${CEPH_OSD_FOUR_IP_ADDRESS}

[rgw]
${CEPH_MON_ONE_HOST_NAME}
${CEPH_MON_TWO_HOST_NAME}

[mons]
${CEPH_MON_ONE_HOST_NAME}
${CEPH_MON_TWO_HOST_NAME}

[mdss]
${CEPH_MON_ONE_HOST_NAME}
${CEPH_MON_TWO_HOST_NAME}

[osds]
${CEPH_OSD_ONE_HOST_NAME}
${CEPH_OSD_TWO_HOST_NAME}
${CEPH_OSD_THREE_HOST_NAME}
${CEPH_OSD_FOUR_HOST_NAME}
EOF

cat <<EOF | tee group_vars/all.yml
ceph_origin: repository
ceph_repository: community
ceph_repository_type: cdn
ceph_stable_release: nautilus
monitor_interface: ${CEPH_MONITOR_NIC}
public_network: "${CEPH_PUBLIC_NETWORK_CIDR}"
cluster_network: "${CEPH_CLUSTER_NETWORK_CIDR}"
dashboard_enabled: false
configure_firewall: true
EOF

cat <<EOF | tee group_vars/osds.yml
osd_scenario: collocated
devices:
  - /dev/${CEPH_OSD_ONS_PV_DEVICE}
  - /dev/${CEPH_OSD_TWO_PV_DEVICE}
EOF

cp site.yml.sample site.yml

echo '***'
echo '*** Clean drives before deploying'
echo '***'
for i in ${CEPH_OSD_ONE_HOST_NAME} ${CEPH_OSD_TWO_HOST_NAME} ${CEPH_OSD_THREE_HOST_NAME} ${CEPH_OSD_FOUR_HOST_NAME}; do
  ssh ${i}.${ROOT_DNS_DOMAIN} "sudo add-apt-repository ppa:ci-train-ppa-service/3535";
  ssh ${i}.${ROOT_DNS_DOMAIN} "sudo apt-get update";
  ssh ${i}.${ROOT_DNS_DOMAIN} "sudo parted /dev/${CEPH_OSD_ONS_PV_DEVICE} rm 1";
  ssh ${i}.${ROOT_DNS_DOMAIN} "sudo parted /dev/${CEPH_OSD_TWO_PV_DEVICE} rm 1";
done
# for i in ${CEPH_OSD_ONE_HOST_NAME} ${CEPH_OSD_TWO_HOST_NAME} ${CEPH_OSD_THREE_HOST_NAME} ${CEPH_OSD_FOUR_HOST_NAME}; do
#   ssh ${i}.${ROOT_DNS_DOMAIN} "for vg in \$(sudo vgdisplay -C --noheadings --nosuffix | awk '{print $1}'); do sudo vgremove \$vg --yes; done";
#   ssh ${i}.${ROOT_DNS_DOMAIN} "sudo pvremove /dev/${CEPH_OSD_ONS_PV_DEVICE} --yes";
#   ssh ${i}.${ROOT_DNS_DOMAIN} "sudo pvremove /dev/${CEPH_OSD_TWO_PV_DEVICE} --yes";
# done

echo '***'
echo '*** Deploy CEPH'
echo '***'
ansible-playbook -i inventory site.yml

echo '***'
echo '*** Deploy CEPH'
echo '***'
deactivate

echo '***'
echo '*** Retrieve autogenerated values'
echo '***'
CEPH_ADMIN_CLIENT_KEY=$(ssh ${CEPH_MON_ONE_FQDN} sudo ceph auth get-key client.admin)
CEPH_FSID=$(ssh ${CEPH_MON_ONE_FQDN} sudo ceph fsid)

echo '***'
echo '*** set etcd admin password so we can write to etcd'
echo '***'
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi

echo '***'
echo '*** Store values in etcd'
echo '***'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CEPH_ADMIN_CLIENT_KEY ${CEPH_ADMIN_CLIENT_KEY}
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CEPH_FSID ${CEPH_FSID}

echo '***'
echo '*** Generate configuration files on workstation'
echo '***'
if [ ! -d /etc/ceph ]; then sudo mkdir -p /etc/ceph; fi

cat <<EOF | sudo tee /etc/ceph/ceph.client.admin.keyring
[client.admin]
        key = ${CEPH_ADMIN_CLIENT_KEY}
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
EOF

cat <<EOF | sudo tee /etc/ceph/ceph.conf
[global]
cluster network = ${CEPH_CLUSTER_NETWORK_CIDR}
fsid = ${CEPH_FSID}
mon host = [v2:${CEPH_MON_ONE_IP_ADDRESS}:${CEPH_MANAGER_SERVER_PORT},v1:${CEPH_MON_ONE_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT}],[v2:${CEPH_MON_TWO_IP_ADDRESS}:${CEPH_MANAGER_SERVER_PORT},v1:${CEPH_MON_TWO_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT}]
mon initial members = ${CEPH_MON_ONE_FQDN},${CEPH_MON_TWO_FQDN}
osd pool default crush rule = -1
public network = ${CEPH_PUBLIC_NETWORK_CIDR}
EOF

echo '***'
echo '*** Check the cluster features'
echo '***'
ceph features

echo '***'
echo '*** Check the status cluster'
echo '***'
ceph mon stat
ceph osd stat
ceph osd tree
ceph quorum_status | jq
ceph -s

echo '***'
echo '*** allow deletion of pools'
echo '***'
ceph tell mon.\* injectargs '--mon-allow-pool-delete=true'

echo '***'
echo '*** allow multiple filesystems'
echo '***'
ceph fs flag set enable_multiple true

echo '***'
echo '*** Create volume for Kubernetes'
echo '***'
ceph osd pool create $K8S_CEPH_OSD_POOL_DATA_NAME 128
ceph osd pool create $K8S_CEPH_OSD_POOL_METADATA_NAME 128
ceph fs new $K8S_CEPH_FS_NAME $K8S_CEPH_OSD_POOL_METADATA_NAME $K8S_CEPH_OSD_POOL_DATA_NAME
ceph fs ls
ceph df
ceph mds stat

echo '***'
echo '*** mount volume for Kubernetes on workstation'
echo '***'
if [ ! -d /mnt/cephfs ]; then sudo mkdir -p /mnt/cephfs; fi

if [[ -f /usr/bin/wslsys ]]; then
  # Using FUSE - WSL
  sudo ceph-fuse -m ${CEPH_MON_ONE_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT},${CEPH_MON_TWO_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT} /mnt/cephfs
else
  # Using the kernel module
  sudo mount -t ceph ${CEPH_MON_ONE_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT},${CEPH_MON_TWO_IP_ADDRESS}:${CEPH_MONITOR_SERVER_PORT}:/ /mnt/cephfs -o name=admin,secret=${CEPH_ADMIN_CLIENT_KEY}
fi