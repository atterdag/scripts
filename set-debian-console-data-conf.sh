#!/bin/sh

apt-get -y remove --purge consolekit keyboard-configuration console-common console-data console-setup
#apt-get -y install console-common console-setup debconf-utils keyboard-configuration
DEBIAN_FRONTEND=noninteractive apt-get -y install console-common console-setup debconf-utils 

cat > /tmp/keyboard-configuration.debconf << EOF
keyboard-configuration  keyboard-configuration/altgr    select  The default for the keyboard layout
keyboard-configuration  keyboard-configuration/compose  select  No compose key
keyboard-configuration  keyboard-configuration/ctrl_alt_bksp    boolean false
keyboard-configuration  keyboard-configuration/layoutcode       string  dk
keyboard-configuration  keyboard-configuration/layout   select
keyboard-configuration  keyboard-configuration/modelcode        string  pc105
keyboard-configuration  keyboard-configuration/model    select  Generic 105-key (Intl) PC
keyboard-configuration  keyboard-configuration/optionscode      string
keyboard-configuration  keyboard-configuration/store_defaults_in_debconf_db     boolean true
keyboard-configuration  keyboard-configuration/switch   select  No temporary switch
keyboard-configuration  keyboard-configuration/toggle   select  No toggling
keyboard-configuration  keyboard-configuration/unsupported_config_layout        boolean true
keyboard-configuration  keyboard-configuration/unsupported_config_options       boolean true
keyboard-configuration  keyboard-configuration/unsupported_layout       boolean true
keyboard-configuration  keyboard-configuration/unsupported_options      boolean true
keyboard-configuration  keyboard-configuration/variantcode      string
keyboard-configuration  keyboard-configuration/variant  select  Danish
keyboard-configuration  keyboard-configuration/xkb-keymap       select  dk
EOF
debconf-set-selections < /tmp/keyboard-configuration.debconf

cat > /tmp/console-setup.debconf << EOF
console-setup   console-setup/store_defaults_in_debconf_db      boolean true
console-setup   console-setup/fontsize  string
console-setup   console-setup/fontsize-text47   select  8x16
console-setup   console-setup/codeset47 select  # Latin1 and Latin5 - western Europe and Turkic languages
console-setup   console-setup/fontface47        select  Do not change the boot/kernel font
console-setup   console-setup/codesetcode       string  Lat15
console-setup   console-setup/charmap47 select  UTF-8
console-setup   console-setup/fontsize-fb47     select  8x16
EOF
debconf-set-selections < /tmp/console-setup.debconf

cat > /tmp/console-common.debconf << EOF
console-common  console-data/bootmap-md5sum     string  d7eeab8322dc2529423844419f7388e8
console-common  console-data/keymap/family      select  qwerty
console-common  console-data/keymap/full        select
console-common  console-data/keymap/ignored     note
console-common  console-data/keymap/policy      select  Select keymap from arch list
console-common  console-data/keymap/powerpcadb  boolean
console-common  console-data/keymap/template/keymap     select
console-common  console-data/keymap/template/layout     select
console-common  console-data/keymap/template/variant    select
EOF
debconf-set-selections < /tmp/console-common.debconf

