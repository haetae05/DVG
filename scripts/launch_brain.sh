#!/bin/bash
qemu-system-x86_64 \
    -nographic \
    -m 256 \
    -machine q35,confidential-guest-support=sev0,memory-backend=ram1 \
    -object memory-backend-memfd,id=ram1,size=256M,share=yes,prealloc=yes \
    -object sev-guest,id=sev0,cbitpos=51,reduced-phys-bits=1 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -device vhost-vsock-pci,guest-cid="${2}" \
    -kernel "${1}"
