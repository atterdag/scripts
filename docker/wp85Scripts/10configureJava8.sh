#!/bin/bash

. `dirname $0`/properties.sh

echo '*** stopping WebSphere Portal server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username $INSTALLUSERNAME -password $INSTALLPASSWORD"

echo '*** determining bitness'
if [ "$(uname -m)"=="x86_64" ]; then ARCH=64; else ARCH=32; fi

echo '*** setting default java for new profiles to 8'
su was --login --shell /bin/bash --command "/opt/IBM/WebSphere/AppServer/bin/managesdk.sh -setNewProfileDefault -sdkname 1.8_${ARCH}"

echo '*** cleaning compiled java classes for WAS'
su was --login --shell /bin/bash --command "/opt/IBM/WebSphere/AppServer/bin/osgiCfgInit.sh -washome"

echo '*** setting default java for wp_profile to 8'
su was --login --shell /bin/bash --command "/opt/IBM/WebSphere/AppServer/bin/managesdk.sh -enableProfile -profileName wp_profile -sdkname 1.8_${ARCH} -enableServers -user $INSTALLUSERNAME -password $INSTALLPASSWORD"

echo '*** cleaning compiled java classes for wp_profile'
rm -fr /opt/IBM/WebSphere/wp_profile/temp/* \
 /opt/IBM/WebSphere/wp_profile/wstemp/* \
 /opt/IBM/WebSphere/wp_profile/config/temp/*
su was --login --shell /bin/bash --command "/opt/IBM/WebSphere/wp_profile/bin/osgiCfgInit.sh"
