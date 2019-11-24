#!/bin/sh

if [ -x /usr/bin/vmware-uninstall-tools.pl ]; then
    sudo /usr/bin/vmware-uninstall-tools.pl
fi

sudo apt-get install -y open-vm-tools open-vm-tools-dkms

# Check that pvscsi, and vmxnet3 is used.
if ! lsmod | grep vmw_pvscsi > /dev/null; then echo "parallel virtual SCSI is not enabled, ensure that scsi0.virtualDev = \"pvscsi\" is set in the vmx configuration"; fi
if ! lsmod | grep vmxnet3 > /dev/null; then echo "parallel virtual network is not enabled, ensure that ethernet0.virtualDev = \"vmxnet3\" is set in the vmx configuration"; fi

echo "get time from the VMware host"
sudo vmware-toolbox-cmd timesync enable
