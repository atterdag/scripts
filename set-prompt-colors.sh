#!/bin/sh

cat > /etc/profile.d/prompt_colors.sh << EOF
# Use individual settings for each type of TERM
case "\$TERM" in
# If this is an xterm set the title to user@host:dir
xterm*|rxvt*)
    PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ '
    PROMPT_COMMAND='echo -ne "\033]0;\${USER}@\${HOSTNAME}: \${PWD/\$HOME/~}\007"'
    ;;
linux)
    PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ '
    ;;
vt100)
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
    ;;
*)
    export PS1='\h:\w\\$ '
    ;;
esac
EOF
