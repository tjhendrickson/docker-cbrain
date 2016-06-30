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

ROOT_DIR="$(get_script_dir)/.."

VERSION=${1:-dev}

function usage {
  echo "usage: $0 [-p] [-h]"
  echo "       -p: pushes containers."
  echo "       -h: prints help."
}

if [ "x$1" != "x" ]
then
  case $1 in 
    "-p") PUSH=true;;
    "-h") usage; exit 0;;
    *) usage; exit 1;;
  esac
fi

DOCKERFILE_DIR=Docker/Dockerfiles
IMAGE_NAME=mcin/cbrain

cd $ROOT_DIR

echo
echo "#########################"
echo "# Building DataProvider #"
echo "#########################"
echo 

docker build -f ${DOCKERFILE_DIR}/Dockerfile.DataProvider -t mcin/cbrain_data_provider .
docker tag ${IMAGE_NAME}_data_provider ${IMAGE_NAME}_data_provider:$VERSION

echo
echo "#########################"
echo "# Building CBRAIN base  #"
echo "#########################"
echo 

docker build -f ${DOCKERFILE_DIR}/Dockerfile -t mcin/cbrain .
docker tag ${IMAGE_NAME} ${IMAGE_NAME}:$VERSION

echo
echo "#########################"
echo "#    Building Portal    #"
echo "#########################"
echo 

docker build -f ${DOCKERFILE_DIR}/Dockerfile.Portal -t mcin/cbrain_portal .
docker tag ${IMAGE_NAME}_portal ${IMAGE_NAME}_portal:$VERSION

echo
echo "#########################"
echo "#    Building Bourreau  #"
echo "#########################"
echo 

docker build -f ${DOCKERFILE_DIR}/Dockerfile.Bourreau -t mcin/cbrain_bourreau .
docker tag ${IMAGE_NAME}_bourreau ${IMAGE_NAME}_bourreau:$VERSION

if [ "${PUSH}" = "true" ]
then
  echo "### Pushing containers ###"
  docker push mcin/cbrain:$VERSION
  docker push mcin/cbrain_portal:$VERSION
  docker push mcin/cbrain_bourreau:$VERSION
fi
