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
for i in $(zypper lr | awk '{print $1}' | grep -v ^\# | grep -v ^- | tac); do sudo zypper rr $i; done

echo
echo "*******************************************************************************"
echo "* Cleaning up zypper configuration                                             *"
echo "*******************************************************************************"
echo
sudo rm -fr /root/.zypp/ /var/cache/zypp/packages/*

echo
echo "*******************************************************************************"
echo "* Adding SLES11 base repositories                                             *"
echo "*******************************************************************************"
echo
for REPOSITORY_NAME in {SLES11-Pool,SLES11-Extras,SLES11-Updates,SLES11-SP1-Pool,SLES11-SP1-Updates,SLES11-SP2-Core,SLES11-SP2-Updates,SLES11-SP2-Extension-Store,SLES11-SP3-Pool,SLES11-SP3-Updates,SLES11-SP3-Extension-Store,SLES11-SP4-Pool,SLES11-SP4-Updates}; do
  sudo zypper addrepo --no-keep-packages ftp://$username:$password@${server}/suse/catalogs/${REPOSITORY_NAME}/sle-11-${ARCH} ${REPOSITORY_NAME}
done

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
echo "* Fixing SP2/SP3 download invalid repository metadata bug                     *"
echo "*******************************************************************************"
echo
sudo zypper ref

sudo zypper install -y libgpg-error0 suse-build-key

sudo zypper ref

echo
echo
echo
read -p "Update SLES? [y]: " UPDATE
if [ ! "$UPDATE" = "n" ]; then
    sudo zypper update -y
fi
