echo '***'
echo '*** clean downloaded packages'
echo '***'
sudo apt-get --yes --quiet clean

echo '***'
echo '*** shutdown server'
echo '***'
sudo poweroff
