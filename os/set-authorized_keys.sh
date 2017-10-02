#!/bin/sh

if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi

cat > ~/.ssh/authorized_keys << EOF
<nope>
EOF
