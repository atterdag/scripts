#!/bin/sh

apt-get -y install fortune-mod fortunes-debian-hints linuxlogo

cat > /usr/local/sbin/chmotd.sh << EOF
#!/bin/sh

OUTPUT="/etc/motd"

cat > \$OUTPUT << OUTPUT
\`/usr/bin/linux_logo -f -u -y\`
Most of the programs included with the Debian GNU/Linux system are
freely redistributable; the exact distribution terms for each program
are described in the individual files in /usr/share/doc/*/copyright

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

\`/usr/games/fortune debian-hints\`

OUTPUT
EOF

chmod +x /usr/local/sbin/chmotd.sh

cat > /etc/cron.d/chmotd << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

@reboot         root    chmotd.sh
0-59/5 * * * *  root    chmotd.sh
EOF

service cron restart
