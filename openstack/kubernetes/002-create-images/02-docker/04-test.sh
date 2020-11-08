#!/bin/sh

echo '***'
echo '*** add user to docker group'
echo '***'
sudo usermod --append --groups docker $USER

echo '***'
echo '*** test docker'
echo '***'
sudo sg docker -c "docker container run hello-world"
