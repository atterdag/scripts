#!/bin/sh

cat >> create_kolla_user.sh <<EOF
echo '***'
echo '*** create kolla management account'
echo '***'
sudo groupadd -g $DEPLOY_GROUP_ID $DEPLOY_GROUP_NAME
sudo useradd -u $DEPLOY_USER_ID -g $DEPLOY_GROUP_NAME -m -G docker -s /bin/bash $DEPLOY_USER_NAME
echo "$DEPLOY_USER_NAME ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${DEPLOY_USER_NAME}-ansible-users

echo '***'
echo '*** add ssh pub keys'
echo '***'
sudo -u $DEPLOY_USER_NAME -i mkdir /home/$DEPLOY_USER_NAME/.ssh
sudo -u $DEPLOY_USER_NAME -i chmod 0750 /home/$DEPLOY_USER_NAME/.ssh
echo "$DEPLOY_USER_SSHKEY" | sudo -u $DEPLOY_USER_NAME -i tee /home/$DEPLOY_USER_NAME/.ssh/authorized_keys
sudo -u $DEPLOY_USER_NAME -i chmod 0600 /home/$DEPLOY_USER_NAME/.ssh/authorized_keys
EOF
chmod +x create_kolla_user.sh
scp create_kolla_user.sh ${CONTROLLER_FQDN}:~/
scp create_kolla_user.sh ${COMPUTE_FQDN}:~/
ssh ${CONTROLLER_FQDN} ~/create_kolla_user.sh
ssh ${COMPUTE_FQDN} ~/create_kolla_user.sh
