#
# cd /srv/git/ibm-docker/build/ubuntu-xenial-wp90ga
#
## Installing 8.5.0.0 GA
# export WP_CF_TAG=ga
# time docker build --tag registry.example.com:5000/ubuntu-xenial-wp90ga:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-xenial-wp90ga:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-wp90ga.$(date +"%Y%m%d_%H%M%S").txt.out
#
## Installing 8.5.0.0 CF08
# export WP_CF_TAG=cf08
# time docker build --build-arg WP_CF_TAG=$WP_CF_TAG --tag registry.example.com:5000/ubuntu-xenial-wp90ga:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-xenial-wp90ga:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-wp90ga.$(date +"%Y%m%d_%H%M%S").txt.out
#
## Installing 8.5.0.0 CF14
# export WP_CF_TAG=cf14
# time docker build --build-arg WP_CF_TAG=$WP_CF_TAG --tag registry.example.com:5000/ubuntu-xenial-wp90ga:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-xenial-wp90ga:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-wp90ga.$(date +"%Y%m%d_%H%M%S").txt.out

FROM registry.example.com:5000/ubuntu-xenial-was:9002

ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG NODENAME=wp90Node01
ARG STARTINGPORT=10012
ARG INSTALLUSERNAME=wpsadmin
ARG INSTALLPASSWORD=passw0rd
ARG WP_CF_TAG=ga
ARG WP_ENABLE=yes
ARG IM_REPOSITORY_WP85_Server=${SOURCE_PATH}/wp/9000/SETUP/products/WP85_Server
ARG IM_REPOSITORY_IFPI59896=${SOURCE_PATH}/wp/9000/SETUP/products/IFPI59896/8.5.0.0-WP-Server-IFPI59896.zip
ARG IM_REPOSITORY_WP85_Enable=${SOURCE_PATH}/wp/9000/SETUP/products/WP85_Enable
ARG IM_REPOSITORY_WP8500CF13_Server=${SOURCE_PATH}/wp/9000/SETUP/products/WP8500CF13_Server/
ARG IM_REPOSITORY_WP90_Portal=${SOURCE_PATH}/wp/9000/SETUP/products/WP90_Portal
ARG IM_REPOSITORY_WP90_Enable=${SOURCE_PATH}/wp/9000/SETUP/products/WP90_Enable

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-xenial-wp90ga" \
      version="${WP_CF_TAG}"

EXPOSE 10041 10042 10039 10038 10033

