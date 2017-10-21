#!/bin/sh

# Set ftp3 ftp credentials here:
username=jdoe
password=passw0rd
server=ftp.example.com

# Determing bit'ness
if [ "$(uname -m)" = "x86_64" ]; then ARCH=x86_64; else ARCH=i586; fi

echo
echo "*******************************************************************************"
echo "* Adding SLES11 Security-Module repository                                    *"
echo "*******************************************************************************"
echo
REPOSITORY_NAME=SLE11-Security-Module
zypper addrepo --no-keep-packages ftp://$username:$password@${server}/suse/catalogs/${REPOSITORY_NAME}/sle-11-${ARCH} ${REPOSITORY_NAME}

echo
echo "*******************************************************************************"
echo "* Enabling all repositories                                                   *"
echo "*******************************************************************************"
echo
zypper mr -r -a

echo
echo "*******************************************************************************"
echo "* Listing repositories                                                        *"
echo "*******************************************************************************"
echo
zypper lr -u

echo
echo
echo
read -p "Update SLES? [y]: " UPDATE
if [ ! "$UPDATE" = "n" ]; then
    zypper update -y
fi
