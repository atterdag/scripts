#!/bin/bash
#
# AUTHOR: Valdemar Lemche <valdemar@lemche.net>
#
# VERSION: $Id$
#
# DESCRIPTION:
# This script shrinks the size of the combined WAS repositories from this'
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
# du -sm /srv/install/was-combined-linux_x86-64_ppc64-85511
# 2304	/srv/install/was-combined-linux_x86-64_ppc64-85511
#
# Its done with the IBM Packaging Utility by only selecting the packages required to install WAS 8.5.5.11 (incl Java 7.0, 7.1, and 8.0) to a given OS, and platform
#
# LICENSE: Well ... its free ... you can have it, its yours! C'MON, TAKE IT!!!
#
# DISCLAIMER:
# This script is released TOTALLY AS-IS. If it will have any negative impact
# on your systems, make you sleepless at night or even cause of World War III;
# I will claim no responsibility! You may use this script at you OWN risk.
#

echo 'Create a combined repository with WAS ND (only) 8.5.5.11 incl all java versions, but restrict architecture to Linux x86_64, and Linux PPC64.'
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.ND.v85 \
 -platform os=linux,arch=x86,os=linux,arch=x86_64,os=linux,arch=ppc,os=linux,arch=ppc64\
 -repositories /net/files/srv/install/was/8550,/net/files/srv/install/wasfps/85511/was\
 -target /net/files/srv/install/was-combined-linux_x86-64_ppc64-85511/\
 -acceptLicense\
 -showVerboseProgress && \
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.IBMJAVA.v70\
 -platform os=linux,arch=x86,os=linux,arch=x86_64,os=linux,arch=ppc,os=linux,arch=ppc64\
 -repositories /net/files/srv/install/ibmwasjava/7041,/net/files/srv/install/ibmwasjava/70960\
 -target /net/files/srv/install/was-combined-linux_x86-64_ppc64-85511/\
 -acceptLicense\
 -showVerboseProgress && \
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.IBMJAVA.v71\
 -platform os=linux,arch=x86,os=linux,arch=x86_64,os=linux,arch=ppc,os=linux,arch=ppc64\
 -repositories /net/files/srv/install/ibmwasjava/71360\
 -target /net/files/srv/install/was-combined-linux_x86-64_ppc64-85511/\
 -acceptLicense\
 -showVerboseProgress && \
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.IBMJAVA.v80\
 -platform os=linux,arch=x86,os=linux,arch=x86_64,os=linux,arch=ppc,os=linux,arch=ppc64\
 -repositories /net/files/srv/install/ibmwasjava/80320\
 -target /net/files/srv/install/was-combined-linux_x86-64_ppc64-85511/\
 -acceptLicense\
 -showVerboseProgress

echo 'check that all packages are available'
/opt/IBM/PackagingUtility/PUCL listAvailablePackages -repositories /net/files/srv/install/was-combined-linux_x86-64_ppc64-85511

echo
echo 'list above should look like this:'
echo 'com.ibm.websphere.IBMJAVA.v70_7.0.10005.20170626_0533'
echo 'com.ibm.websphere.IBMJAVA.v71_7.1.4005.20170626_0531'
echo 'com.ibm.websphere.IBMJAVA.v80_8.0.4005.20170626_0627'
echo 'com.ibm.websphere.ND.v85_8.5.5012.20170627_1018'
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
