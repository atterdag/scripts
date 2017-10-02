#!/bin/bash

. `dirname $0`/properties.sh

echo '*** installing WebSphere Application Server Network Deployment'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.ND.v85\
 -acceptLicense\
 -eclipseLocation ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-was-log.xml\
 -nl en\
 -record /tmp/install-was-response.xml\
 -repositories ${IM_REPOSITORY_WAS_GA},\
${IM_REPOSITORY_WAS_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -properties user.wasjava=java6\
 -showVerboseProgress" || exit 1

echo '*** installing IBM Java for WAS 7.0'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v70\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava70-log.xml\
 -nl en\
 -record /tmp/install-ibmjava70-response.xml\
 -repositories ${IM_REPOSITORY_JDK70_GA},\
${IM_REPOSITORY_JDK70_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress" || exit 1

echo '*** installing IBM Java for WAS 7.1'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v71\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava71-log.xml\
 -nl en\
 -record /tmp/install-ibmjava-response.xml\
 -repositories ${IM_REPOSITORY_JDK71_GA},\
${IM_REPOSITORY_JDK71_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress" || exit 1

echo '*** installing IBM Java for WAS 8.0'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl\
 install com.ibm.websphere.IBMJAVA.v80\
 -acceptLicense\
 -installationDirectory ${BASE_INSTALLATION_PATH}/WebSphere/AppServer\
 -installFixes none\
 -log /tmp/install-ibmjava-log.xml\
 -nl en\
 -record /tmp/install-ibmjava-response.xml\
 -repositories ${IM_REPOSITORY_JDK80_GA},\
${IM_REPOSITORY_JDK80_FP}\
 -sharedResourcesDirectory ${BASE_INSTALLATION_PATH}/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress" || exit 1

echo '*** installing unrestricted JCE policies'
su was --login --shell /bin/bash --command "unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java/jre/lib/security/ ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip" || exit 1
su was --login --shell /bin/bash --command "unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.7_64/jre/lib/security/ ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip" || exit 1
su was --login --shell /bin/bash --command "unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.7.1_64/jre/lib/security/ ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip" || exit 1
su was --login --shell /bin/bash --command "unzip -o -d ${BASE_INSTALLATION_PATH}/WebSphere/AppServer/java_1.8_64/jre/lib/security/ ${SOURCE_PATH}/unrestricted_jce/unrestrictedpolicyfiles.zip" || exit 1

echo '*** listing currently installed IBM software'
su was --login --shell /bin/bash --command "${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools/imcl listInstalledPackages" || exit 1
