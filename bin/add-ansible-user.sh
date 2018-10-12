#!/bin/sh
if ! id ansible > /dev/null; then
  echo '***'
  echo '*** creating ansible group, and user'
  echo '***'
  useradd --comment "ansible runtime user,,,automation" --create-home --system --uid 500 --user-group --shell /bin/bash ansible
fi

echo '***'
echo '*** add current user ssh public key to ansible user'
echo '***'
mkdir ~ansible/.ssh
cp ~/.ssh/authorized_keys ~ansible/.ssh/authorized_keys
chown -R ansible:ansible ~ansible/.ssh
chmod 0750 ~ansible/.ssh
chmod 0640 ~ansible/.ssh/authorized_keys

echo '***'
echo '*** allow members of ansible group to perform all commands as any user without password check'
echo '***'
cat << EOF | sudo tee /etc/sudoers.d/99-ansible
%ansible   ALL=(ALL:ALL) NOPASSWD: ALL
EOF
