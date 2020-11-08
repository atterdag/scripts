echo '***'
echo '*** correct FQDN'
echo '***'
for server in 192.168.8.8 192.168.8.9 192.168.8.11 192.168.8.12 192.168.8.13; do
  ssh-keygen -f "/home/atterdag/.ssh/known_hosts" -R "$server"
  ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@${server} "sudo hostnamectl set-hostname \$(echo \$(hostname | sed 's|k8s-||'))"
  ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@${server} "sudo hostnamectl set-hostname \$(echo \$(hostname | sed 's|\..*||'))"
  ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@${server} "hostname"
  ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@${server} "sudo reboot"
done
for server in 192.168.8.8 192.168.8.9 192.168.8.11 192.168.8.12 192.168.8.13; do
  ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@${server} "free -m"
done
