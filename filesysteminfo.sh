#!/bin/bash

set -e

function system_info() {
  echo "||-----------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                 ||"
  echo "||-----------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | sort -u)
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1,3,6)
    line=$(printf "||%-30s |%-20s |%-20s |%-25s||\n" $line)
    tabla="$tabla""$line"
    tabla+=$'\n'"||-----------------------------------------------------------------------------------------------------||"$'\n'
  done
  echo "$tabla"
}

function inverse() {
  echo "||-----------------------------------------------------------------------------------------------------||"
  echo "|| Filesistem                    | Space               | Uso%                | Mount on                ||"
  echo "||-----------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | tail -n +2 | cut -d  ' ' -f3 | sort -u | sort -r)
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | sort -k3 -n | tail -n -1 | cut -d ' ' -f 2,5,6)
    line=$(printf "||%-30s |%-20s |%-20s |%-25s||\n" $line)
    tabla="$tabla""$line"
    tabla+=$'\n'"||-----------------------------------------------------------------------------------------------------||"$'\n'
  done
  echo "$tabla"
}

function helper() {
  echo "Usage: cat [OPTION]..."
  echo "This script is to get information about our diferents partitions of the disk"
  echo "It is not necesary a FILE, but if you introduce a FILE you will get the output in the file (This will be in the future"
  echo ""
  echo "-inv,       Print the inverse of the main output"
}

if [ $# -gt 0 ]; then
  while [ "$1" != "" ]; do
    case $1 in
      "-h" | "--help")
        helper
        shift
        ;;
      "-inv" )
        inverse
        shift
        ;;
      * )
        echo $1
        shift
        ;;
    esac
  done
else
  system_info
fi