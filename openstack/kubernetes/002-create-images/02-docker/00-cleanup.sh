echo '***'
echo '*** removing any past versions of docker'
echo '***'
sudo systemctl stop docker
sudo apt-get --yes --purge remove docker docker-engine docker.io docker-ce
sudo apt-get --yes --purge autoremove
sudo rm -fr /etc/docker

echo '***'
echo '*** removing docker filesystems'
echo '***'
sudo umount /var/lib/docker
sudo lvremove --force containers/docker
sudo vgremove --force containers
sudo pvremove --force --force --yes /dev/sdb
perl -pe 's/.*\/var\/lib\/docker.*\n//' < /etc/fstab | sudo tee /etc/fstab
sudo rm -fr /var/lib/docker

echo '***'
echo '*** removing docker systemd files'
echo '***'
sudo rm -fr /etc/systemd/system/docker.service.d/ /lib/systemd/system/docker.service
sudo systemctl daemon-reload

echo '***'
echo '*** removing docker group'
echo '***'
groupdel docker
