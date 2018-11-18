#!/bin/sh

##############################################################################
# Bash completion on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion
