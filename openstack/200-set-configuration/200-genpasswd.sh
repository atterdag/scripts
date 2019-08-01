#!/bin/sh

##############################################################################
# Create function to generate passwords
##############################################################################
cat << EOF | sudo tee /etc/profile.d/genpasswd.sh
genpasswd() {
	local l=\$1
       	[ "\$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c \${l} | xargs
}
EOF
source /etc/profile.d/genpasswd.sh
