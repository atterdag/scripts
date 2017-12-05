#!/bin/bash
#
# AUTHOR: Valdemar Lemche <valdemar@lemche.net>
#
# VERSION: $Id$
#
# DESCRIPTION:
# This script shrinks the size of the combined wassup repositories by splitting
# them up into different platforms, thus reducing the size of each combined
# repository from:
# du -sm /srv/install/wassup/8550\
#       /srv/install/wasfps/85511/wassup\
#       /srv/install/wasfps/85511/wct
#
# 2992	/srv/install/wassup/8550
# 4128	/srv/install/wasfps/85511/wassup
# 3348	/srv/install/wasfps/85511/wct
#
#
# Total size is 10468 MB
#
# ... to this:'
# du -sm /srv/install/wassup-combined*
# 683	/srv/install/wassup-combined_85511_aix.ppc
# 701	/srv/install/wassup-combined_85511_linux.ppc
# 688	/srv/install/wassup-combined_85511_linux.x86
# 722	/srv/install/wassup-combined_85511_win32.x86
#
# Its done with the IBM Packaging Utility by only selecting the packages
# required to install wassup 8.5.5.11 (incl wct) to a given OS, and platform.
#
# LICENSE: Well ... its free ... you can have it, its yours! C'MON, TAKE IT!!!
#
# DISCLAIMER:
# This script is released TOTALLY AS-IS. If it will have any negative impact
# on your systems, make you sleepless at night or even cause of World War III;
# I will claim no responsibility! You may use this script at you OWN risk.
#

SOURCE_DIR="/net/files/srv/install"
TARGET_PREFIX="${SOURCE_DIR}/wassup-combined"

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
    echo "usage: $0 <wassup VERSION> <platform(s)|common>"
    echo
    echo "example: $0 85511 aix.ppc linux.x86"
    echo
}

WASSUP_VERSION=$1
if [ "${*:2}" == "" ]; then
  print_usage
  exit 1
fi

if [ "${*:2}" == "common" ]; then
  PLATFORMS=(aix.ppc linux.ppc linux.x86 win32.x86)
else
  PLATFORMS=(${*:2})
fi

case $WASSUP_VERSION in
  85511)
    WASSUP_REPOSITORIES="${SOURCE_DIR}/wassup/8550,${SOURCE_DIR}/wasfps/85511/wassup,${SOURCE_DIR}/wasfps/85511/wct"
    ;;
  85512)
    WASSUP_REPOSITORIES="${SOURCE_DIR}/wassup/8550,${SOURCE_DIR}/wasfps/85512/wassup,${SOURCE_DIR}/wasfps/85511/wct"
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
  add_product com.ibm.websphere.IHS.v85 "$WASSUP_REPOSITORIES" "${TARGET_PREFIX}_${WASSUP_VERSION}_${PLATFORM}" $OS $ARCH
  add_product com.ibm.websphere.PLG.v85 "$WASSUP_REPOSITORIES" "${TARGET_PREFIX}_${WASSUP_VERSION}_${PLATFORM}" $OS $ARCH
  add_product com.ibm.websphere.WCT.v85 "$WASSUP_REPOSITORIES" "${TARGET_PREFIX}_${WASSUP_VERSION}_${PLATFORM}" $OS $ARCH
  echo
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo '*** check that packages available in repository                            ***'
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo "${TARGET_PREFIX}_${WASSUP_VERSION}_${PLATFORM}:"
  /opt/IBM/PackagingUtility/PUCL listAvailablePackages -showPlatforms -repositories "${TARGET_PREFIX}_${WASSUP_VERSION}_${PLATFORM}"
  echo
  echo '******************************************************************************'
  echo '******************************************************************************'
  echo
done
