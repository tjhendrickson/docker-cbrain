#!/bin/bash -e

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

ROOT_DIR="$(get_script_dir)"

cd "$ROOT_DIR"

if [[ $NO_SUDO ]]; then
  DOCKER_COMPOSE="docker-compose"
elif groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER_COMPOSE="docker-compose"
else
  DOCKER_COMPOSE="sudo docker-compose"
fi

source .env
DOCKER_COMPOSE_UID="USERID=$(id -u $USER) GROUPID=$(id -g $USER) $DOCKER_COMPOSE"

eval "$DOCKER_COMPOSE_UID up -d mysql"
eval "$DOCKER_COMPOSE_UID run --rm wait_db"
eval "$DOCKER_COMPOSE_UID up -d cbrain-portal"
eval "$DOCKER_COMPOSE_UID run --rm wait_portal"
eval "$DOCKER_COMPOSE_UID up -d cbrain-bourreau"
eval "$DOCKER_COMPOSE_UID up -d data-provider"

echo
echo
echo "Type the following command to stop CBrain:"
echo "  $DOCKER_COMPOSE down"
echo
echo
eval "$DOCKER_COMPOSE_UID logs -f"
