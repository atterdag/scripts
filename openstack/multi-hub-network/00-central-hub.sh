openstack project create \
  --description "Main tenant used for solutions" \
  solutions

openstack user create \
  --project solutions \
  --password passw0rd \
  solutions_admin

openstack role add \
  --project solutions \
  --user solutions_admin \
  admin

cat > ~/os_solutions.sh <<EOF
for key in \$( set | awk '{FS="="}  /^OS_/ {print \$1}' ); do unset \$key ; done
export OS_AUTH_PLUGIN=password
export OS_AUTH_URL=https://openstack.se.lemche.net:35357/v3
export OS_CACERT=/etc/ssl/certs/ca-certificates.crt
export OS_ENDPOINT_TYPE=internalURL
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=internal
export OS_PASSWORD=passw0rd
export OS_PLACEMENT_API_VERSION=1.28
export OS_PROJECT_DOMAIN_NAME=Default
export OS_PROJECT_NAME=solutions
export OS_REGION_NAME=RegionOne
export OS_TENANT_NAME=solutions
export OS_USER_DOMAIN_NAME=Default
export OS_USERNAME=solutions_admin
EOF
source ~/os_solutions.sh
