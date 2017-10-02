#!/bin/sh

. `dirname $0`/properties.sh

docker image rm registry.example.com:5000/wp85:${WP_CF}

docker container commit \
 --author="Valdemar Lemche <ext.valdemar.lemche@dsv.com>" \
 --message="WebSphere Portal 8.5 CF14 installed on WebSphere Application Server 8.5.5.11, running IBM Java 8.0.3.20 on Ubuntu Trusty" \
 --change='ENTRYPOINT ["'${BASE_INSTALLATION_PATH}'/WebSphere/wp_profile/bin/start_WebSphere_Portal.sh"]' \
 --change='USER "was"' \
 wp85${WP_CF} \
 registry.example.com:5000/wp85:${WP_CF}
