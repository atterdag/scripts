#!/bin/bash

echo '***'
echo '*** create simple python script to get CA certifiates list from HTML'
echo '***'
cat > /tmp/get_cas.py << EOF
#!/usr/bin/env python3
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

echo '***'
echo '*** add CA certifiates to truststore'
echo '***'
export SSL_BASE_URL=http://ca.se.lemche.net

CA_CERTIFICATES=$(curl \
  --silent \
	--url ${SSL_BASE_URL} \
| /tmp/get_cas.py)

for ca_certificate in $CA_CERTIFICATES; do
  echo $ca_certificate
  sudo curl \
    --output /usr/local/share/ca-certificates/${ca_certificate} \
    --silent \
    --url http://ca.se.lemche.net/${ca_certificate}
done

sudo update-ca-certificates \
  --verbose \
  --fresh
