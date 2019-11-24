#!/bin/sh

scripts="install-debian-autofs.sh \
set-aliases.sh \
set-prompt-colors.sh \
configure-ssh.sh \
set-authorized_keys.sh \
add-proxyenv.sh \
set-debian-sources.sh \
add-debian-ca.sh \
add-debian-chmotd.sh \
add-debian-statistics.sh \
install-debian-sudo.sh \
install-debian-tools.sh \
install-debian-ufw.sh \
set-debian-remote-logging.sh \
set-debian-console-data-conf.sh \
set-debian-network.sh \
set-debian-elevator-boot.sh \
install-debian-open-vm.sh"

echo "creating /var/www/html/debian-scripts.tar with $scripts"
sudo cd /srv/bin
sudo tar cf /var/www/html/debian-scripts.tar $scripts

echo "creating run_all.sh script"
echo "#!/bin/sh" > /tmp/run_all.sh
for script in $scripts; do
	echo "./$script" >> /tmp/run_all.sh
done
chmod +x /tmp/run_all.sh

echo "adding run_all.sh to /var/www/html/debian-scripts.tar"
cd /tmp
sudo tar rf /var/www/html/debian-scripts.tar run_all.sh
