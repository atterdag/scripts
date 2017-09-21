#!/bin/sh
for i in `lxc-ls | sed 's|*.\s|\n|'`; do lxc-stop -n $i; done
