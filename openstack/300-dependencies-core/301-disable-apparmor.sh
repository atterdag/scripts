#!/bin/bash

##############################################################################
# Missing apparmor profiles for new version of MariaDB
##############################################################################
sudo systemctl disable apparmor
sudo systemctl stop apparmor
