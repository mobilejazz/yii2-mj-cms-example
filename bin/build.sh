#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(cd ${SCRIPT_DIR}/..; pwd)

source ${SCRIPT_DIR}/common.sh
trap "Exiting" SIGUSR1

# Determine entrypoint

ENTRYPOINT="/run.sh"

if [ $(uname) == "Darwin" ]; then
    ENTRYPOINT="/run-mac.sh"
fi

#
cd ${ROOT_DIR} && ENTRYPOINT=${ENTRYPOINT} docker-compose up -d --build --remove-orphans


cd ${ROOT_DIR} && docker-compose up -d --build --remove-orphans

sleep 10    # hack to allow services to start

bin/exec.sh composer install -vv
bin/exec.sh vendor/bin/phing docker.init

# Load example data

bin/yii.sh fixture/load User,Mediafile,Locale,ContentSource,ContentSlug,ContentComponent,ComponentField --interactive=0
