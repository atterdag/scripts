#
# cd /srv/git/ibm-docker/build/ubuntu-xenial-was90fp
#
## Installing 9.0.0.2 (Fixpack 02)
# export WAS_FP=9002
# time docker build --build-arg WAS_FP=$WAS_FP --build-arg JDK_FP=8030 --tag registry.example.com:5000/ubuntu-xenial-was:$WAS_FP --tag registry.example.com:5000/ubuntu-xenial-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-was.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-xenial-was:$WAS_FP
# docker image push registry.example.com:5000/ubuntu-xenial-was:latest
#
## Installing 9.0.0.6 (Fixpack 06)
# export WAS_FP=9006
# time docker build --build-arg WAS_FP=$WAS_FP --build-arg JDK_FP=80322 --tag registry.example.com:5000/ubuntu-xenial-was:$WAS_FP --tag registry.example.com:5000/ubuntu-xenial-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_ubuntu-xenial-was.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/ubuntu-xenial-was:$WAS_FP
# docker image push registry.example.com:5000/ubuntu-xenial-was:latest
#

FROM registry.example.com:5000/ubuntu-xenial-was:9000

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG WAS_FP=none
ARG JDK_FP=none
ARG IM_REPOSITORY_WAS_FP=${SOURCE_PATH}/wasfps/${WAS_FP}/was
ARG IM_REPOSITORY_JDK_FP=${SOURCE_PATH}/ibmjava/${JDK_FP}

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/ubuntu-xenial-was" \
      version="$WAS_FP"

RUN if [ "$WAS_FP" == "none" ]; then echo '*** no WAS_FP defined'; exit 1; fi

USER was:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing WebSphere Application Server Network Deployment' ${WAS_FP} && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.ND.v90 com.ibm.java.jdk.v8\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-was${WAS_FP}-log.xml\
 -nl en\
 -record /tmp/install-was${WAS_FP}-response.xml\
 -repositories ${IM_REPOSITORY_WAS_FP},${IM_REPOSITORY_JDK_FP}\
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
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java/8.0/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    echo '*** cleaning out /tmp/unrestrictedpolicyfiles.zip' && \
    rm -f /tmp/unrestrictedpolicyfiles.zip

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
