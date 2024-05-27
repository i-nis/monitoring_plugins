#!/bin/bash
#
# check_docker_cpu.sh: script para verificar el uso de procesador por un contenedor.
# Docker.
#
# (C) 2023 Martin Andres Gomez Gimenez <mggimenez@nis.com.ar>
# Distributed under the terms of the GNU General Public License v3
#



# Default values.
CRITICAL="90"
WARNING="80"



# Función para determinar si docker está instalado.
#
docker_installed() {
  local DOCKER=$(whereis -b docker | awk '{print $2}')

  if [[ ! -x ${DOCKER} || "${DOCKER}" == "" ]]; then
    echo "Docker is not installed on this system."
    status 4
  fi
}



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
  echo "Check the CPU used by a Docker container."
  echo ""
  echo "  Uso: "
  echo "       ${PROG_PATH}/${PROG_NAME} [-h|--help]"
  echo "       ${PROG_PATH}/${PROG_NAME} [-c|--critical] CRITICAL [-n|--name] DOCKER [-w|--warning] WARNING"
  echo ""
  echo "       --help, -h"
  echo "           Show this help."
  echo ""
  echo "       --critical, -c"
  echo "           Parameter to pass critical CPU percentage value."
  echo ""
  echo "       CRITICAL"
  echo "           Critical CPU percentage."
  echo ""
  echo ""
  echo "       --name, -n"
  echo "           Parameter to pass the name of the docker container."
  echo ""
  echo "       DOCKER"
  echo "           Name of the docker container to examine."
  echo ""
  echo ""
  echo "       --warning, -w"
  echo "           Parameter to pass warning CPU percentage value."
  echo ""
  echo "       WARNING"
  echo "           Warning CPU percentage."
  echo ""
}



# parameters()
# Verifica el correcto pasaje de parámetros.
#
function parameters() {
  local OPT=$(getopt \
              --options c:n:hw: \
              --longoptions critical:,name:,help,warning: \
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

      -n | --name )
        NAME="${2}"
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
      echo "CPU ${STATUS}: ${CPU_DOCKER_P} used. | ${PERFDATA}"
      return 0
      ;;
    1 )
      STATUS="WARNING"
      echo "CPU ${STATUS}: ${CPU_DOCKER_P} used. | ${PERFDATA}"
      return 1
      ;;
    2 )
      STATUS="CRITICAL"
      echo "CPU ${STATUS}: ${CPU_DOCKER_P} used. | ${PERFDATA}"
      return 2
      ;;
    * )
      STATUS="UNKNOWN"
      echo "CPU ${STATUS}. | ${PERFDATA}"
      return 3
      ;;
  esac

}



docker_installed

# Verificación de parámetros.
#
if [ "${#}" == "0" ]; then
    no_parameters
    status 4
    exit
  else
    parameters "${@}"
fi



CPU_DOCKER_P=$(docker stats --no-stream --format {{.CPUPerc}} ${NAME})
CPU_DOCKER=$(echo "${CPU_DOCKER_P//[^0-9.]/}")
CPU_TOTAL="100"

PERFDATA="TOTAL=${CPU_TOTAL};;;0;${CPU_TOTAL} ${NAME}=${CPU_DOCKER};${WARNING};${CRITICAL};0;${CPU_TOTAL}"

if (( $(echo "${CPU_DOCKER} > ${CRITICAL}" | bc --mathlib) )); then
    status 2
  elif (( $(echo "${CPU_DOCKER} > ${WARNING}" | bc --mathlib) )); then
    status 1
  else
    status 0
fi

