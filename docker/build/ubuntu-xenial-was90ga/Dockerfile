#
## Installing WAS 9.0.0.0 (GA)
# cd /srv/git/ibm-docker/build/ubuntu-xenial-was90ga
# time docker build --tag registry.example.com:5000/ubuntu-xenial-was:9000 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-was90ga.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-xenial-was:9000

FROM registry.example.com:5000/ubuntu-xenial-im

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG IM_REPOSITORY_WAS_GA=${SOURCE_PATH}/was/9000
ARG IM_REPOSITORY_JDK_GA=${SOURCE_PATH}/ibmjava/8030

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-xenial-was855" \
      version="ga"

RUN echo '*** creating IBM WebSphere Application Server runtime group, and user' && \
    useradd --gid ibm --create-home --system --shell /bin/false --uid 500 was

USER was:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing WebSphere Application Server Network Deployment 9.0.0.0 (GA)' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.ND.v90 com.ibm.java.jdk.v8\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-was9000-log.xml\
 -nl en\
 -record /tmp/install-was9000-response.xml\
 -repositories ${IM_REPOSITORY_WAS_GA},${IM_REPOSITORY_JDK_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties user.wasjava=java6\
 -showVerboseProgress

RUN echo '*** downloading unrestricated jce policies compressed archive' && \
    wget \
    --output-document=/tmp/unrestrictedpolicyfiles.zip \
    ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip && \
    echo '*** installing unrestricted JCE policies' && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java/8.0/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    echo '*** cleaning out /tmp/unrestrictedpolicyfiles.zip' && \
    rm -f /tmp/unrestrictedpolicyfiles.zip

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
