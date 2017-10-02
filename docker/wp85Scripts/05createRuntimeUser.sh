#!/bin/bash

. `dirname $0`/properties.sh

. /etc/profile.d/proxyenv.sh

echo '*** adding imcl to PATH'
cat > /etc/profile.d/imcl_path.sh << EOF
#!/bin/sh
PATH=\${PATH}:${BASE_INSTALLATION_PATH}/InstallationManager/eclipse/tools
export PATH
EOF

echo '*** downloading imcl bash completion script from Github'
wget --no-check-certificate -O /etc/bash_completion.d/imcl "https://raw.githubusercontent.com/atterdag/bash-completion-imcl/master/imcl" || exit 1

echo '*** adding was group'
groupadd -g 500 -r was || exit 1

echo '*** adding was runtime user'
useradd -r -u 500 -g was -m -s /bin/false was || exit 1

echo '*** creating base installation directory'
mkdir -p $BASE_INSTALLATION_PATH || exit 1

echo '*** changing ownership of base installation directory to was:was'
chown was:was $BASE_INSTALLATION_PATH || exit 1
