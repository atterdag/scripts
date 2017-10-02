#!/bin/bash

. `dirname $0`/properties.sh

echo '*** genering encrypted password for installation manager'
PORTAL_PASSWORD=$(su was --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl encryptString $INSTALLPASSWORD")

echo '*** stopping Configuration Wizard server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/cw_profile/bin/stopServer.sh server1 -username cwadmin -password $INSTALLPASSWORD"

echo '*** stopping WebSphere Portal server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username $INSTALLUSERNAME -password $INSTALLPASSWORD"

echo '*** installing IBM WebSpere Portal 8.5 CF'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.PORTAL.SERVER.v85\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
 -log /tmp/install-wp8500cf-log.xml\
 -nl en\
 -record /tmp/install-wp8500cf-response.xml\
 -repositories ${IM_REPOSITORY_WP_GA},\
${IM_REPOSITORY_WP_CF}\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress"

echo '*** updating wkplc.properties'
cat << EOF | su was --login --shell /bin/bash --command "tee /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties"
PWordDelete=false
WasPassword=${INSTALLPASSWORD}
PortalAdminPwd=${INSTALLPASSWORD}
EOF
su was --login --shell /bin/bash --command '/opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh -DSaveParentProperties=true -DparentProperties="/opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties"'

echo '*** installing applying CF to wp_profile'
su was --login --shell /bin/bash --command "/opt/IBM/WebSphere/wp_profile/PortalServer/bin/applyCF.sh -DPortalAdminPwd=$INSTALLPASSWORD -DWasPassword=$INSTALLPASSWORD"

echo '*** stopping WebSphere Portal server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username $INSTALLUSERNAME -password $INSTALLPASSWORD" || exit 1

echo '*** listing currently installed IBM software'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages"
