echo '***'
echo '*** removing any past versions of docker'
echo '***'
sudo systemctl stop docker
sudo apt-get --yes --purge remove docker docker-engine docker.io docker-ce
sudo apt-get --yes --purge autoremove
sudo rm -fr /etc/docker \
            /var/lib/docker/*
sudo umount /var/lib/docker
sudo lvremove --force containers/docker
sudo vgremove --force containers
sudo pvremove --force --force --yes /dev/sdb
perl -pe 's/.*\/var\/lib\/docker.*\n//' < /etc/fstab | sudo tee /etc/fstab
sudo rm -fr /var/lib/docker
for num in $(ufw status numbered | grep dockerd | perl -pe 's/\[||]//g' | awk '{print $1}'); do
  yes | sudo ufw delete $num
done
sudo rm -fr /etc/systemd/system/docker.service.d/ /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo rm -f /etc/ufw/applications.d/docker
groupdel docker
sudo reboot
