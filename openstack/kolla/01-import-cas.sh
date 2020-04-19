#!/bin/sh

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

cat << EOF | sudo tee /etc/profile.d/syv.sh
syv() {
  if [[ -z \$3 ]]; then
    echo 'syv sets or updates a string variable in a yaml file - it is very crude ...'
    echo
    echo '!!! bad input - syv <variable name> <variable value> <file>'
    return 1
  fi
  local _variable_name=\$1
  local _variable_value=\$2
  local _file=\$3
  if grep -q -E "^\$_variable_name|^#\$_variable_name" \$_file; then \
    sed -r -i 's/^'\$_variable_name':.*|^#'\$_variable_name':.*/'\$_variable_name': "'\$_variable_value'"/' \$_file
  else
    echo ''\$_variable_name': "'\$_variable_value'"' >> \$_file
  fi
}
EOF
source /etc/profile.d/syv.sh

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
	  --url ${SSL_BASE_URL}/${ca_certificate}
done

sudo update-ca-certificates \
  --verbose \
  --fresh
