#!/usr/bin/env bash

sudo yum install -y python3-devel libffi-devel gcc openssl-devel libselinux-python python-virtualenv

if [[ ! -d $HOME/.virtualenvs ]]; then mkdir $HOME/.virtualenvs; fi
virtualenv --python=/usr/bin/python3 $HOME/.virtualenvs/importcas
source $HOME/.virtualenvs/importcas/bin/activate
pip install -U pip

if [[ ! -d  $HOME/.pip/ ]]; then mkdir  $HOME/.pip/; fi
cat > $HOME/.pip/pip.conf << EOF
[list]
format = columns
EOF

pip install -U \
  bs4 \
  lxml

cat > /tmp/get_cas.py << EOF
#!/usr/bin/env python
from bs4 import BeautifulSoup
import sys
import re
data = sys.stdin.readlines()
html = ' '.join(map(str, data))
soup = BeautifulSoup(html,"lxml")
for link in soup.find_all('a'):
  href = link.get('href')
  if re.search('.crt', href):
    print(href)
EOF
chmod +x /tmp/get_cas.py

CA_CERTIFICATES=$(curl \
  --silent \
	--url http://ca.se.lemche.net/ \
| /tmp/get_cas.py)

for ca_certificate in $CA_CERTIFICATES; do
  echo $ca_certificate
  sudo curl \
    --output /etc/pki/ca-trust/source/anchors/${ca_certificate} \
    --silent \
    --url http://ca.se.lemche.net/${ca_certificate}
done

sudo update-ca-trust

deactivate

rm -fr $HOME/.virtualenvs/importcas
