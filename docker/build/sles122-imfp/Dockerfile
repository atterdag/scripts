#
## Installing 1.8.7.0
# cd /srv/git/ibm-docker/build/sles122-imfp
# export IM_FP=1870
# time docker build --build-arg IM_FP=$IM_FP --tag registry.example.com:5000/sles122-im:$IM_FP --tag registry.example.com:5000/sles122-im:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-im.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-im:$IM_FP
# docker image push registry.example.com:5000/sles122-im:latest
#

FROM registry.example.com:5000/sles122-im:1850

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG SOURCE_PATH=http://ftp.example.com
ARG IM_FP=1870
ARG IM_REPOSITORY_IM_FP=${SOURCE_PATH}/imfps/${IM_FP}
ARG BASE_INSTALLATION_PATH=/opt/IBM

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/sles122-im" \
      version="$IM_FP"

USER root:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** installing Installation Manager' $IM_FP && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.cic.agent\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/InstallationManager\
 -installationDirectory ${BASE_INSTALLATION_PATH}/InstallationManager\
 -installFixes none\
 -log /tmp/update-im${IM_FP}-log.xml\
 -nl en\
 -record /tmp/update-im${IM_FP}-response.xml\
 -repositories ${IM_REPOSITORY_IM_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=true\
 -showVerboseProgress

RUN echo '*** listing installed packages' && \
    ${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages

CMD ["/bin/bash","--login"]

