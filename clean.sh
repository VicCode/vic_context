#!/bin/bash

set -e

DEBUG=1

PROG=`basename ${BASH_SOURCE[0]}`
PROG_DIR=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)

cd $PROG_DIR

function log {
    if [[ -n $DEBUG ]] ; then
        for ARG in "$@"
        do
            echo "$ARG"
        done
    fi
}

#log "Debug mode"

CMAKE_TEMP_DIR="tmp"
MAKE_BIN_DIR="bin"
MAKE_LIB_DIR="lib"
MAKE_MOD_DIR="mod"
PACKAGE_DIR_NAME="tarball"
PACKAGE_TAR_FILE="$PACKAGE_DIR_NAME.*"

ALL_ITEMS=($CMAKE_TEMP_DIR $MAKE_BIN_DIR $MAKE_LIB_DIR $MAKE_MOD_DIR $PACKAGE_DIR_NAME $PACKAGE_TAR_FILE)
log "Will clean ${#ALL_ITEMS[@]} items:"
log ${ALL_ITEMS[*]}

echo -n "Press any key to continue..."
read INP
rm -rf ${ALL_ITEMS[*]}

log "Clean Success."
