#!/bin/sh

echo '***'
echo '*** install software required to run ansible, molecule, docker-compose  etc'
echo '***'
sudo apt-get install -y \
  bash-completion \
  python-dev \
  python-virtualenv \
  gcc \
  git

echo '***'
echo '*** Configure pip'
echo '***'
mkdir ~/.pip/
cat > ~/.pip/pip.conf << EOF
[list]
format = columns
EOF

echo '***'
echo '*** add Python virtualenv environment'
echo '***'
virtualenv ~/venv/ansible
~/venv/ansible/bin/pip install -U \
  ansible-tower-cli \
  ansible \
  docker \
  docker-compose \
  jmespath \
  molecule \
  requests \
  shade

echo '***'
echo '*** install Docker Compose bash completion'
echo '***'
mkdir ~/.bash_completion.d
curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o ~/.bash_completion.d/docker-compose
echo 'for i in ~/.bash_completion.d/*; do source $i; done' > ~/.bash_completion

echo '***'
echo '*** install Git prompt'
echo '***'
git clone https://github.com/magicmonty/bash-git-prompt ~/src/github/magicmonty/bash-git-prompt
echo 'source ~/src/github/magicmonty/bash-git-prompt/gitprompt.sh' > ~/.bash_completion.d/gitprompt

echo '***'
echo '*** reload bash completion'
echo '***'
source ~/.bash_completion

echo '***'
echo '*** testing'
echo '***'
source ~/venv/ansible/bin/activate
mkdir ~/src
cd ~/src
molecule init role --role-name hello
cd hello
cat > meta/main.yml << EOF
---
galaxy_info:
  author: $USER
  description: Hello World test
  company: Lemche.NET
  license: BSD
  min_ansible_version: 1.2
  platforms:
    - name: Centos
      versions:
        - all
  galaxy_tags: []
dependencies: []
EOF
molecule --debug test
cat ~/src/hello/molecule/default/pytestdebug.log

echo '***'
echo -n '*** creating hello-world container'
cat > ~/src/hello/docker-compose.yml << EOF
hello:
  container_name: "hello"
  dns_search: se.lemche.net
  hostname: hello
  image: hello-world
  restart: "no"
EOF
(cd ~/src/hello/; docker-compose up)
echo '***'

echo '***'
echo '*** clean up'
echo '***'
rm -fr ~/src/hello
