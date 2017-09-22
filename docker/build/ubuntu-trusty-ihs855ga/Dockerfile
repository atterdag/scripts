#
## Installing 8.5.5.0 (GA)
# cd /srv/git/ibm-docker/build/ubuntu-trusty-ihs855ga
# time docker build --tag registry.example.com:5000/ubuntu-trusty-ihs:8550 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-ihs855.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:8550

FROM registry.example.com:5000/ubuntu-trusty-im

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG IM_REPOSITORY_IHS_GA=${SOURCE_PATH}/wassup/8550
ARG IM_REPOSITORY_PLG_GA=${SOURCE_PATH}/wassup/8550
ARG IM_REPOSITORY_WCT_GA=${SOURCE_PATH}/wassup/8550

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-trusty-ihs" \
      version="8550"

USER root:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing IBM HTTP Server 8.5.5.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.IHS.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/HTTPServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/HTTPServer\
 -installFixes none\
 -log /tmp/install-ihs8550-log.xml\
 -nl en\
 -record /tmp/install-ihs8550-response.xml\
 -repositories ${IM_REPOSITORY_IHS_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties \
user.ihs.http.server.service.name=none,\
user.ihs.httpPort=80,\
user.ihs.installHttpService=false\
 -showVerboseProgress

RUN echo '*** installing IBM WebSphere Plugin 8.5.5.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.PLG.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/Plugins\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/Plugins\
 -installFixes none\
 -log /tmp/install-plg8550-log.xml\
 -nl en\
 -record /tmp/install-plg8550-response.xml\
 -repositories ${IM_REPOSITORY_PLG_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

RUN echo '*** installing IBM WebSphere Toolbox 8.5.5.0' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.WCT.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/Toolbox\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/Toolbox\
 -installFixes none\
 -log /tmp/install-wct8550-log.xml\
 -nl en\
 -record /tmp/install-wct8550-response.xml\
 -repositories ${IM_REPOSITORY_WCT_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

RUN echo '*** downloading unrestricated jce policies compressed archive' && \
    wget -O /tmp/unrestrictedpolicyfiles.zip ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip && \
    echo '*** installing unrestricted JCE policies' && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/HTTPServer/java/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    echo '*** cleaning out /tmp/unrestrictedpolicyfiles.zip' && \
    rm -f /tmp/unrestrictedpolicyfiles.zip

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
