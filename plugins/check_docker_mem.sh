#!/bin/bash
#
# check_docker_mem.sh: script para verificar la memoria utilizada por un contenedor
# Docker.
#
# (C) 2023 - 2024 Martin Andres Gomez Gimenez <mggimenez@nis.com.ar>
# Distributed under the terms of the GNU General Public License v3
#
# Vea https://www.kernel.org/doc/Documentation/cgroup-v2.txt
#



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
  echo "Check the memory used by a Docker container."
  echo ""
  echo "  Uso: "
  echo "       ${PROG_PATH}/${PROG_NAME} [-h|--help]"
  echo "       ${PROG_PATH}/${PROG_NAME} [-c|--critical] CRITICAL [-n|--name] DOCKER [-w|--warning] WARNING"
  echo ""
  echo "       --help, -h"
  echo "           Show this help."
  echo ""
  echo "       --critical, -c"
  echo "           Parameter to pass critical memory percentage value."
  echo ""
  echo "       CRITICAL"
  echo "           Critical memory percentage."
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
  echo "           Parameter to pass warning memory percentage value."
  echo ""
  echo "       WARNING"
  echo "           Warning memory percentage."
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
      echo "MEMORY ${STATUS}: ${MEMORY_DOCKER} - ${MEMORY_DOCKER_P} used. | ${PERFDATA}"
      return 0
      ;;
    1 )
      STATUS="WARNING"
      echo "MEMORY ${STATUS}: ${MEMORY_DOCKER} - ${MEMORY_DOCKER_P} used. | ${PERFDATA}"
      return 1
      ;;
    2 )
      STATUS="CRITICAL"
      echo "MEMORY ${STATUS}: ${MEMORY_DOCKER} - ${MEMORY_DOCKER_P} used. | ${PERFDATA}"
      return 2
      ;;
    * )
      STATUS="UNKNOWN"
      echo "MEMORY ${STATUS}. | ${PERFDATA}"
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


ID="$(docker ps --all --filter name="${NAME}$" --format {{.ID}})"

MEMORY_DOCKER=$(docker stats --no-stream --format {{.MemUsage}} ${NAME})
MEMORY_DOCKER_P=$(docker stats --no-stream --format {{.MemPerc}} ${NAME})

MEMORY_USAGE_T=$(cat /sys/fs/cgroup/docker/${ID}*/memory.current)
MEMORY_INACTIVE_F=$(awk '/^inactive_file/{print $2}' /sys/fs/cgroup/docker/${ID}*/memory.stat)
MEMORY_USAGE=$((${MEMORY_USAGE_T} - ${MEMORY_INACTIVE_F}))

MEMORY_TOTAL_K=$(cat /sys/fs/cgroup/docker/${ID}*/memory.max)
MEMORY_TOTAL=$((${MEMORY_TOTAL_K} * 1024))

MEMORY_CRITICAL=$((${MEMORY_TOTAL} * ${CRITICAL} / 100))
MEMORY_WARNING=$((${MEMORY_TOTAL} * ${WARNING} / 100))

PERFDATA="TOTAL=${MEMORY_TOTAL};;;0;${MEMORY_TOTAL} ${NAME}=${MEMORY_USAGE};${MEMORY_WARNING};${MEMORY_CRITICAL};0;${MEMORY_TOTAL}"

if [ "${MEMORY_USAGE}" -ge "${MEMORY_CRITICAL}" ]; then
    status 2
  elif [ "${MEMORY_USAGE}" -ge "${MEMORY_WARNING}" ]; then
    status 1
  else
    status 0
fi

