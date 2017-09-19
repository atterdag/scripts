#!/bin/sh

for db in `db2 list database directory | grep "Database name" | awk '{print $4}'`; do
    db2 connect to $db
    db2 reorgchk update statistics on table all
    db2 terminate
done
