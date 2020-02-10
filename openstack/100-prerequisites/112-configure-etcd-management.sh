#!/bin/bash

##############################################################################
# Create initial configuration for Etcd on Controller host
##############################################################################

# Generate a root password
export ETCD_ROOT_PASS=$(genpasswd 32)

# Add root user
etcdctl user add root:"$ETCD_ROOT_PASS"

# Grant root user the special root role
etcdctl user grant --roles root root

# Enable authentication for etcd
etcdctl auth enable

# Remove the guest roles access
etcdctl --username root:"$ETCD_ROOT_PASS" role revoke --path "/*" --readwrite guest

# Store etch root password
sudo touch /var/lib/openstack/ETCD_ROOT_PASS
sudo chmod 0600 /var/lib/openstack/ETCD_ROOT_PASS
echo $ETCD_ROOT_PASS | sudo tee /var/lib/openstack/ETCD_ROOT_PASS

##############################################################################
# Create areas to store configuration in etcd on Controller host
##############################################################################

# Create ephemeral path for temp data
etcdctl --username root:"$ETCD_ROOT_PASS" mkdir /ephemeral

# Create keystores path for certificate keystores
etcdctl --username root:"$ETCD_ROOT_PASS" mkdir /keystores

# Create passwords path for secrets
etcdctl --username root:"$ETCD_ROOT_PASS" mkdir /passwords

# Create secret path for local users
etcdctl --username root:"$ETCD_ROOT_PASS" mkdir /secret

# Create variables to store general configuration
etcdctl --username root:"$ETCD_ROOT_PASS" mkdir /variables

# Create roles in etcd, that we can limit access to paths
etcdctl --username root:"$ETCD_ROOT_PASS" role add admin
etcdctl --username root:"$ETCD_ROOT_PASS" role add user

# Create policy that allows users to read secrets
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /ephemeral/* --readwrite admin
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /ephemeral/* --readwrite user
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /keystores/* --readwrite admin
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /keystores/* --read user
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /passwords/* --readwrite admin
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /passwords/* --read user
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /variables/* --readwrite admin
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /passwords/* --read user
etcdctl --username root:"$ETCD_ROOT_PASS" role grant --path /variables/* --read guest

# Generate secrets for the local users
export ETCD_ADMIN_PASS=$(genpasswd 32)
export ETCD_USER_PASS=$(genpasswd 32)

# Create local users in etcd
etcdctl --username root:"$ETCD_ROOT_PASS" user add admin:$ETCD_ADMIN_PASS
etcdctl --username root:"$ETCD_ROOT_PASS" user add user:"$ETCD_USER_PASS"

# Map roles to users
etcdctl --username root:"$ETCD_ROOT_PASS" user grant --roles admin admin
etcdctl --username root:"$ETCD_ROOT_PASS" user grant --roles user user

# Store admin, and user passwords
etcdctl --username root:"$ETCD_ROOT_PASS" mk /secret/admin "$ETCD_ADMIN_PASS"
etcdctl --username root:"$ETCD_ROOT_PASS" mk /secret/user  "$ETCD_USER_PASS"

# This is prolly not a good idea
echo $ETCD_ADMIN_PASS > ~/.ETCD_ADMIN_PASS
echo $ETCD_USER_PASS > ~/.ETCD_USER_PASS