USER was
RUN echo '*** generating encrypted password for installation manager' && \
    PORTAL_PASSWORD=$(${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl encryptString $INSTALLPASSWORD) && \
    echo '*** installing IBM WebSphere Portal Server 8.5.0.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
      install com.ibm.websphere.PORTAL.SERVER.v85,ce.install,portal.binary,portal.profile 8.5.0.0-WP-Server-IFPI59896\
      -acceptLicense\
      -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
      -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
      -log /tmp/install-wp90ga-server-log.xml\
      -nl en\
      -record /tmp/install-wp90ga-server-response.xml\
      -repositories ${IM_REPOSITORY_WP85_Server},${IM_REPOSITORY_IFPI59896}\
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
      -showVerboseProgress && \
    echo '*** stopping Configuration Wizard server' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/cw_profile/bin/stopServer.sh\
      server1\
      -username cwadmin\
      -password $INSTALLPASSWORD && \
    echo '*** stopping WebSphere Portal server' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh\
      WebSphere_Portal\
      -username $INSTALLUSERNAME\
      -password $INSTALLPASSWORD

RUN echo '*** updating wkplc.properties' && \
    echo "PWordDelete=false" > ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
    echo "WasPassword=${INSTALLPASSWORD}" >> ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
    echo "PortalAdminPwd=${INSTALLPASSWORD}" >> ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh\
      -DSaveParentProperties=true\
      -DparentProperties="${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties"

RUN if [ "$WP_ENABLE" = "yes" ]; then \
      echo '*** installing IBM WebSphere Portal Enable 8.5.0.0' && \
      ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
        install com.ibm.websphere.PORTAL.ENABLE.v85,enable.upsell\
        -acceptLicense\
        -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
        -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
        -installFixes none\
        -log /tmp/install-wp90ga-enable-log.xml\
        -nl en\
        -record /tmp/install-wp90ga-enable-response.xml\
        -repositories ${IM_REPOSITORY_WP85_Enable}\
        -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
        -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
        -showVerboseProgress && \
      echo '*** configure WCM authoring portlet' && \
      ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh\
        configure-wcm-authoring\
        -DWasUserid=${INSTALLUSERNAME}\
        -DPortalAdminPwd=${INSTALLPASSWORD}\
        -DWasPassword=${INSTALLPASSWORD};\
    fi

RUN echo '*** installing IBM WebSphere Portal 8.5.0.0 CF13' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
    install com.ibm.websphere.PORTAL.SERVER.v85\
      -acceptLicense\
      -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
      -log /tmp/install-wp90gacf13-log.xml\
      -nl en\
      -record /tmp/install-wp90gacf13-response.xml\
      -repositories ${IM_REPOSITORY_WP8500CF13_Server}\
      -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
      -properties \
user.wp.portal.userid,,com.ibm.websphere.PORTAL.SERVER.v85=$INSTALLUSERNAME,\
user.wp.portal.password,,com.ibm.websphere.PORTAL.SERVER.v85=$PORTAL_PASSWORD,\
user.wp.was.userid,,com.ibm.websphere.PORTAL.SERVER.v85=$INSTALLUSERNAME,\
user.wp.was.password,,com.ibm.websphere.PORTAL.SERVER.v85=$PORTAL_PASSWORD\
      -showVerboseProgress && \
    echo '*** installing applying CF to wp_profile' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/PortalServer/bin/applyCF.sh\
      -DPortalAdminPwd=${INSTALLPASSWORD}\
      -DWasPassword=${INSTALLPASSWORD} && \
    echo '*** stopping WebSphere Portal server' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh\
      WebSphere_Portal\
      -username ${INSTALLUSERNAME}\
      -password ${INSTALLPASSWORD}

RUN echo '*** installing IBM WebSphere Portal 9.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
      install com.ibm.websphere.PORTAL.SERVER.v90,portal9.upsell\
      -acceptLicense\
      -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
      -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
      -installFixes none\
      -log /tmp/install-wp9000-log.xml\
      -nl en\
      -record /tmp/install-wp9000-response.xml\
      -repositories ${IM_REPOSITORY_WP90_Portal}\
      -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
      -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
      -showVerboseProgress

RUN if [ "$WP_ENABLE" = "yes" ]; then \
      echo '*** installing IBM WebSphere Portal Enable 9.0' && \
      ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
        install com.ibm.websphere.PORTAL.ENABLE.v90,ext9.upsell\
        -acceptLicense\
        -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
        -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
        -installFixes none\
        -log /tmp/install-wp9000-enable-log.xml\
        -nl en\
        -record /tmp/install-wp9000-enable-response.xml\
        -repositories ${IM_REPOSITORY_WP90_Enable}\
        -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
        -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
        -showVerboseProgress;\
  fi

RUN echo '*** creating entrypoint start script' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/startServer.sh\
      WebSphere_Portal\
      -script ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/start_WebSphere_Portal.sh

USER root
RUN echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/WebSphere_Portal_was.init' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/bin/wasservice.sh \
-add WebSphere_Portal \
-serverName WebSphere_Portal \
-profilePath ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile \
-userid was \
-wasHome ${BASE_INSTALLATION_PATH}/WebSphere/AppServer \
-stopArgs "-username $INSTALLUSERNAME -password $INSTALLPASSWORD" && \
    echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/ConfigWizard_was.init' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/bin/wasservice.sh \
-add ConfigWizard \
-serverName server1 \
-profilePath ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/cw_profile \
-stopArgs "-username cwadmin -password $INSTALLPASSWORD" && \
    echo '*** fixing su syntax error in SysV script generated by wasservice' && \
    update-rc.d -f ConfigWizard_was.init remove && \
    sed -i 's|su -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@"|' /etc/init.d/*_was.init && \
    sed -i 's|su -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@"|' /etc/init.d/*_was.init

USER was
RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
