#
# cd /srv/git/ibm-docker/build/sles122-was855fp
#
## Installing 8.5.5.8 (Fixpack 08)
# export WAS_FP_TAG=8558
# time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=8558 --build-arg JDK70_FP=70910_0001 --build-arg JDK71_FP=71310_0001 --tag registry.example.com:5000/sles122-was:$WAS_FP_TAG --tag registry.example.com:5000/sles122-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-was:$WAS_FP_TAG
# docker image push registry.example.com:5000/sles122-was:latest
#
## Installing 8.5.5.11 (Fixpack 11)
# export WAS_FP_TAG=85511
# time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85511 --build-arg JDK70_FP=70960 --build-arg JDK71_FP=71360 --build-arg JDK80_FP=80320 --tag registry.example.com:5000/sles122-was:$WAS_FP_TAG --tag registry.example.com:5000/sles122-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-was:$WAS_FP_TAG
# docker image push registry.example.com:5000/sles122-was:latest
#
## Installing 8.5.5.12 (Fixpack 12)
# export WAS_FP_TAG=85512
# time docker build --build-arg WAS_FP_TAG=$WAS_FP_TAG --build-arg WAS_FP=85512 --build-arg JDK70_FP=70105 --build-arg JDK71_FP=7145 --build-arg JDK80_FP=8045 --tag registry.example.com:5000/sles122-was:$WAS_FP_TAG --tag registry.example.com:5000/sles122-was:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-was:$WAS_FP_TAG
# docker image push registry.example.com:5000/sles122-was:latest

FROM registry.example.com:5000/sles122-was:8550

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG BASE_INSTALLATION_PATH=/opt/IBM
ARG WAS_FP_TAG=none
ARG WAS_FP=none
ARG JDK70_FP=none
ARG JDK71_FP=none
ARG JDK80_FP=none
ARG IM_REPOSITORY_WAS_FP=${SOURCE_PATH}/wasfps/${WAS_FP}/was
ARG IM_REPOSITORY_JDK70_FP=${SOURCE_PATH}/ibmwasjava/${JDK70_FP}
ARG IM_REPOSITORY_JDK71_FP=${SOURCE_PATH}/ibmwasjava/${JDK71_FP}
ARG IM_REPOSITORY_JDK80_FP=${SOURCE_PATH}/ibmwasjava/${JDK80_FP}

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/sles122-was" \
      version="$WAS_FP_TAG"

RUN if [ "$WAS_FP_TAG" == "none" ]; then echo '*** no WAS_FP_TAG defined'; exit 1; fi

USER was:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing WebSphere Application Server Network Deployment' $WAS_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.ND.v85\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-was${WAS_FP}-log.xml\
 -nl en\
 -record /tmp/install-was${WAS_FP}-response.xml\
 -repositories ${IM_REPOSITORY_WAS_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties user.wasjava=java6\
 -showVerboseProgress

RUN echo '*** installing IBM Java 7.0 for WAS' $JDK70_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v70\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava${JDK70_FP}-log.xml\
 -nl en\
 -record /tmp/install-ibmjava${JDK70_FP}-response.xml\
 -repositories ${IM_REPOSITORY_JDK70_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

RUN if [[ $WAS_FP -ge 8552 ]]; then \
        echo '*** installing IBM Java 7.1 for WAS' $JDK71_FP; \
        ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v71\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava${JDK71_FP}-log.xml\
 -nl en\
 -record /tmp/install-ibmjava${JDK71_FP}-response.xml\
 -repositories ${IM_REPOSITORY_JDK71_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress; \
    fi

RUN if [[ $WAS_FP -ge 8559 ]]; then \
        echo '*** installing IBM Java 8.0 for WAS' $JDK80_FP; \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v80\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava${JDK80_FP}-log.xml\
 -nl en\
 -record /tmp/install-ibmjava${JDK80_FP}-response.xml\
 -repositories ${IM_REPOSITORY_JDK80_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress; \
    fi

RUN echo '*** downloading unrestricated jce policies compressed archive' && \
    wget \
    --output-document=/tmp/unrestrictedpolicyfiles.zip \
    ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip && \
    echo '*** installing unrestricted JCE policies' && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.7_64/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip && \
    if [[ $WAS_FP -ge 8552 ]]; then \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.7.1_64/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip ; \
    fi && \
    if [[ $WAS_FP -ge 8559 ]]; then \
    unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.8_64/jre/lib/security/ /tmp/unrestrictedpolicyfiles.zip; \
    fi && \
    echo '*** cleaning out /tmp/unrestrictedpolicyfiles.zip' && \
    rm -f /tmp/unrestrictedpolicyfiles.zip

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
