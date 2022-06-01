#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/common.sh
verifyExecutablePresent sed

installTimer() {
    INSTALLDIR=$1
    RUNASUSER=$2
    RUNASGROUP=$3
    SVCNAME=gen-resolv-conf
    sed -e "s:%INSTALLDIR%:${INSTALLDIR}:g" -e "s:%RUNASUSER%:${RUNASUSER}:g"  -e "s:%RUNASGROUP%:${RUNASGROUP}:g" "${INSTALLDIR}/systemd-templates/${SVCNAME}.service" > "/etc/systemd/system/${SVCNAME}.service"
    cp "systemd-templates/${SVCNAME}.timer" /etc/systemd/system/

    systemctl daemon-reload
    systemctl enable --now "${SVCNAME}.timer"
}

FUNC=$(declare -f installTimer)
sudo bash -c "$FUNC; installTimer ${SCRIPT_DIR} $(id -un) $(id -gn)"
