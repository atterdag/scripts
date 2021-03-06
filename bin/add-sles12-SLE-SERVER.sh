#!/bin/sh

# Set ftp credentials here:
username=jdoe
password=passw0rd
server=ftp.example.com

# Determing bit'ness
if [ "$(uname -m)" = "x86_64" ]; then ARCH=x86_64; else ARCH=i586; fi

echo
echo "*******************************************************************************"
echo "* Removing old repositories                                                   *"
echo "*******************************************************************************"
echo
for i in `zypper lr | awk '{print $1}' | grep -v ^\# | grep -v ^- | tac`; do sudo zypper rr $i; done

echo
echo "*******************************************************************************"
echo "* Cleaning up zypper configuration                                             *"
echo "*******************************************************************************"
echo
sudo rm -fr /root/.zypp/ /var/cache/zypp/packages/*

echo
echo "*******************************************************************************"
echo "* Adding SLES12 SLE-SERVER repositories                                             *"
echo "*******************************************************************************"
echo
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Products/SLE-SERVER/12/${ARCH}/product SLE-Server-product-12
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Updates/SLE-SERVER/12/${ARCH}/update/ SLE-Server-update-12
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Products/SLE-SERVER/12-SP1/${ARCH}/product SLE-Server-product-12-SP1
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Updates/SLE-SERVER/12-SP1/${ARCH}/update SLE-Server-update-12-SP1
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Products/SLE-SERVER/12-SP2/${ARCH}/product SLE-Server-product-12-SP2
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Updates/SLE-SERVER/12-SP2/${ARCH}/update SLE-Server-update-12-SP2
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Products/SLE-SERVER/12-SP2/${ARCH}/product SLE-Server-product-12-SP3
sudo zypper addrepo -K --no-keep-packages ftp://$username:$password@${server}/suse/scc/Updates/SLE-SERVER/12-SP2/${ARCH}/update SLE-Server-update-12-SP3

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
