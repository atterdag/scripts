#
# cd /srv/git/ibm-docker/build/ubuntu-trusty-wp8500
#
## Installing 8.5.0.0 GA
# export WP_CF_TAG=ga
# time docker build --tag registry.example.com:5000/ubuntu-trusty-wp8500:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-trusty-wp8500:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-wp8500.$(date +"%Y%m%d_%H%M%S").txt.out
#
## Installing 8.5.0.0 CF08
# export WP_CF_TAG=cf08
# time docker build --build-arg WP_CF_TAG=$WP_CF_TAG --tag registry.example.com:5000/ubuntu-trusty-wp8500:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-trusty-wp8500:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-wp8500.$(date +"%Y%m%d_%H%M%S").txt.out
#
## Installing 8.5.0.0 CF14
# export WP_CF_TAG=cf14
# time docker build --build-arg WP_CF_TAG=$WP_CF_TAG --tag registry.example.com:5000/ubuntu-trusty-wp8500:$WP_CF_TAG --tag registry.example.com:5000/ubuntu-trusty-wp8500:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-wp8500.$(date +"%Y%m%d_%H%M%S").txt.out

FROM registry.example.com:5000/ubuntu-trusty-was855

ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG NODENAME=wp85Node01
ARG STARTINGPORT=10012
ARG INSTALLUSERNAME=wpsadmin
ARG INSTALLPASSWORD=passw0rd
ARG WP_CF_TAG=ga
ARG IM_REPOSITORY_WP_GA=${SOURCE_PATH}/wp/8500/WP85_Server
ARG IM_REPOSITORY_WP_CF=${SOURCE_PATH}/wpcfs/8500${WP_CF_TAG}/server/

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-trusty-wp8500" \
      version="${WP_CF_TAG}"

EXPOSE 10041 10042 10039 10038 10033

USER was
RUN echo '*** generating encrypted password for installation manager' && \
    PORTAL_PASSWORD=$(${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl encryptString $INSTALLPASSWORD) && \
    echo '*** installing IBM WebSphere Portal Server 8.5.0.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
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
 -showVerboseProgress && \
    echo '*** stopping Configuration Wizard server' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/cw_profile/bin/stopServer.sh server1 -username cwadmin -password $INSTALLPASSWORD && \
    echo '*** stopping WebSphere Portal server' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username $INSTALLUSERNAME -password $INSTALLPASSWORD && \
    echo '*** creating entrypoint start script' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/startServer.sh WebSphere_Portal -script ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/start_WebSphere_Portal.sh

USER root
RUN echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/WebSphere_Portal_was.init' && \
    /opt/IBM/WebSphere/AppServer/bin/wasservice.sh \
 -add WebSphere_Portal \
 -serverName WebSphere_Portal \
 -profilePath /opt/IBM/WebSphere/wp_profile \
 -userid was \
 -wasHome /opt/IBM/WebSphere/AppServer \
 -stopArgs "-username $INSTALLUSERNAME -password $INSTALLPASSWORD" && \
    echo '*** creating SysV script for WebSphere Portal server: /etc/init.d/ConfigWizard_was.init' && \
    echo '*** installing IBM WebSpere Portal 8.5 GA' && \
    /opt/IBM/WebSphere/AppServer/bin/wasservice.sh \
 -add ConfigWizard \
 -serverName server1 \
 -profilePath /opt/IBM/WebSphere/AppServer/profiles/cw_profile \
 -stopArgs "-username cwadmin -password $INSTALLPASSWORD" && \
    update-rc.d -f ConfigWizard_was.init remove && \
    sed -i 's|su -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${startCmd}\\" \\"${SERVERNAME}\\" ${STARTARGS} $@"|' /etc/init.d/*_was.init && \
    sed -i 's|su -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@" ${RUNASUSER}|su - ${RUNASUSER} -s /bin/sh -c "\\"${stopCmd}\\" \\"${SERVERNAME}\\" ${STOPARGS} $@"|' /etc/init.d/*_was.init

USER was
RUN if [ ! "$WP_CF_TAG" = "ga" ]; then \
        echo '*** installing IBM WebSphere Portal Server 8.5.0.0' "$WP_CF_TAG" && \
        ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.PORTAL.SERVER.v85\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/PortalServer\
 -log /tmp/install-wp8500${WP_CF_TAG}-log.xml\
 -nl en\
 -record /tmp/install-wp8500${WP_CF_TAG}-response.xml\
 -repositories ${IM_REPOSITORY_WP_CF}\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress && \
        echo '*** updating wkplc.properties' && \
        echo "PWordDelete=false" > /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
        echo "WasPassword=${INSTALLPASSWORD}" >> /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
        echo "PortalAdminPwd=${INSTALLPASSWORD}" >> /opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties && \
        /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh -DSaveParentProperties=true -DparentProperties="/opt/IBM/WebSphere/wp_profile/ConfigEngine/properties/wkplc_parent.properties" && \
        echo '*** installing applying CF to wp_profile' && \
        /opt/IBM/WebSphere/wp_profile/PortalServer/bin/applyCF.sh -DPortalAdminPwd=${INSTALLUSERNAME} -DWasPassword=${INSTALLPASSWORD} && \
        echo '*** stopping WebSphere Portal server' && \
        ${BASE_INSTALLATION_PATH}/WebSphere/wp_profile/bin/stopServer.sh WebSphere_Portal -username ${INSTALLUSERNAME} -password ${INSTALLPASSWORD}; \
    fi

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
