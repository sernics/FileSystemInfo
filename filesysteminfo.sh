#!/bin/bash

set -e

function system_info() {
  df -h | tail -n +2 | sort -u -k 1,1 | sort | uniq | awk '{ printf "||%-20s |%-20s |%-20s||\n", $1, $3, $6}'
}

function main() {
  echo "||Filesystem           |Size                 |Mountpoint          ||"
  echo "||---------------------|---------------------|--------------------||"
  system_info
}

function helper() {
  echo "Usage: cat [OPTION]..."
  echo "This script is to get information about our diferents partitions of the disk"
  echo "It is not necesary a FILE, but if you introduce a FILE you will get the output in the file (This will be in the future"
  echo ""
  echo "-inv,       Print the inverse of the main output"
}

function inverse() {
  df -h | tail -n +2 | sort -u -k 1,1 | sort -n -r | uniq | awk '{ printf "||%-20s |%-20s |%-20s||\n", $1, $3, $6}'
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
      "--modificacion")
        ps -A -o size --no-headers | awk '{ sum+=$1 } END { print sum }'
        shift
        ;;
      * )
        echo $1
        shift
        ;;
    esac
  done
else
  main
fi
