#
## Installing 8.5.5.0 (GA)
# cd /srv/git/ibm-docker/build/ubuntu-trusty-was855ga
# time docker build --tag registry.example.com:5000/ubuntu-trusty-was:8550 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-trusty-was855ga.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-trusty-was:8550

FROM registry.example.com:5000/ubuntu-trusty-im

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG IM_REPOSITORY_WAS_GA=${SOURCE_PATH}/was/8550
ARG IM_REPOSITORY_JDK70_GA=${SOURCE_PATH}/ibmwasjava/7041

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-trusty-was855" \
      version="ga"

RUN echo '*** creating IBM WebSphere Application Server runtime group, and user' && \
    useradd --gid ibm --create-home --system --shell /bin/false --uid 500 was

USER was:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing WebSphere Application Server Network Deployment 8.5.5.0 (GA)' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.ND.v85\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-was8550-log.xml\
 -nl en\
 -record /tmp/install-was8550-response.xml\
 -repositories ${IM_REPOSITORY_WAS_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties user.wasjava=java6\
 -showVerboseProgress

RUN echo '*** installing IBM Java 7.0.4.1 (GA) for WAS' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v70\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava7041-log.xml\
 -nl en\
 -record /tmp/install-ibmjava7041-response.xml\
 -repositories ${IM_REPOSITORY_JDK70_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

RUN echo '*** downloading unrestricated jce policies compressed archive' && \
    wget \
    --output-document=/tmp/unrestrictedpolicyfiles.zip \
    ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip && \
    echo '*** installing unrestricted JCE policies' && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.7_64/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    echo '*** cleaning out /tmp/unrestrictedpolicyfiles.zip' && \
    rm -f /tmp/unrestrictedpolicyfiles.zip

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
