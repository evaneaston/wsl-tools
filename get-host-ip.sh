#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

{
  $powershell -Command 'Get-NetIPAddress  -AddressFamily ipv4|Where-Object -FilterScript { $_.IPAddress -LIKE "10.240.*" } | Select-Object -ExpandProperty IPAddress'
} | tr -d '\r'
