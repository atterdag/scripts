#!/bin/sh

cat << EOF | sudo tee /etc/X11/xorg.conf.d/TouchPad.conf
Section "InputClass"
  Identifier "touchpad catchall"
  MatchIsTouchpad "on"
  Driver "synaptics"
  Option "VertTwoFingerScroll" "1"
  Option "MinSpeed" "1.1"
  Option "MaxSpeed" "1.1"
  Option "AccelFactor" "1"
  Option "PalmDetect" "1"
  Option "PressureMotionMinZ" "200"
  Option "PalmMinZ" "255"
EndSection
EOF
