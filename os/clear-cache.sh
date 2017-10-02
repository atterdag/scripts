#!/bin/sh
sync
sync
sync
echo 3 > /proc/sys/vm/drop_caches
sync
sync
sync
echo 0 > /proc/sys/vm/drop_caches
sync
sync
sync
