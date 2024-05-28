#!/bin/bash
#
# check_nvme_temp.sh: script para verificar la temperatura utilizada por una 
# unidad de almacenamiento HDD/SDD.
#
# (C) 2023 Martin Andres Gomez Gimenez <mggimenez@nis.com.ar>
# Distributed under the terms of the GNU General Public License v3
#



# Default values.
CRITICAL="100"
WARNING="80"
PERFDATA="TEMP=0;0;0;0;0"



# no_parameters()
# Función para alertar la falta de parámetros obligatorios.
#
function no_parameters() {
  echo "ERROR: the number of parameters is insufficient. See"
  echo " $(basename ${0}) --help"
  echo ""
}



# Función para mostrar ayuda de uso.
#
function usage () {
  local PROG_NAME=$(basename $0)
  local PROG_PATH=$(echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,')
  echo "${PROG_NAME}:"
  echo "Checks the temperature used by an HDD/SSD storage drive."
  echo ""
  echo "  Uso: "
  echo "       ${PROG_PATH}/${PROG_NAME} [-h|--help]"
  echo "       ${PROG_PATH}/${PROG_NAME} [-c|--critical] CRITICAL [-d|--device] HDD/SSD [-w|--warning] WARNING"
  echo ""
  echo "       --help, -h"
  echo "           Show this help."
  echo ""
  echo "       --critical, -c"
  echo "           Parameter to pass critical temperature in degrees Celsius value."
  echo ""
  echo "       CRITICAL"
  echo "           Critical temperature in degrees Celsius."
  echo ""
  echo ""
  echo "       --device, -d"
  echo "           Parameter to indicate the NVME storage unit to monitor."
  echo ""
  echo "       HDD/SSD"
  echo "           HDD/SSD storage drive, for example /dev/sda."
  echo ""
  echo ""
  echo "       --warning, -w"
  echo "           Parameter to pass warning temperature in degrees Celsius value."
  echo ""
  echo "       WARNING"
  echo "           Warning temperature in degrees Celsius."
  echo ""
}



# parameters()
# Verifica el correcto pasaje de parámetros.
#
function parameters() {
  local OPT=$(getopt \
              --options c:d:hw: \
              --longoptions critical:,device:,help,warning: \
              --name '$(basename ${0})' \
              -- "${@}")

  if [ $? -ne 0 ]; then
    echo 'Error in parameters...' >&2
    exit 1
  fi

  eval set -- "${OPT}"

  while true; do

    case "$1" in

      -c | --critical )
        CRITICAL=${2}
        shift 2
        continue
        ;;

      -d | --device )
        DEVICE="${2}"
        shift 2
        continue
        ;;

      -h | --help )
        usage
        exit
        ;;

      -w | --warning )
        WARNING=${2}
        shift 2
        continue
        ;;

      -- )
        shift
        break
        ;;

      * )
        echo "Error in parameters. See:"
        echo " $(basename ${0}) --help"
        echo ""
        exit 1
        ;;
    esac

  shift
  done

}


# Función para informar el estado de los servicios monitoreados en Icinga2.
# STATUS: código de estado a informar.
#
function status() {
  local STATE=${1}

  case ${STATE} in
    0 )
      STATUS="OK"
      echo "Temp ${STATUS}: the ${DEVICE} drive is at ${TEMP}°C. | ${PERFDATA}"
      return 0
      ;;
    1 )
      STATUS="WARNING"
      echo "Temp ${STATUS}: the ${DEVICE} drive is at ${TEMP}°C. | ${PERFDATA}"
      return 1
      ;;
    2 )
      STATUS="CRITICAL"
      echo "Temp ${STATUS}: the ${DEVICE} drive is at ${TEMP}°C. | ${PERFDATA}"
      return 2
      ;;
    * )
      STATUS="UNKNOWN"
      echo "Temp ${STATUS}. | ${PERFDATA}"
      return 3
      ;;
  esac

}



# check_device()
# Verifica que se trata de un dispositivo especial de bloque.
function check_device() {
  if [ ! -b $DEVICE ];then
    echo "UNKNOWN: ${DEVICE} is not a block special file"
    return 3
  fi
}



# hddtemp_installed()
# Función para determinar si hddmp está instalado.
hddtemp_installed() {
  if [[ ! -x /usr/bin/hddtemp ]]; then
    echo "hddtemp is not installed on this system."
    return 3
  fi
}



# get_hddtemp()
# Función para obtener la temperatura del dispositivo.
function get_hddtemp() {
  TEMP=$(/usr/bin/hddtemp ${DEVICE} -n)

  case "${TEMP}" in
    [0-9]* )
      ;;
    * )
      echo "UNKNOWN: Could not get temperature from: $DEVICE"
      return 3
      ;;
  esac

}



# Verificación de parámetros.
if [ "${#}" == "0" ]; then
    no_parameters
    status 4
    exit
  else
    parameters "${@}"
    check_device "${DEVICE}"
    hddtemp_installed
fi

get_hddtemp
PERFDATA="TEMP=${TEMP};${WARNING};${CRITICAL};0;0"

if [ "${TEMP}" -ge "${CRITICAL}" ]; then
    status 2
  elif [ "${TEMP}" -ge "${WARNING}" ]; then
    status 1
  else
    status 0
fi

