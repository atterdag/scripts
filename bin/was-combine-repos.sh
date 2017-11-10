#!/bin/bash
#
# AUTHOR: Valdemar Lemche <valdemar@lemche.net>
#
# VERSION: $Id$
#
# DESCRIPTION:
# This script shrinks the size of the combined WAS repositories by splitting
# them up into different platforms, thus reducing the size of each combined
# repository from:
# du -sm /srv/install/was/8550\
#        /srv/install/wasfps/85511/was\
#        /srv/install/ibmwasjava/7041\
#        /srv/install/ibmwasjava/70960\
#        /srv/install/ibmwasjava/71360\
#        /srv/install/ibmwasjava/80320
#
# 2987	/srv/install/was/8550
# 4297	/srv/install/wasfps/85511/was
# 2183	/srv/install/ibmwasjava/7041
# 2318	/srv/install/ibmwasjava/70960
# 2044	/srv/install/ibmwasjava/71360
# 2554	/srv/install/ibmwasjava/80320
#
# Total size is 16383 MB
#
# ... to this:'
# du -sm /srv/install/was-combined*
# 2427    /srv/install/was-combined_85511_aix.ppc
# 2341    /srv/install/was-combined_85511_linux.ppc
# 2304    /srv/install/was-combined_85511_linux.x86
# 2574    /srv/install/was-combined_85511_win32.x86
#
# Its done with the IBM Packaging Utility by only selecting the packages
# required to install WAS 8.5.5.11 (incl Java 7.0, 7.1, and 8.0) to a given
# OS, and platform.
#
# LICENSE: Well ... its free ... you can have it, its yours! C'MON, TAKE IT!!!
#
# DISCLAIMER:
# This script is released TOTALLY AS-IS. If it will have any negative impact
# on your systems, make you sleepless at night or even cause of World War III;
# I will claim no responsibility! You may use this script at you OWN risk.
#

SOURCE_DIR="/net/files/srv/install"
TARGET_PREFIX="${SOURCE_DIR}/was-combined"

function add_product() {
  local PRODUCT=$1
  local REPOSITORIES=$2
  local TARGET=$3
  local OS=$4
  local ARCH=$5
  /opt/IBM/PackagingUtility/PUCL copy $PRODUCT \
   -platform os=$OS,arch=$ARCH \
   -repositories $REPOSITORIES\
   -target $TARGET \
   -acceptLicense \
   -showVerboseProgress || exit 1
}

function print_usage() {
    echo "usage: $0 <WAS VERSION> <platform(s)|common>"
    echo
    echo "example: $0 85511 aix.ppc linux.x86"
    echo
}

WAS_VERSION=$1
if [ "${*:2}" == "" ]; then
  print_usage
  exit 1
fi

if [ "${*:2}" == "common" ]; then
  PLATFORMS=(aix.ppc linux.ppc linux.x86 win32.x86)
else
  PLATFORMS=(${*:2})
fi

case $WAS_VERSION in
  85511)
    WAS_REPOSITORIES="${SOURCE_DIR}/was/8550,${SOURCE_DIR}/wasfps/85511/was"
    SDK70_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/7041,${SOURCE_DIR}/ibmwasjava/70960"
    SDK71_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/71360"
    SDK80_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/80320"
    ;;
  85512)
    WAS_REPOSITORIES="${SOURCE_DIR}/was/8550,${SOURCE_DIR}/wasfps/85512/was"
    SDK70_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/7041,${SOURCE_DIR}/ibmwasjava/70105"
    SDK71_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/7145"
    SDK80_REPOSITORIES="${SOURCE_DIR}/ibmwasjava/8045"
    ;;
  *)
    print_usage
    exit 1
    ;;
esac

for PLATFORM in ${PLATFORMS[@]}; do
  IFS=.
  OS_AND_ARCH=($PLATFORM)
  OS=${OS_AND_ARCH[0]}
  ARCH=${OS_AND_ARCH[1]}
  unset IFS
  add_product com.ibm.websphere.ND.v85      "$WAS_REPOSITORIES"   "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}" $OS $ARCH
  add_product com.ibm.websphere.IBMJAVA.v70 "$SDK70_REPOSITORIES" "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}" $OS $ARCH
  add_product com.ibm.websphere.IBMJAVA.v71 "$SDK71_REPOSITORIES" "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}" $OS $ARCH
  add_product com.ibm.websphere.IBMJAVA.v80 "$SDK80_REPOSITORIES" "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}" $OS $ARCH
  echo
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo '*** check that packages available in repository                            ***'
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}:"
  /opt/IBM/PackagingUtility/PUCL listAvailablePackages -showPlatforms -repositories "${TARGET_PREFIX}_${WAS_VERSION}_${PLATFORM}"
  echo
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo
done
echo
echo 'list(s) above should look like this:'
echo 'com.ibm.websphere.IBMJAVA.v70_7.0.9060.20161124_1308'
echo 'com.ibm.websphere.IBMJAVA.v71_7.1.3060.20161124_1256'
echo 'com.ibm.websphere.IBMJAVA.v80_8.0.3020.20161124_1304'
echo 'com.ibm.websphere.ND.v85_8.5.5011.20161206_1434'
echo
echo 'And you install the packages with as single command like this: '
echo 'su was --login --shell /bin/bash --command "/opt/IBM/InstallationManager/eclipse/tools/imcl\'
echo ' install com.ibm.websphere.ND.v85 com.ibm.websphere.IBMJAVA.v70 com.ibm.websphere.IBMJAVA.v71 com.ibm.websphere.IBMJAVA.v80\'
echo ' -acceptLicense\'
echo ' -eclipseLocation /opt/IBM/WebSphere/AppServer\'
echo ' -installationDirectory /opt/IBM/WebSphere/AppServer\'
echo ' -installFixes none\'
echo ' -log /tmp/install-was85511-log.xml\'
echo ' -nl en\'
echo ' -record /tmp/install-was85511-response.xml\'
echo ' -repositories http://ftp.example.com/srv/install/was-combined-linux_x86-64-85511\'
echo ' -sharedResourcesDirectory /opt/IBM/IMShared\'
echo ' -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\'
echo 'com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\'
echo 'offering.service.repositories.areUsed=false,\'
echo 'com.ibm.cic.common.core.preferences.searchForUpdates=false\'
echo ' -properties user.wasjava=java6\'
echo ' -showVerboseProgress"'
echo
