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
bool_device_files=0
bool_sopen=0
bool_sdevice=0
bool_inv=0

sort_method="sort -u"

lines=""

function print_header() {
  info="Filesistem Dispositive_name Storage Mount_on Total_Used Stat_Lower Stat_Higher"
  if [ $bool_device_files -eq 1 ]; then
  info+=" Device_files"
    echo "||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------||"
    header=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s |%-15s ||\n" $info)
    echo "$header"
    echo "||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------||"
  else
    echo "||---------------------------------------------------------------------------------------------------------------------------------------------------------||"
    header=$(printf "||%-30s |%-20s |%-20s |%-25s |%-15s |%-15s |%-15s ||\n" $info)
    echo "$header"
    echo "||---------------------------------------------------------------------------------------------------------------------------------------------------------||"
  fi
}

# Al entregarla cambiarle el nombre a system_info
function definitive_function() {
  echo
}

function device_files() {
  if [ $bool_inv -eq 1 ]; then
    sort_method+=" -r"
  fi
  # Tipos es el tipo de sistema de archivos
  tipos=$(cat /proc/mounts | cut -d  ' ' -f3 | ${sort_method})
  tabla=""
  for tipo in $tipos; do
    line=$tipo
    line+=" "
    line+=$(df -a -t $tipo | tr -s ' ' | tail -n +2 | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1,3,6)
    total_used=$(df -a -t $tipo | awk 'BEGIN {total=0} {total = total + $3} END {print total}')
    dispositive=$(df -a -t $tipo | tr -s ' ' | sort -k3 -n | tail -n -1 | cut -d ' ' -f 1)
    if [ $bool_device_files -eq 1 ]; then
      if [ -e $dispositive ]; then
        stat_lower=$(stat -c %t $dispositive)
        stat_higher=$(stat -c %T $dispositive)
        lsof_value=$(lsof $dispositive | wc -l)
        lines+="$line $total_used $stat_lower $stat_higher $lsof_value"
        lines+=$'\n'
      fi
    else 
      if [ -e $dispositive ]; then
        stat_lower=$(stat -c %t $dispositive)
        stat_higher=$(stat -c %T $dispositive)
        lines+="$line $total_used $stat_lower $stat_higher"
        lines+=$'\n'
      else 
        lines+="$line $total_used * *"
        lines+=$'\n'
      fi
    fi

    #tabla="$tabla""$line"
    #tabla+=$'\n'"||---------------------------------------------------------------------------------------------------------------------------------------------------------||"$'\n'                               
  done
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
        bool_inv=1
        shift
        ;;
      "-devicefiles")
        bool_device_files=1
        shift
        ;;
      "-sopen")
        bool_sopen=1
        shift
        ;;
      "-sdevice")
        bool_sdevice=1
        shift
        ;;
      * )
        echo $1
        shift
        ;;
    esac
  done
else 
  echo
fi
print_header
device_files
echo "$lines"