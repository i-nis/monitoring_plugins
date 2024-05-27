#!/bin/bash
#
# check_docker.sh: script para verificar el estado de los contenedores Docker.
#
# (C) 2023 Martin Andres Gomez Gimenez <mggimenez@nis.com.ar>
# Distributed under the terms of the GNU General Public License v3
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
  echo "Check the status of Docker container."
  echo ""
  echo "  Uso: "
  echo "       ${PROG_PATH}/${PROG_NAME} [-h|--help]"
  echo "       ${PROG_PATH}/${PROG_NAME} [-n|--name] DOCKER"
  echo ""
  echo "       --help, -h"
  echo "           Show this help."
  echo ""
  echo "       --name, -n"
  echo "           Parameter to pass the name of the docker container."
  echo ""
  echo "       DOCKER"
  echo "           Name of the docker container to examine."
  echo ""
}



# parameters()
# Verifica el correcto pasaje de parámetros.
#
function parameters() {
  local OPT=$(getopt \
              --options n:h \
              --longoptions name:,help \
              --name '$(basename ${0})' \
              -- "${@}")

  if [ $? -ne 0 ]; then
    echo 'Error in parameters...' >&2
    exit 1
  fi

  eval set -- "${OPT}"

  while true; do

    case "$1" in

      -n | --name )
        NAME=${2}
        shift 2
        continue
        ;;

      -h | --help )
        usage
        exit
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
  local STATE_N=${1}

  case ${STATE_N} in
    0 )
      STATUS="Ok"
      echo "${STATUS}: Docker container ${NAME} is ${STATE}. | ${PERFDATA}"
      return 0
      ;;
    1 )
      STATUS="Warning"
      echo "${STATUS}: Docker container ${NAME} is ${STATE}. | ${PERFDATA}"
      return 1
      ;;
    2 )
      STATUS="Critical"
      echo "${STATUS}: Docker container ${NAME} is ${STATE}. | ${PERFDATA}"
      return 2
      ;;
    * )
      STATUS="Unknown"
      echo "Unknonw status. | ${PERFDATA}"
      return 3
      ;;
  esac

}


docker_installed

# Verificación de parámetros.
#
if [ "${#}" == "0" ]; then
    no_parameters
    exit
  else
    parameters "${@}"
fi

STATE=$(docker ps --all --filter name="${NAME}$" --format {{.Status}} | awk '{print $1}')

if [[ "${STATE}" == "Up" || "${STATE}" == "Running" ]]; then
    PERFDATA="online=1;0;0;0;1"
    status 0
  elif [[ "${STATE}" == "Restarting" ||  "${STATE}" == "Paused" ]]; then
    PERFDATA="online=0;0;0;0;1"
    status 1
  elif [ "${STATE}" == "Exited" ]; then
    PERFDATA="online=0;0;0;0;1"
    status 2
  else
    PERFDATA="online=0;0;0;0;1"
    status 3
fi

