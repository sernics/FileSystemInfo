#!/bin/bash

# TODO:
# - Usuarios
# - Ordenaciones: 
#   - sopen: La ordenación se hará por el número de archivos abiertos, y solo se podrá usar con las opciones -devicefiles y/o -u, dado que solo se considerarán los dispositivos con archivos de dispositivo asociados. 
#Si no se cumple esta regla debe producirse un error que deberá ser gestionado correctamente en el script.
#   - sdevice: la ordenación se realizará por el número total de dispositivos considerados para cada sistema de archivos.
#   - inv: la ordenación se realizará por el número total de dispositivos considerados para cada sistema de archivos, pero en orden inverso.
#  DEBEN PODER SER USADAS JUNTAS, POR EJEMPLO: -sopen -inv -u sernics

# Esta linea la pongo para que se me ejecute el script en modo desarrollador
set -e

are_usuarios=0
usuarios=""

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
  echo "||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                  |Total Used      |Stat Lower      |Stat Higher     |Lsof            ||"
  echo "||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------||"
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
      lsof_value=$(lsof $dispositive | wc -l)
      line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s |%-15s ||\n" $line $total_used $stat_lower $stat_higher $lsof_value)
    else
      asterisco="*"
      line=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s |%-15s ||\n" $line $total_used "*" "*" "*")
    fi
    
    tabla="$tabla""$line"
    tabla+=$'\n'"||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------||"$'\n'                               
  done
  echo "$tabla"
}

function inverse() {
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  echo "||Filesistem                     |Dispositive name     |Storage              |Mount on                  |Total Used      ||"
  echo "||-----------------------------------------------------------------------------------------------------------------------||"
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | sort -u -r)
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

function helper() {
  echo "Usage: cat [OPTION]..."
  echo "This script is to get information about our diferents partitions of the disk"
  echo "It is not necesary a FILE, but if you introduce a FILE you will get the output in the file (This will be in the future"
  echo ""
  echo "-inv       Print the inverse of the main output"
}

if [ $# -gt 0 ]; then
  while [ "$1" != "" ]; do
    case $1 in
      "-h" | "--help")
        helper
        shift
        ;;
      "-u")
        shift
        while [ "$1" != "" ]; do
          # Comprobar que el valor de $1 es un usuario
          if id "$1" >/dev/null 2>&1; then
            are_usuarios=1
            usuarios=$1
            usuarios+=" "
            # Implementar función para los usuarios
          else
            echo "The user $1 is not a valid user"
          fi
          shift
        done
        echo $usuarios
        echo $are_usuarios
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