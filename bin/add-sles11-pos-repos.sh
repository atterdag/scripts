#!/bin/sh

# Set ftp3 ftp credentials here:
username=jdoe
password=passw0rd
server=ftp.example.com

# Determing bit'ness
if [ "$(uname -m)" = "x86_64" ]; then ARCH=x86_64; else ARCH=i586; fi

echo
echo "*******************************************************************************"
echo "* Adding SLES11 POS repositories                                              *"
echo "*******************************************************************************"
echo
for LEVEL in {"",-SP1,-SP2}; do
  for REPOSITORY_NAME in {SLE11-POS${LEVEL}-Pool,SLE11-POS${LEVEL}-Updates}; do
    sudo zypper addrepo --no-keep-packages ftp://$username:$password@${server}/suse/catalogs/${REPOSITORY_NAME}/sle-11-${ARCH} ${REPOSITORY_NAME}
  done
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
