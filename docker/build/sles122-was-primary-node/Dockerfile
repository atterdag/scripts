#
# cd /srv/git/ibm-docker/build/sles122-was-primary-node
# export VERSION=85512
# time docker build --build-arg VERSION=$VERSION --tag registry.example.com:5000/sles122-was-primary-node:$VERSION --tag registry.example.com:5000/sles122-was-primary-node:latest --file ./Dockerfile . 2>&1 | tee /tmp/docker_file_sles122-was-primary-node.$(date +"%Y%m%d_%H%M%S").txt.out
# docker image push registry.example.com:5000/sles122-was-primary-node:$VERSION
# docker image push registry.example.com:5000/sles122-was-primary-node:latest
#

FROM registry.example.com:5000/sles122-was:$VERSION

ARG INSTALLATION_MANAGER_GROUP=ibm
ARG BASE_INSTALLATION_PATH=${BASE_INSTALLATION_PATH}
ARG VERSION=latest
ARG DOMAINANME=docker.example.com

LABEL maintainer="Valdemar Lemche <valdemar@lemche.net>" \
      name="registry.example.com:5000/sles122-was-primary-node" \
      version="none"

RUN if [ "$VERSION" == "none" ]; then echo '*** no VERSION defined'; exit 1; fi

USER root:root

RUN echo '*** updating /etc/hosts' && \
    thisHostIp=$(grep $(hostname) /etc/hosts | awk '{print $1}') && \
    echo "${thisHostIp} was${VERSION}01.${DOMAINANME} was${VERSION}01" >> /etc/hosts

USER was:${INSTALLATION_MANAGER_GROUP}

RUN echo '*** setting default SDK for commands, and new profiles to 8.0' && \
    if [ "$(uname -m)" = "x86_64" ]; then ARCH=64; else ARCH=32; fi && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/bin/managesdk.sh -setCommandDefault -sdkname 1.8_${ARCH} && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/bin/managesdk.sh -setNewProfileDefault -sdkname 1.8_${ARCH}

RUN echo '*** create WebSphere Application Server Deployment Manager profile' && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/bin/manageprofiles.sh \
     -create \
     -templatePath ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profileTemplates/management \
     -hostName was${VERSION}01.${DOMAINANME} \
     -profileName Dmgr01 \
     -profilePath ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/Dmgr01 \
     -cellName was${VERSION}01Cell01 \
     -nodeName was${VERSION}01CellManager01 \
     -enableAdminSecurity false \
     -defaultPorts && \
    ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/profiles/Dmgr01/bin/startManager.sh

CMD ["/bin/bash","--login"]
