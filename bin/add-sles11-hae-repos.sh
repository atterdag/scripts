#!/bin/sh

# Set ftp3 ftp credentials here:
username=jdoe
password=passw0rd
server=ftp.example.com

# Determing bit'ness
if [ "$(uname -m)" = "x86_64" ]; then ARCH=x86_64; else ARCH=i586; fi

echo
echo "*******************************************************************************"
echo "* Adding SLES11 HAE repositories                                              *"
echo "*******************************************************************************"
echo
for REPOSITORY_NAME in {SLE11-HAE-Pool,SLE11-HAE-Updates,SLE11-HAE-SP1-Pool,SLE11-HAE-SP1-Updates,SLE11-HAE-SP2-Pool,SLE11-HAE-SP2-Updates,SLE11-HAE-SP3-Pool,SLE11-HAE-SP3-Updates,SLE11-HAE-SP4-Pool,SLE11-HAE-SP4-Updates}; do
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
echo
echo
read -p "Update SLES? [y]: " UPDATE
if [ ! "$UPDATE" = "n" ]; then
    sudo zypper update -y
fi
