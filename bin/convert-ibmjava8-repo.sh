#!/bin/sh
# The IBM Java 8.0.3.0 repository was not formatted with Network repository
# format but rather the old Electronic Service Delivery format.
# (ref https://www.ibm.com/support/knowledgecenter/SSDV2W_1.8.5/com.ibm.silentinstall12.doc/topics/r_repository_types.html).
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
echo '*** rename old IBM Java 8.0.3.0 repository'
echo '***'
mv /net/files/srv/install/ibmjava/8030 /net/files/srv/install/ibmjava/8030.esd

echo '***'
echo '*** check for package IDs on WebSphere Application Server 8.5.5 GA repository'
echo '***'
imcl listAvailablePackages -repositories /net/files/srv/install/ibmjava/8030.esd/disk1
com.ibm.java.jdk.v8_8.0.3000.20160623_1418

echo '***'
echo '*** convert ESD format repository to a Network format repository'
echo '***'
/opt/IBM/PackagingUtility/PUCL copy com.ibm.java.jdk.v8 \
 -repositories /net/files/srv/install/ibmjava/8030.esd/disk1/\
 -target /net/files/srv/install/ibmjava/8030/\
 -acceptLicense\
 -showVerboseProgress

echo '***'
echo '*** Lets just check that we can get a package listing for each repository over HTTP.'
echo '***'

echo '*** converting http://ftp.example.com/was/8550'
imcl listAvailablePackages -repositories http://ftp.example.com/ibmjava/8030/
echo '*** output should be:'
com.ibm.java.jdk.v8_8.0.3000.20160623_1418

echo '***'
echo '*** remove old ESD repositories'
echo '***'
rm -fr /net/files/srv/install/ibmjava/8030.esd/
