#!/bin/sh
if [ "$2" == "" ]; then
    echo "usage: $0 <name of source vm> <name of target vm>"
    exit 1
fi
sudo vmrun -T ws clone /media/vmware/${1}/${1}.vmx /media/vmware/${2}/${2}.vmx full -cloneName $2
