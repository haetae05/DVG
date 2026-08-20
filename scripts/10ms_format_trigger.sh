#!/bin/bash
set -euo pipefail
touch "${2}" "${1}"
inotifywait -m -e modify "${2}" | while read -r _; do
    [[ -s "${1}" ]] && kill -9 "$(< "${1}")" 2>/dev/null || true
    qemu-img snapshot -a "${4}" "${3}"
    qemu-system-x86_64 -m 1G -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd -hda "${3}" -daemonize -pidfile "${1}"
done
