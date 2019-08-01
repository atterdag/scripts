#!/bin/sh

##############################################################################
# Include neutron commands in bash completion on Controller host
##############################################################################
openstack complete \
| sudo tee /etc/bash_completion.d/osc.bash_completion \
> /dev/null

source /etc/bash_completion
