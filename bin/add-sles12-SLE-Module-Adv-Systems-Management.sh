#!/bin/sh

# Set ftp credentials here:
username=jdoe
password=passw0rd
server=ftp.example.com

# Determing bit'ness
if [ "$(uname -m)" = "x86_64" ]; then ARCH=x86_64; else ARCH=i586; fi

echo
echo "*******************************************************************************"
echo "* Adding SLES12 SLE-Module-Adv-Systems-Management repositories                                             *"
echo "*******************************************************************************"
echo
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Products/SLE-Module-Adv-Systems-Management/12/${ARCH}/product SLE-Module-Adv-Systems-Management-product-12
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Updates/SLE-Module-Adv-Systems-Management/12/${ARCH}/update SLE-Module-Adv-Systems-Management-update-12

echo
echo "*******************************************************************************"
echo "* Enabling all repositories                                                   *"
echo "*******************************************************************************"
echo
sudo zypper mr -r -a

echo
echo "*******************************************************************************"
echo "* Listing repositories                                                        *"
echo "*******************************************************************************"
echo
sudo zypper lr -u

echo
echo "*******************************************************************************"
echo "* Refreshing repositories                                                     *"
echo "*******************************************************************************"
echo
sudo zypper ref

echo
echo "*******************************************************************************"
echo "*******************************************************************************"
read -p "Update SLES? [y]: " UPDATE
if [ ! "$UPDATE" = "n" ]; then
    sudo zypper update -y
fi
