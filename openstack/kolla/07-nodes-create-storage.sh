
#!/bin/sh
cat <<EOF | ssh ${DEPLOY_USER_NAME}@${COMPUTE_FQDN}
echo '***'
echo '*** create premium (SDD) storage on Compute host'
echo '***'
sudo parted --script /dev/${OS_LVM_PREMIUM_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${OS_LVM_PREMIUM_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${OS_LVM_PREMIUM_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${OS_LVM_PREMIUM_PV_DEVICE}1
sudo vgcreate cinder-premium-vg /dev/${OS_LVM_PREMIUM_PV_DEVICE}1

echo '***'
echo '*** Create standard (HDD) storage on Compute host'
echo '***'
sudo parted --script /dev/${OS_LVM_STANDARD_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${OS_LVM_STANDARD_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${OS_LVM_STANDARD_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${OS_LVM_STANDARD_PV_DEVICE}1
sudo vgcreate cinder-standard-vg /dev/${OS_LVM_STANDARD_PV_DEVICE}1

echo '***'
echo '*** Create LVM thin pool on system used for lvm-1 on Compute host'
echo '***'
sudo lvcreate --type thin-pool --size 10G --name system-pool system

# echo '***'
# echo '*** workaround to allow nova to use /dev/kvm on host'
# echo '***'
# sudo groupadd -g 42436 nova
# sudo useradd -u 42436 -g nova -d /var/lib/nova -m -G kvm -s /usr/sbin/nologin nova

# echo '***'
# echo '*** download ironic agent images'
# echo '***'
# if [[ ! -d /etc/kolla/config/ironic ]]; then mkdir -p /etc/kolla/config/ironic; fi
# curl \
#   --url https://tarballs.openstack.org/ironic-python-agent/dib/files/ipa-centos7-master.kernel \
#   --output /etc/kolla/config/ironic/ironic-agent.kernel
# curl \
#   --url https://tarballs.openstack.org/ironic-python-agent/dib/files/ipa-centos7-master.initramfs \
#   --output /etc/kolla/config/ironic/ironic-agent.initramfs
EOF