cat > /tmp/console-data.debconf << EOF
console-data    console-data/bootmap-md5sum     string  d7eeab8322dc2529423844419f7388e8
console-data    console-data/keymap/azerty/belgian/apple_usb/keymap     select
console-data    console-data/keymap/azerty/belgian/standard/keymap      select
console-data    console-data/keymap/azerty/belgian/variant      select
console-data    console-data/keymap/azerty/belgian/wang/keymap  select
console-data    console-data/keymap/azerty/french/apple_usb/keymap      select
console-data    console-data/keymap/azerty/french/same_as_x11__latin_9_/keymap  select
console-data    console-data/keymap/azerty/french/variant       select
console-data    console-data/keymap/azerty/layout       select
console-data    console-data/keymap/dvorak/layout       select
console-data    console-data/keymap/dvorak/unknown/apple_usb/keymap     select
console-data    console-data/keymap/dvorak/unknown/left_single-handed/keymap    select
console-data    console-data/keymap/dvorak/unknown/right_single-handed/keymap   select
console-data    console-data/keymap/dvorak/unknown/standard/keymap      select
console-data    console-data/keymap/dvorak/unknown/variant      select
console-data    console-data/keymap/family      select  qwerty
console-data    console-data/keymap/fggiod/layout       select
console-data    console-data/keymap/fggiod/turkish/standard/keymap      select
console-data    console-data/keymap/fggiod/turkish/variant      select
console-data    console-data/keymap/full        select
console-data    console-data/keymap/ignored     note
console-data    console-data/keymap/policy      select  Select keymap from arch list
console-data    console-data/keymap/powerpcadb  boolean
console-data    console-data/keymap/qwerty/brazilian/br-latin1/keymap   select
console-data    console-data/keymap/qwerty/brazilian/standard/keymap    select
console-data    console-data/keymap/qwerty/brazilian/variant    select
console-data    console-data/keymap/qwerty/british/apple_usb/keymap     select
console-data    console-data/keymap/qwerty/british/standard/keymap      select
console-data    console-data/keymap/qwerty/british/variant      select
console-data    console-data/keymap/qwerty/bulgarian/cp_1251_coding/keymap      select
console-data    console-data/keymap/qwerty/bulgarian/standard/keymap    select
console-data    console-data/keymap/qwerty/bulgarian/variant    select
console-data    console-data/keymap/qwerty/byelorussian/standard/keymap select
console-data    console-data/keymap/qwerty/byelorussian/variant select
console-data    console-data/keymap/qwerty/canadian/english/keymap      select
console-data    console-data/keymap/qwerty/canadian/french/keymap       select
console-data    console-data/keymap/qwerty/canadian/multilingual/keymap select
console-data    console-data/keymap/qwerty/canadian/variant     select
console-data    console-data/keymap/qwerty/czech/standard/keymap        select
console-data    console-data/keymap/qwerty/czech/variant        select
console-data    console-data/keymap/qwerty/danish/standard/keymap       select  Standard
console-data    console-data/keymap/qwerty/danish/variant       select  Standard
console-data    console-data/keymap/qwerty/dutch/standard/keymap        select
console-data    console-data/keymap/qwerty/dutch/variant        select
console-data    console-data/keymap/qwerty/estonian/standard/keymap     select
console-data    console-data/keymap/qwerty/estonian/variant     select
console-data    console-data/keymap/qwerty/finnish/apple_usb/keymap     select
console-data    console-data/keymap/qwerty/finnish/old__obsolete_/keymap        select
console-data    console-data/keymap/qwerty/finnish/standard/keymap      select
console-data    console-data/keymap/qwerty/finnish/variant      select
console-data    console-data/keymap/qwerty/greek/standard/keymap        select
console-data    console-data/keymap/qwerty/greek/variant        select
console-data    console-data/keymap/qwerty/hebrew/standard/keymap       select
console-data    console-data/keymap/qwerty/hebrew/variant       select
console-data    console-data/keymap/qwerty/hungarian/standard/keymap    select
console-data    console-data/keymap/qwerty/hungarian/variant    select
console-data    console-data/keymap/qwerty/icelandic/standard/keymap    select
console-data    console-data/keymap/qwerty/icelandic/variant    select
console-data    console-data/keymap/qwerty/italian/standard/keymap      select
console-data    console-data/keymap/qwerty/italian/variant      select
console-data    console-data/keymap/qwerty/japanese/pc_110/keymap       select
console-data    console-data/keymap/qwerty/japanese/standard/keymap     select
console-data    console-data/keymap/qwerty/japanese/variant     select
console-data    console-data/keymap/qwerty/kirghiz/standard/keymap      select
console-data    console-data/keymap/qwerty/kirghiz/variant      select
console-data    console-data/keymap/qwerty/latin_american/standard/keymap       select
console-data    console-data/keymap/qwerty/latin_american/variant       select
console-data    console-data/keymap/qwerty/latvian/standard/keymap      select
console-data    console-data/keymap/qwerty/latvian/variant      select
console-data    console-data/keymap/qwerty/layout       select  Danish
console-data    console-data/keymap/qwerty/lithuanian/standard/keymap   select
console-data    console-data/keymap/qwerty/lithuanian/variant   select
console-data    console-data/keymap/qwerty/macedonian/standard/keymap   select
console-data    console-data/keymap/qwerty/macedonian/variant   select
console-data    console-data/keymap/qwerty/norwegian/standard/keymap    select
console-data    console-data/keymap/qwerty/norwegian/variant    select
console-data    console-data/keymap/qwerty/polish/standard/keymap       select
console-data    console-data/keymap/qwerty/polish/variant       select
console-data    console-data/keymap/qwerty/portugese/standard/keymap    select
console-data    console-data/keymap/qwerty/portugese/variant    select
console-data    console-data/keymap/qwerty/romanian/standard/keymap     select
console-data    console-data/keymap/qwerty/romanian/variant     select
console-data    console-data/keymap/qwerty/russian/standard/keymap      select
console-data    console-data/keymap/qwerty/russian/variant      select
console-data    console-data/keymap/qwerty/serbian/standard/keymap      select
console-data    console-data/keymap/qwerty/serbian/variant      select
console-data    console-data/keymap/qwerty/slovak/standard/keymap       select
console-data    console-data/keymap/qwerty/slovak/variant       select
console-data    console-data/keymap/qwerty/spanish/apple_usb/keymap     select
console-data    console-data/keymap/qwerty/spanish/standard/keymap      select
console-data    console-data/keymap/qwerty/spanish/variant      select
console-data    console-data/keymap/qwerty/swedish/apple_usb/keymap     select
console-data    console-data/keymap/qwerty/swedish/standard/keymap      select
console-data    console-data/keymap/qwerty/swedish/variant      select
console-data    console-data/keymap/qwerty/thai/standard/keymap select
console-data    console-data/keymap/qwerty/thai/variant select
console-data    console-data/keymap/qwerty/turkish/standard/keymap      select
console-data    console-data/keymap/qwerty/turkish/variant      select
console-data    console-data/keymap/qwerty/ukrainian/standard/keymap    select
console-data    console-data/keymap/qwerty/ukrainian/variant    select
console-data    console-data/keymap/qwerty/us_american/apple_usb/keymap select
console-data    console-data/keymap/qwerty/us_american/standard/keymap  select
console-data    console-data/keymap/qwerty/us_american/variant  select
console-data    console-data/keymap/qwertz/croat/standard/keymap        select
console-data    console-data/keymap/qwertz/croat/variant        select
console-data    console-data/keymap/qwertz/czech/standard/keymap        select
console-data    console-data/keymap/qwertz/czech/variant        select
console-data    console-data/keymap/qwertz/german/apple_usb/keymap      select
console-data    console-data/keymap/qwertz/german/standard/keymap       select
console-data    console-data/keymap/qwertz/german/variant       select
console-data    console-data/keymap/qwertz/hungarian/standard/keymap    select
console-data    console-data/keymap/qwertz/hungarian/variant    select
console-data    console-data/keymap/qwertz/layout       select
console-data    console-data/keymap/qwertz/polish/standard/keymap       select
console-data    console-data/keymap/qwertz/polish/variant       select
console-data    console-data/keymap/qwertz/serbian/standard/keymap      select
console-data    console-data/keymap/qwertz/serbian/variant      select
console-data    console-data/keymap/qwertz/slovak/standard/keymap       select
console-data    console-data/keymap/qwertz/slovak/variant       select
console-data    console-data/keymap/qwertz/slovene/standard/keymap      select
console-data    console-data/keymap/qwertz/slovene/variant      select
console-data    console-data/keymap/qwertz/swiss/french/keymap  select
console-data    console-data/keymap/qwertz/swiss/german/keymap  select
console-data    console-data/keymap/qwertz/swiss/variant        select
console-data    console-data/keymap/template/keymap     select
console-data    console-data/keymap/template/layout     select
console-data    console-data/keymap/template/variant    select
console-data    console-keymaps-acorn/keymap    select
console-data    console-keymaps-amiga/keymap    select
console-data    console-keymaps-atari/keymap    select
console-data    console-keymaps-at/keymap       select
console-data    console-keymaps-dec/keymap      select
console-data    console-keymaps-mac/keymap      select
console-data    console-keymaps-sun/keymap      select
console-data    console-keymaps-usb/keymap      select
EOF
debconf-set-selections < /tmp/console-data.debconf

rm -f /etc/console/*

dpkg-reconfigure console-setup console-data console-common keyboard-configuration initramfs-tools
#dpkg-reconfigure console-data console-common initramfs-tools 

update-grub
