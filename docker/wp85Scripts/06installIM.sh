#!/bin/bash

. `dirname $0`/properties.sh

echo '*** installing Installation Manager'
su was --login --shell /bin/bash --command "${IM_REPOSITORY_IM_GA}/tools/imcl \
 install com.ibm.cic.agent\
 -acceptLicense\
 -accessRights group\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/InstallationManager\
 -installationDirectory ${BASE_INSTALLATION_PATH}/InstallationManager\
 -dataLocation ${BASE_INSTALLATION_PATH}/IMDataLocation\
 -log /tmp/install-im-log.xml\
 -nl en\
 -record /tmp/install-im-response.xml\
 -repositories ${IM_REPOSITORY_IM_GA},\
${IM_REPOSITORY_IM_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress" || exit 1

echo '*** listing currently installed IBM software'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages" || exit 1
