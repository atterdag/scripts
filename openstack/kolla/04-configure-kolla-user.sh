#!/bin/sh

echo '***'
echo '*** Get read privileges to etcd'
echo '***'
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi

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

# Get read privileges to etcd
if [[ -z \${ETCD_USER_PASS+x} ]]; then
  echo "ETCD_USER_PASS is undefined, run the following to set it"
  echo 'echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS'
  return 1
fi

if [[ -d /etc/kolla ]]; then
  source <(sudo cat /etc/kolla/admin-openrc.sh)
fi

export ETCDCTL_DISCOVERY_SRV="\$(hostname -d)"

# Create variables with infrastructure configuration
for key in \$(etcdctl ls /variables/ | sed 's|^/variables/||'); do
    export eval \$key="\$(etcdctl get /variables/\$key)"
done

# Create variables with secrets
for secret in \$(etcdctl --username user:\$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
    export eval \$secret="\$(etcdctl --username user:\$ETCD_USER_PASS get /passwords/\$secret)"
done
EOF
source $HOME/prepare-node.env

echo '***'
echo '*** setup virtualenvwrapper'
echo '***'
if [[ ! -d $HOME/.virtualenvs ]]; then mkdir $HOME/.virtualenvs; fi
if ! grep -q "^export WORKON_HOME=$HOME/.virtualenvs" $HOME/.bashrc; then
  cat >> $HOME/.bashrc << EOT
export WORKON_HOME=$HOME/.virtualenvs
[[ -x "/usr/local/bin/virtualenvwrapper.sh" ]] && source "/usr/local/bin/virtualenvwrapper.sh"
EOT
  source $HOME/.bashrc
fi

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
