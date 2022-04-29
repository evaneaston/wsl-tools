#!/usr/bin/env bash
set -eu -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

tmp=`mktemp`
powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
trap ctrlC INT

removeTempFiles() {
    rm -f $tmp
}

ctrlC() {
    echo
    echo "Trapped Ctrl-C, removing temporary files"
    removeTempFiles
    stty sane
}


hostip=$(${SCRIPT_DIR}/get-host-ip.sh)

echo "Current /etc/hosts"
echo "-------------------"
cat /etc/hosts

echo
echo "Creating new /etc/hosts"
echo "------------------------"
{
    cat /etc/hosts | grep -v local-web.dev.datasite.com
    echo ${hostip}   local-web.dev.datasite.com
} | tr -d '\r' | tee $tmp

(set -x; sudo cp $tmp /etc/hosts)

removeTempFiles

export TARGET_HOST=http://local-web.dev.datasite.com:8096

