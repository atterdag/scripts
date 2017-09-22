#!/bin/sh
# The WebSphere Application Server Network Deployment 8.5.5 GA repositories 
# are so old that it pre-dates the Network repository format, but uses the old
# Electronic Service Delivery format.
# (ref https://www.ibm.com/support/knowledgecenter/SSDV2W_1.8.1/com.ibm.silentinstall12.doc/topics/r_repository_types.html). 
# So in order to install from a network URL you need to convert the ESD 
# repositories to Network format.

# Download IBM Packaging Utility from \
# http://www-01.ibm.com/support/docview.wss?uid=swg24037641#DNLD, and extract 
# the installation files into /net/files/srv/install/pu/1870/linux64
imcl install com.ibm.cic.packagingUtility \
 -acceptLicense\
 -eclipseLocation /opt/IBM/PackagingUtility\
 -installationDirectory /opt/IBM/PackagingUtility\
 -installFixes none\
 -log /tmp/install-pu1870-log.xml\
 -nl en\
 -record /tmp/install-pu1870-response.xml\
 -repositories /net/files/srv/install/pu/1870/linux64/disk_linux.gtk.x86_64\
 -sharedResourcesDirectory /opt/IBM/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress

# Rename old WebSphere Application Server 8.5.5 GA repositories
mv /net/files/srv/install/was/8550/ /net/files/srv/install/was/8550.esd
mv /net/files/srv/install/wassup/8550/ /net/files/srv/install/wassup/8550.esd
mv /net/files/srv/install/ibmwasjava/704001 /net/files/srv/install/ibmwasjava/704001.esd

# Check for package IDs on WebSphere Application Server 8.5.5 GA repository
imcl listAvailablePackages -repositories /net/files/srv/install/was/8550.esd/
com.ibm.websphere.ND.v85_8.5.5000.20130514_1044

# Convert WebSphere Application Server ESD format repository to a Network format repository
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.ND.v85 \
 -repositories /net/files/srv/install/was/8550.esd/\
 -target /net/files/srv/install/was/8550/\
 -acceptLicense\
 -showVerboseProgress

# Check for package IDs on WebSphere Application Server Supplements 8.5.5 GA repository
imcl listAvailablePackages -repositories /net/files/srv/install/wassup/8550.esd/
# com.ibm.websphere.APPCLIENT.v85_8.5.5000.20130514_1044
# com.ibm.websphere.IHS.v85_8.5.5000.20130514_1044
# com.ibm.websphere.PLG.v85_8.5.5000.20130514_1044
# com.ibm.websphere.PLUGCLIENT.v85_8.5.5000.20130514_1044
# com.ibm.websphere.WCT.v85_8.5.5000.20130514_1044

# Rather than converting each package individually, we can just loop over the 
# previous output.
for i in $(imcl listAvailablePackages -repositories /net/files/srv/install/wassup/8550.esd/); do
/opt/IBM/PackagingUtility/PUCL copy $i\
 -repositories /net/files/srv/install/wassup/8550.esd/\
 -target /net/files/srv/install/wassup/8550/\
 -acceptLicense\
 -showVerboseProgress
done

# Check for package IDs on IBM Java 7.0.4.001 GA repository
imcl listAvailablePackages -repositories /net/files/srv/install/ibmwasjava/704001.esd
com.ibm.websphere.IBMJAVA.v70_7.0.4001.20130510_2103
com.ibm.websphere.liberty.IBMJAVA.v70_7.0.4001.20130510_2103

# Convert WebSphere Application Server ESD format repository to a Network format repository
for i in $(imcl listAvailablePackages -repositories /net/files/srv/install/ibmwasjava/704001.esd/); do
/opt/IBM/PackagingUtility/PUCL copy $i\
 -repositories /net/files/srv/install/ibmwasjava/704001.esd/\
 -target /net/files/srv/install/ibmwasjava/704001/\
 -acceptLicense\
 -showVerboseProgress
done

# Lets just check that we can get a package listing for each repository over HTTP.
imcl listAvailablePackages -repositories http://ftp.example.com/was/8550
# com.ibm.websphere.ND.v85_8.5.5000.20130514_1044
imcl listAvailablePackages -repositories http://ftp.example.com/wassup/8550
# com.ibm.websphere.APPCLIENT.v85_8.5.5000.20130514_1044
# com.ibm.websphere.IHS.v85_8.5.5000.20130514_1044
# com.ibm.websphere.PLG.v85_8.5.5000.20130514_1044
# com.ibm.websphere.PLUGCLIENT.v85_8.5.5000.20130514_1044
# com.ibm.websphere.WCT.v85_8.5.5000.20130514_1044
imcl listAvailablePackages -repositories http://ftp.example.com/ibmwasjava/704001
# com.ibm.websphere.IBMJAVA.v70_7.0.4001.20130510_2103
# com.ibm.websphere.liberty.IBMJAVA.v70_7.0.4001.20130510_2103

# Remove old ESD repositories
rm -fr /net/files/srv/install/was/8550.esd
rm -fr /net/files/srv/install/wassup/8550.esd
rm -fr /net/files/srv/install/ibmwasjava/704001.esd
