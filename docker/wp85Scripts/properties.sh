# Network location of installation files
SOURCE_NETWORK_PATH="/net/files/srv/install"

# Mounted volume on docker container, where it can reach the installation files
#SOURCE_PATH="/host/install"
SOURCE_PATH="/net/files/srv/install"

# Define which fixpack levels to use
IM_FP="1870"
WAS_FP="85511"
JDK70_FP="70960"
JDK71_FP="71360"
JDK80_FP="80320"
WP_CF="cf14"

# General availability (i.e first release) installation files. These files are
# used during the initial installation
IM_REPOSITORY_IM_GA="${SOURCE_PATH}/im/1850/linux64"
IM_REPOSITORY_WAS_GA="${SOURCE_PATH}/wp/8500/WAS8552"
IM_REPOSITORY_JDK70_GA="${SOURCE_PATH}/wp/8500/IBMJAVA7"
IM_REPOSITORY_JDK71_GA="${SOURCE_PATH}/ibmwasjava/7100"
IM_REPOSITORY_JDK80_GA="${SOURCE_PATH}/ibmwasjava/8000"
IM_REPOSITORY_WP_GA="${SOURCE_PATH}/wp/8500/WP85_Server"
IM_REPOSITORY_WCM_GA="${SOURCE_PATH}/wcm/8500/WP85_WCM"

# The fix pack installation files that you want to update to. These locations
# are both referenced during the initial installation, but also during later
# update installations.
IM_REPOSITORY_IM_FP="${SOURCE_PATH}/imfps/${IM_FP}"
IM_REPOSITORY_WAS_FP="${SOURCE_PATH}/wasfps/${WAS_FP}/was"
IM_REPOSITORY_JDK70_FP="${SOURCE_PATH}/ibmwasjava/${JDK70_FP}"
IM_REPOSITORY_JDK71_FP="${SOURCE_PATH}/ibmwasjava/${JDK71_FP}"
IM_REPOSITORY_JDK80_FP="${SOURCE_PATH}/ibmwasjava/${JDK80_FP}"
IM_REPOSITORY_WP_CF="${SOURCE_PATH}/wpcfs/8500${WP_CF}/server"

# The base directory where all software is installed under
BASE_INSTALLATION_PATH="/opt/IBM"

# Where to create the Portal WAS profile
PROFILE_LOCATION="${BASE_INSTALLATION_PATH}/WebSphere/wp_profile"

# DNS hostname for the container
HOSTNAME="wp85${WP_CF}"
# IP address for container
IP_ADDRESS="172.16.228.11"
# User defined network
NETWORK="172.16.228.0"
# User defined network subnet mask
NETWORK_MASK="24"
# User defined network name
NETWORK_NAME="devnet"
# DNS zone name for the container network
DOMAINNAME="docker.dsv.com"
# WAS portal node name
NODENAME="${HOSTNAME}Node01"
# Portal server starting port
STARTINGPORT="10012"
# The portal, and ConfigWizard wasadmin, and wpsadmin username, and password
INSTALLUSERNAME="wpsadmin"
INSTALLPASSWORD="passw0rd"

# Proxy server
PROXYHOST="cache.example.com"
PROXYPORT="3128"
PROXYUSER="proxyuser"
PROXYPASS="passw0rd"
