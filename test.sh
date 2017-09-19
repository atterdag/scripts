#!/bin/bash -x

LINE="col0 col1  col2     col3  col4      "

LINES=( $LINE )
echo ${LINES[*]}


COLS=()

for val in $LINE ; do
        COLS+=("$val")
done

for COL in ${COLS[*]}; do echo $COL; done

echo ${COLS[*]}

echo "${COLS[0]}"; # prints "col0"
echo "${COLS[1]}"; # prints "col1"
echo "${COLS[2]}"; # prints "col2"
echo "${COLS[3]}"; # prints "col3"
echo "${COLS[4]}"; # prints "col4"

