#!/bin/sh

sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="quiet"|GRUB_CMDLINE_LINUX_DEFAULT="quiet elevator=noop"|' /etc/default/grub

sudo update-grub
