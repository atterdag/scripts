#!/bin/sh

echo '***'
echo '*** dump etcd user password in a file'
echo '***'
echo "<etcd user password>" > ~/.ETCD_USER_PASS

echo '***'
echo '*** create and load script to import openstack configuration'
echo '***'
cat > $HOME/prepare-node.env << EOF
##############################################################################
# Getting the environment up for a node
##############################################################################
if [[ ! \$0 =~ bash ]]; then
 echo "You cannot _run_ this script, you have to *source* it."
 exit 1
fi

# You have to set this by hand
export MANAGEMENT_FQDN=aku.se.lemche.net

# Get read privileges to etcd
ETCD_USER_PASS=\$(cat ~/.ETCD_USER_PASS)

if [[ "\$MANAGEMENT_FQDN" == "" ]]; then
 echo "You have to set MANAGEMENT_FQDN variable before sourcing this file!"
 return
fi

export ETCDCTL_ENDPOINTS="https://\${MANAGEMENT_FQDN}:2379"

# Create variables with infrastructure configuration
for key in \$(etcdctl ls /variables/ | sed 's|^/variables/||'); do
    export eval \$key="\$(etcdctl get /variables/\$key)"
done

# Create variables with secrets
for secret in \$(etcdctl --username user:\$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
    export eval \$secret="\$(etcdctl --username user:\$ETCD_USER_PASS get /passwords/\$secret)"
done

source <(sudo cat /etc/kolla/admin-openrc.sh)
EOF

echo '***'
echo '*** setup virtualenvwrapper'
echo '***'
if [[ ! -d $HOME/.virtualenvs ]]; then mkdir $HOME/.virtualenvs; fi
if grep -q "^export WORKON_HOME=$HOME/.virtualenv" $HOME/.bashrc; then
  cat >> $HOME/.bashrc << EOT
export WORKON_HOME=$HOME/.virtualenvs
[[ -x "/usr/local/bin/virtualenvwrapper.sh" ]] && source "/usr/local/bin/virtualenvwrapper.sh"
EOT
fi
source $HOME/.bashrc

echo '***'
echo '*** Configure pip'
echo '***'
if [[ ! -d  $HOME/.pip ]]; then mkdir  $HOME/.pip; fi
cat > $HOME/.pip/pip.conf << EOF
[list]
format = columns
EOF

echo '***'
echo '*** setup ansible'
echo '***'
if [[ ! -d /etc/ansible ]]; then sudo mkdir /etc/ansible; fi
cat << EOF | sudo tee /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
stdout_callback = yaml
deprecation_warnings=False
EOF