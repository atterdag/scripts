#!/bin/bash

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
sudo apt-get --yes --quiet --fix-missing install \
  apt-transport-https \
  curl \
  gnupg

curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
## Installs the latest Erlang 22.x release.
## Change component to "erlang-21.x" to install the latest 21.x version.
## "bionic" as distribution name should work for any later Ubuntu or Debian release.
## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang
deb https://dl.bintray.com/rabbitmq/debian bionic main
EOF

sudo apt-get --yes update

sudo apt-get --yes --quiet --fix-missing install \
  rabbitmq-server

curl https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/master/bin/rabbitmqadmin \
  | sudo tee /usr/local/sbin/rabbitmqadmin

sudo chown root:root /usr/local/sbin/rabbitmqadmin
sudo chmod 0755 /usr/local/sbin/rabbitmqadmin

##############################################################################
# Enable SSL for RabbitMQ on Controller host
##############################################################################
cat <<EOF | sudo tee /etc/rabbitmq/rabbitmq.config
[
  {ssl,
    [
      {versions,                  ['tlsv1.2', 'tlsv1.1', 'tlsv1']}
    ]
  },
  {rabbit,
    [
      {ssl_listeners,             [5671]},
      {ssl_options,
        [
          {cacertfile,            "/etc/ssl/certs/ca-certificates.crt"},
          {certfile,              "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"},
          {keyfile,               "/etc/ssl/private/${CONTROLLER_FQDN}.key"},
          {versions,              ['tlsv1.2', 'tlsv1.1', 'tlsv1']},
          {ciphers,               [
                                    "ECDHE-ECDSA-AES256-GCM-SHA384",
                                    "ECDHE-RSA-AES256-GCM-SHA384",
                                    "ECDHE-ECDSA-AES256-SHA384",
                                    "ECDHE-RSA-AES256-SHA384",
                                    "ECDH-ECDSA-AES256-GCM-SHA384",
                                    "ECDH-RSA-AES256-GCM-SHA384",
                                    "ECDH-ECDSA-AES256-SHA384",
                                    "ECDH-RSA-AES256-SHA384",
                                    "DHE-RSA-AES256-GCM-SHA384",
                                    "DHE-DSS-AES256-GCM-SHA384",
                                    "DHE-RSA-AES256-SHA256",
                                    "DHE-DSS-AES256-SHA256",
                                    "AES256-GCM-SHA384",
                                    "AES256-SHA256",
                                    "ECDHE-ECDSA-AES128-GCM-SHA256",
                                    "ECDHE-RSA-AES128-GCM-SHA256",
                                    "ECDHE-ECDSA-AES128-SHA256",
                                    "ECDHE-RSA-AES128-SHA256",
                                    "ECDH-ECDSA-AES128-GCM-SHA256",
                                    "ECDH-RSA-AES128-GCM-SHA256",
                                    "ECDH-ECDSA-AES128-SHA256",
                                    "ECDH-RSA-AES128-SHA256",
                                    "DHE-RSA-AES128-GCM-SHA256",
                                    "DHE-DSS-AES128-GCM-SHA256",
                                    "DHE-RSA-AES128-SHA256",
                                    "DHE-DSS-AES128-SHA256",
                                    "AES128-GCM-SHA256",
                                    "AES128-SHA256",
                                    "ECDHE-ECDSA-AES256-SHA",
                                    "ECDHE-RSA-AES256-SHA",
                                    "DHE-RSA-AES256-SHA",
                                    "DHE-DSS-AES256-SHA",
                                    "ECDH-ECDSA-AES256-SHA",
                                    "ECDH-RSA-AES256-SHA",
                                    "AES256-SHA",
                                    "ECDHE-ECDSA-DES-CBC3-SHA",
                                    "ECDHE-RSA-DES-CBC3-SHA",
                                    "EDH-RSA-DES-CBC3-SHA",
                                    "EDH-DSS-DES-CBC3-SHA",
                                    "ECDH-ECDSA-DES-CBC3-SHA",
                                    "ECDH-RSA-DES-CBC3-SHA",
                                    "DES-CBC3-SHA",
                                    "ECDHE-ECDSA-AES128-SHA",
                                    "ECDHE-RSA-AES128-SHA",
                                    "DHE-RSA-AES128-SHA",
                                    "DHE-DSS-AES128-SHA",
                                    "ECDH-ECDSA-AES128-SHA",
                                    "ECDH-RSA-AES128-SHA",
                                    "AES128-SHA",
                                    "EDH-RSA-DES-CBC-SHA",
                                    "DES-CBC-SHA"
                                  ]},
          {verify,                verify_none},
          {fail_if_no_peer_cert,  false}
        ]
      }
    ]
  },
  {rabbitmq_management,
    [
      {http_log_dir,              "/var/log/rabbitmq/"},
      {listener,
        [
          {port,                  15671},
          {ssl,                   true},
          {ssl_opts,
            [
              {cacertfile,        "/etc/ssl/certs/ca-certificates.crt"},
              {certfile,          "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"},
              {keyfile,           "/etc/ssl/private/${CONTROLLER_FQDN}.key"}
            ]
          },
          {verify,                verify_none},
          {fail_if_no_peer_cert,  false},
          {client_renegotiation,  false},
          {secure_renegotiate,    true},
          {honor_ecc_order,       true},
          {honor_cipher_order,    true},
          {versions,              ['tlsv1.1', 'tlsv1.2']},
          {ciphers,               [
                                    "ECDHE-ECDSA-AES256-GCM-SHA384",
                                    "ECDHE-RSA-AES256-GCM-SHA384",
                                    "ECDHE-ECDSA-AES256-SHA384",
                                    "ECDHE-RSA-AES256-SHA384",
                                    "ECDH-ECDSA-AES256-GCM-SHA384",
                                    "ECDH-RSA-AES256-GCM-SHA384",
                                    "ECDH-ECDSA-AES256-SHA384",
                                    "ECDH-RSA-AES256-SHA384",
                                    "DHE-RSA-AES256-GCM-SHA384"
                                  ]}
        ]
      }
    ]
  }
].
EOF

sudo usermod -a -G ssl-cert rabbitmq

##############################################################################
# Restart rabbitmq server on Controller host
##############################################################################
sudo systemctl restart \
  rabbitmq-server

# Check that rabbitmq is using the correct certificate
echo Q | openssl s_client -connect ${CONTROLLER_FQDN}:amqps | openssl x509 -text

##############################################################################
# Add RabbitMQ management plugin on Controller host
##############################################################################
sudo rabbitmq-plugins enable rabbitmq_management

# Check that rabbitmq is using the correct certificate
echo Q | openssl s_client -connect ${CONTROLLER_FQDN}:15671 | openssl x509 -text

##############################################################################
# Add RabbitMQ management admin user on Controller host
##############################################################################
sudo rabbitmqctl add_user admin $RABBIT_ADMIN_PASS
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
sudo rabbitmqctl set_user_tags admin administrator

##############################################################################
# Add OpenStack user on Controller host
##############################################################################
sudo rabbitmqctl add_user openstack $RABBIT_PASS
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##############################################################################
# Enable bash completion rabbitmqadmin on Controller host
##############################################################################
rabbitmqadmin --bash-completion \
  | sudo tee /etc/bash_completion.d/rabbitmqadmin
