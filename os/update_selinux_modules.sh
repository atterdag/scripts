#/bin/sh

USAGE="usage: $0 [-u] [-?] \n
-u will update the existing modules from dmesg output \n
-? shows this help \n"

ARGUMENT="--all"

while getopts :u opt; do
  case $opt in
    u)
      ARGUMENT="-d"
      ;;
    \?)
      echo $USAGE
      exit 1
    ;;
  esac
done

for SEMODULE in `audit2allow ${ARGUMENT} | grep \#= | sed 's/\#//' | sed 's/=//g'`; do
  audit2allow -t ${SEMODULE} ${ARGUMENT} -m ${SEMODULE} > ${SEMODULE}.te
  cat ${SEMODULE}.te
  checkmodule -M -m -o ${SEMODULE}.mod ${SEMODULE}.te
  semodule_package -o ${SEMODULE}.pp -m ${SEMODULE}.mod
  semodule -i ${SEMODULE}.pp
done
