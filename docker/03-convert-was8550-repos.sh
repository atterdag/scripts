#!/bin/sh
# The WebSphere Application Server Network Deployment 8.5.5 GA repositories 
# are so old that it pre-dates the Network repository format, but uses the old
# Electronic Service Delivery format.
# (ref https://www.ibm.com/support/knowledgecenter/SSDV2W_1.8.1/com.ibm.silentinstall12.doc/topics/r_repository_types.html). 
# So in order to install from a network URL you need to convert the ESD 
# repositories to Network format.

echo '***'
echo '*** creating IBM Installation Manager group'
echo '***'
sudo groupadd --system --gid 200 iim

echo '***'
echo '*** Add your user to the docker group to run docker'
echo '***'
sudo usermod -aG iim $USER

echo '***'
echo '*** installing IBM Installation Manager'
echo '***'
sudo -u root -g iim -i "/net/files/srv/install/im/1850/linux64/tools/imcl\
 install com.ibm.cic.agent\
 -acceptLicense\
 -accessRights group\
 -eclipseLocation /opt/IBM/InstallationManager\
 -installationDirectory /opt/IBM/InstallationManager\
 -dataLocation /opt/IBM/IMDataLocation\
 -log /tmp/install-im1850-log.xml\
 -nl en\
 -record /tmp/install-im1850-response.xml\
 -repositories /net/files/srv/install/im/1850/linux64,\
/net/files/srv/install/imfps/1870\
 -sharedResourcesDirectory /opt/IBM/IMShared\
 -preferences com.ibm.cic.common.core.preferences.keepFetchedFiles=false,\
com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false,\
offering.service.repositories.areUsed=false,\
com.ibm.cic.common.core.preferences.searchForUpdates=false\
 -showVerboseProgress"

echo '***'
echo '*** adding imcl to PATH'
echo '***'
cat << EOF | sudo tee /etc/profile.d/imcl_path.sh
#!/bin/sh
PATH=\${PATH}:/opt/IBM/InstallationManager/eclipse/tools
export PATH
EOF
sudo chmod +x /etc/profile.d/imcl_path.sh

echo '***'
echo '*** downloading imcl bash completion script from Github' 
echo '***'
sudo -i wget -O /etc/bash_completion.d/imcl "https://raw.githubusercontent.com/atterdag/bash-completion-imcl/master/imcl"
. /etc/bash_completion.d/imcl

echo '***'
echo '*** install IBM Packaging Utility' 
echo '***'
echo 'Download IBM Packaging Utility from '
echo 'http://www-01.ibm.com/support/docview.wss?uid=swg24037641#DNLD, and extract '
echo 'the installation files into /net/files/srv/install/pu/1870/linux64'
sudo -u root -g iim -i "imcl \
 install com.ibm.cic.packagingUtility \
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
 -showVerboseProgress"

echo '***'
echo '*** rename old WebSphere Application Server 8.5.5 GA repositories' 
echo '***'
mv /net/files/srv/install/was/8550/ /net/files/srv/install/was/8550.esd
mv /net/files/srv/install/wassup/8550/ /net/files/srv/install/wassup/8550.esd
mv /net/files/srv/install/ibmwasjava/704001 /net/files/srv/install/ibmwasjava/704001.esd

echo '***'
echo '*** check for package IDs on WebSphere Application Server 8.5.5 GA repository' 
echo '***'
imcl listAvailablePackages -repositories /net/files/srv/install/was/8550.esd/
com.ibm.websphere.ND.v85_8.5.5000.20130514_1044

echo '***'
echo '*** convert WebSphere Application Server ESD format repository to a Network format repository' 
echo '***'
/opt/IBM/PackagingUtility/PUCL copy com.ibm.websphere.ND.v85 \
 -repositories /net/files/srv/install/was/8550.esd/\
 -target /net/files/srv/install/was/8550/\
 -acceptLicense\
 -showVerboseProgress

echo '***'
echo '*** check for package IDs on WebSphere Application Server Supplements 8.5.5 GA repository'
echo '***'
imcl listAvailablePackages -repositories /net/files/srv/install/wassup/8550.esd/
echo '*** output should be:'
echo com.ibm.websphere.APPCLIENT.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.IHS.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.PLG.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.PLUGCLIENT.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.WCT.v85_8.5.5000.20130514_1044

echo '***'
echo '*** rather than converting each package individually, we can just loop over the '
echo '*** previous output.'
echo '***'
for i in $(imcl listAvailablePackages -repositories /net/files/srv/install/wassup/8550.esd/); do
echo '*** converting $i'
/opt/IBM/PackagingUtility/PUCL copy $i\
 -repositories /net/files/srv/install/wassup/8550.esd/\
 -target /net/files/srv/install/wassup/8550/\
 -acceptLicense\
 -showVerboseProgress
done

echo '***'
echo '*** Check for package IDs on IBM Java 7.0.4.001 GA repository'
echo '***'
imcl listAvailablePackages -repositories /net/files/srv/install/ibmwasjava/704001.esd
echo '*** output should be:'
echo com.ibm.websphere.IBMJAVA.v70_7.0.4001.20130510_2103
echo com.ibm.websphere.liberty.IBMJAVA.v70_7.0.4001.20130510_2103

echo '***'
echo '*** Convert WebSphere Application Server ESD format repository to a Network format repository'
echo '***'
for i in $(imcl listAvailablePackages -repositories /net/files/srv/install/ibmwasjava/704001.esd/); do
echo '*** converting $i'
/opt/IBM/PackagingUtility/PUCL copy $i\
 -repositories /net/files/srv/install/ibmwasjava/704001.esd/\
 -target /net/files/srv/install/ibmwasjava/704001/\
 -acceptLicense\
 -showVerboseProgress
done

echo '***'
echo '*** Lets just check that we can get a package listing for each repository over HTTP.'
echo '***'

echo '*** converting http://ftp.example.com/was/8550'
imcl listAvailablePackages -repositories http://ftp.example.com/was/8550
echo '*** output should be:'
echo com.ibm.websphere.ND.v85_8.5.5000.20130514_1044

echo '*** converting http://ftp.example.com/wassup/8550'
imcl listAvailablePackages -repositories http://ftp.example.com/wassup/8550
echo '*** output should be:'
echo com.ibm.websphere.APPCLIENT.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.IHS.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.PLG.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.PLUGCLIENT.v85_8.5.5000.20130514_1044
echo com.ibm.websphere.WCT.v85_8.5.5000.20130514_1044

echo '*** converting http://ftp.example.com/ibmwasjava/704001'
imcl listAvailablePackages -repositories http://ftp.example.com/ibmwasjava/704001
echo '*** output should be:'
echo com.ibm.websphere.IBMJAVA.v70_7.0.4001.20130510_2103
echo com.ibm.websphere.liberty.IBMJAVA.v70_7.0.4001.20130510_2103

echo '***'
echo '*** remove old ESD repositories'
echo '***'
rm -fr /net/files/srv/install/was/8550.esd
rm -fr /net/files/srv/install/wassup/8550.esd
rm -fr /net/files/srv/install/ibmwasjava/704001.esd
