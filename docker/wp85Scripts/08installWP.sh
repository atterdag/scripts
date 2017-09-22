#!/bin/bash -x

. `dirname $0`/properties.sh

echo '*** genering encrypted password for installation manager'
PORTAL_PASSWORD=$(su was --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl encryptString $INSTALLPASSWORD")

echo '*** installing IBM WebSpere Portal 8.5 GA'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.PORTAL.SERVER.v85,ce.install,portal.binary,portal.profile\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
 -installFixes none\
 -log /tmp/install-wp8500-server-log.xml\
 -nl en\
 -record /tmp/install-wp8500-server-response.xml\
 -repositories ${IM_REPOSITORY_WP_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties user.import.profile=false,\
user.configengine.binaryLocation,,com.ibm.websphere.PORTAL.SERVER.v85=${BASE_INSTALLATION_PATH}/WebSphere/ConfigEngine,\
user.was.installLocation,,com.ibm.websphere.PORTAL.SERVER.v85=${BASE_INSTALLATION_PATH}/WebSphere/AppServer,\
user.wp.wasprofiles.location,,com.ibm.websphere.PORTAL.SERVER.v85=${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles,\
user.cw.userid,,com.ibm.websphere.PORTAL.SERVER.v85=cwadmin,\
user.cw.password,,com.ibm.websphere.PORTAL.SERVER.v85=$PORTAL_PASSWORD,\
user.iim.currentlocale,,com.ibm.websphere.PORTAL.SERVER.v85=en,\
user.wp.base.offering,,com.ibm.websphere.PORTAL.SERVER.v85=portal.server,\
user.wp.hostname,,com.ibm.websphere.PORTAL.SERVER.v85=localhost,\
user.wp.cellname,,com.ibm.websphere.PORTAL.SERVER.v85=${NODENAME},\
user.wp.nodename,,com.ibm.websphere.PORTAL.SERVER.v85=${NODENAME},\
user.wp.userid,,com.ibm.websphere.PORTAL.SERVER.v85=$INSTALLUSERNAME,\
user.wp.password,,com.ibm.websphere.PORTAL.SERVER.v85=$PORTAL_PASSWORD,\
user.wp.profilename,,com.ibm.websphere.PORTAL.SERVER.v85=wp_profile,\
user.wp.custom.contextroot,,com.ibm.websphere.PORTAL.SERVER.v85=wps,\
user.wp.custom.defaulthome,,com.ibm.websphere.PORTAL.SERVER.v85=portal,\
user.wp.custom.personalhome,,com.ibm.websphere.PORTAL.SERVER.v85=myportal,\
user.wp.starting.port,,com.ibm.websphere.PORTAL.SERVER.v85=$STARTINGPORT,\
user.wp.profilepath,,com.ibm.websphere.PORTAL.SERVER.v85=${BASE_INSTALLATION_PATH}/WebSphere/wp_profile\
 -showVerboseProgress" || exit 1

echo '*** stopping Configuration Wizard server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/cw_profile/bin/stopServer.sh server1 -username cwadmin -password $INSTALLPASSWORD" || exit 1

echo '*** stopping WebSphere Portal server'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username $INSTALLUSERNAME -password $INSTALLPASSWORD" || exit 1

echo '*** creating entrypoint start script'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/startServer.sh WebSphere_Portal -script ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/start_WebSphere_Portal.sh" || exit 1

echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/WebSphere_Portal_was.init'
/opt/IBM/WebSphere/AppServer/bin/wasservice.sh \
-add WebSphere_Portal \
-serverName WebSphere_Portal \
-profilePath /opt/IBM/WebSphere/wp_profile \
-userid was \
-wasHome /opt/IBM/WebSphere/AppServer \
-stopArgs "-username $INSTALLUSERNAME -password $INSTALLPASSWORD"

echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/ConfigWizard_was.init'
echo '*** installing IBM WebSpere Portal 8.5 GA'
/opt/IBM/WebSphere/AppServer/bin/wasservice.sh \
-add ConfigWizard \
-serverName server1 \
-profilePath /opt/IBM/WebSphere/AppServer/profiles/cw_profile \
-stopArgs "-username cwadmin -password $INSTALLPASSWORD"
update-rc.d -f ConfigWizard_was.init remove
sed -i 's|su -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@"|' /etc/init.d/*_was.init
sed -i 's|su -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@"|' /etc/init.d/*_was.init

echo '*** listing currently installed IBM software'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages"
