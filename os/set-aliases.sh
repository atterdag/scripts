#!/bin/sh

cat > /etc/profile.d/aliases.sh << EOF
export LS_OPTIONS='--color=auto'
eval "\`dircolors\`"
alias ls='ls \$LS_OPTIONS'
alias ll='ls \$LS_OPTIONS -l'
alias l='ls \$LS_OPTIONS -lA'

#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF
