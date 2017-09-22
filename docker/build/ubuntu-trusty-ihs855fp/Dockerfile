#
# cd /srv/git/ibm-docker/build/ubuntu-trusty-ihs855fp
#
## Installing 8.5.5.8 (Fixpack 08)
# export IHS_FP_TAG=8558
# time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=8558 --build-arg PLG_FP=8558 --build-arg WCT_FP=8558 --tag registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-ihs:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:latest
#
## Installing 8.5.5.11 (Fixpack 11)
# export IHS_FP_TAG=85511
# time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85511 --build-arg PLG_FP=85511 --build-arg WCT_FP=85511 --tag registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-ihs:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:latest
#
## Installing 8.5.5.12 (Fixpack 12)
# export IHS_FP_TAG=85512
# time docker build --build-arg IHS_FP_TAG=$IHS_FP_TAG --build-arg IHS_FP=85512 --build-arg PLG_FP=85512 --build-arg WCT_FP=85512 --tag registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG --tag registry.example.com:5000/ubuntu-trusty-ihs:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:$IHS_FP_TAG
# docker image push registry.example.com:5000/ubuntu-trusty-ihs:latest

FROM registry.example.com:5000/ubuntu-trusty-ihs:8550

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG IHS_FP_TAG=none
ARG IHS_FP=none
ARG PLG_FP=none
ARG WCT_FP=none
ARG IM_REPOSITORY_IHS_FP=${SOURCE_PATH}/wasfps/${IHS_FP}/wassup
ARG IM_REPOSITORY_PLG_FP=${SOURCE_PATH}/wasfps/${PLG_FP}/wassup
ARG IM_REPOSITORY_WCT_FP=${SOURCE_PATH}/wasfps/${WCT_FP}/wct

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-trusty-ihs" \
      version="$IHS_FP_TAG"

RUN if [ "$IHS_FP_TAG" == "none" ]; then echo '*** no IHS_FP_TAG defined'; exit 1; fi

USER root:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing IBM HTTP Server' $IHS_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.IHS.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/HTTPServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/HTTPServer\
 -installFixes none\
 -log /tmp/install-ihs${IHS_FP}-log.xml\
 -nl en\
 -record /tmp/install-ihs${IHS_FP}-response.xml\
 -repositories ${IM_REPOSITORY_IHS_FP}\
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

RUN echo '*** installing IBM WebSphere Plugin' $PLG_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.PLG.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/Plugins\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/Plugins\
 -installFixes none\
 -log /tmp/install-plg${PLG_FP}-log.xml\
 -nl en\
 -record /tmp/install-plg${PLG_FP}-response.xml\
 -repositories ${IM_REPOSITORY_PLG_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

RUN echo '*** installing IBM WebSphere Toolbox' $WCT_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.WCT.v85 \
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/Toolbox\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/Toolbox\
 -installFixes none\
 -log /tmp/install-wct${WCT_FP}-log.xml\
 -nl en\
 -record /tmp/install-wct${WCT_FP}-response.xml\
 -repositories ${IM_REPOSITORY_WCT_FP}\
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
