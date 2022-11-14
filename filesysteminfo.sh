#!/bin/bash

set -e

function system_info() {
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                  |Total Used      ||"
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | sort -u)
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1,3,6)
    total_used=$(df -a -t $tipo | awk 'BEGIN {total=0} {total = total + $3} END {print total}')
    line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s ||\n" $line $total_used)
    
    tabla="$tabla""$line"
    tabla+=$'\n'"||-----------------------------------------------------------------------------------------------------------------------||"$'\n'
  done
  echo "$tabla"
}

function device_files() {
  echo "||---------------------------------------------------------------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                  |Total Used      |Stat Lower      |Stat Higher     ||"
  echo "||---------------------------------------------------------------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | sort -u)
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | tail -n +2 | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1,3,6)
    total_used=$(df -a -t $tipo | awk 'BEGIN {total=0} {total = total + $3} END {print total}')
    dispositive=$(df -a -t $tipo | tr -s ' ' | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1)
    if [ -e $dispositive ]; then
      stat_lower=$(stat -c %t $dispositive)
      stat_higher=$(stat -c %T $dispositive)
      line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s ||\n" $line $total_used $stat_lower $stat_higher)
    else
      line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s ||\n" $line $total_used "*" "*")
    fi
    
    tabla="$tabla""$line"
    tabla+=$'\n'"||---------------------------------------------------------------------------------------------------------------------------------------------------------||"$'\n'
  done
  echo "$tabla"
}

function inverse() {
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                  |Total Used      ||"
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | sort -u | sort -r)
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | tail -n +2 | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1,3,6)
    total_used=$(df -a -t $tipo | awk 'BEGIN {total=0} {total = total + $3} END {print total}')
    line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s ||\n" $line $total_used)
    
    tabla="$tabla""$line"
    tabla+=$'\n'"||-----------------------------------------------------------------------------------------------------------------------||"$'\n'
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
      "-devicefiles")
        device_files
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