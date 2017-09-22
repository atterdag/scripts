#
## Installing 1.8.5.0
# cd /srv/git/ibm-docker/build/sles122-imga
# time docker build --tag registry.example.com:5000/sles122-im:1850 --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-im.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-im:1850
#

FROM registry.example.com:5000/sles122

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG COMPRESSED_IMAGE=agent.installer.linux.gtk.x86_64_1.8.5000.20160506_1125.zip
ARG SOURCE_PATH=http://ftp.example.com
ARG IM_REPOSITORY_IM_GA=/tmp/im
ARG BASE_INSTALLATION_PATH=/opt/IBM

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/sles122-im" \
      version="1850"

RUN echo '*** adding imcl to PATH' && \
    echo '#!/bin/sh' | tee /etc/profile.d/imcl_path.sh && \
    echo "PATH=\${PATH}:${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools" | tee -a /etc/profile.d/imcl_path.sh && \
    echo 'export PATH' | tee -a /etc/profile.d/imcl_path.sh && \
    echo '*** downloading imcl bash completion script from Github' && \
    wget -O /etc/bash_completion.d/imcl "https://raw.githubusercontent.com/atterdag/bash-completion-imcl/master/imcl"

RUN echo '*** creating IIM group' $INSTALLATION_MANAGER_GROUP && \
    groupadd --system --gid 200 $INSTALLATION_MANAGER_GROUP

USER root:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** downloading IBM Installation Manager compressed archive' && \
    wget -O /tmp/$COMPRESSED_IMAGE ${SOURCE_PATH}/im/zipped/${COMPRESSED_IMAGE} && \
    echo '*** extracting Installation Manager compressed archive' && \
    mkdir -p $IM_REPOSITORY_IM_GA && \
    unzip -d $IM_REPOSITORY_IM_GA /tmp/$COMPRESSED_IMAGE && \
    echo '*** installing Installation Manager 1.8.5.0' && \
    $IM_REPOSITORY_IM_GA/tools/imcl\
 install com.ibm.cic.agent\
 -acceptLicense\
 -accessRights group\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/InstallationManager\
 -installationDirectory ${BASE_INSTALLATION_PATH}/InstallationManager\
 -dataLocation ${BASE_INSTALLATION_PATH}/IMDataLocation\
 -log /tmp/install-im1850-log.xml\
 -nl en\
 -record /tmp/install-im1850-response.xml\
 -repositories ${IM_REPOSITORY_IM_GA}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress && \
    echo '*** removing' $IM_REPOSITORY_IM_GA && \
    rm -fr $IM_REPOSITORY_IM_GA && \
    echo '*** removing' /tmp/$COMPRESSED_IMAGE && \
    rm -f /tmp/$COMPRESSED_IMAGE

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]
