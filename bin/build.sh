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

bin/exec.sh composer install -vv --ignore-platform-reqs
bin/exec.sh vendor/bin/phing docker.init

# Load example data

bin/yii.sh fixture/load User,Mediafile,Locale,ContentSource,ContentSlug,ContentComponent,ComponentField --interactive=0

# install git hooks
#
# NOTE: this is done via the build script instead of with Phing as it needs to be aware of the ROOT folder whereas
# Phing can only access everything from src/ and lower as it is run within the docker machine.

if [ ! -e "${ROOT_DIR}/.git/hooks/pre-commit" ]; then

    cp "${ROOT_DIR}/hooks/pre-commit" "${ROOT_DIR}/.git/hooks/pre-commit"
    echo "Installed pre-commit hook"

else

    echo "Existing pre-commit hook detected. Doing nothing"

fi
