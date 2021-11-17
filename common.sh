#!/usr/bin/env bash
set -euo pipefail

exec 5>/dev/null

enableVerboseOutput() {
    exec 5>&1
}
[[ ${DEBUG:-} == true ]] && enableVerboseOutput


verifyExecutablePresent() {
    local cmd=$1
    if which $1 > /dev/null ; then
        echo >&5 "Prerequisite $1 is present."
    else
        echo "Prerequisite $1 is not present.  Install it."
        exit 1;
    fi 
} 


verifyExecutablePresent diff

sudoSyncFile() {
    local fromFile=$1
    local toFile=$2

    echo >&5 Comparing new file "${fromFile}" to "${toFile}"

    set +e
    (diff --ignore-trailing-space "${toFile}" "${fromFile}" ) 2>&1 >&5
    DIFF_EXIT=$?
    set -e

    if [ $DIFF_EXIT == 0 ] ; then
        echo >&5 Unchanged.
    else
        echo "Updating ${toFile}."
        (set -x; sudo cp "${fromFile}" "${toFile}")
    fi
}
