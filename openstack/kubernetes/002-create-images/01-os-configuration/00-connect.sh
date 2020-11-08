ssh-keygen -f "/home/atterdag/.ssh/known_hosts" -R "192.168.254.84"
ssh -o StrictHostKeyChecking=no debian@192.168.254.84 hostname
ssh -o StrictHostKeyChecking=no -J debian@192.168.254.84 debian@192.168.8.3
