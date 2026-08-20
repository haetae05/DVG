#!/bin/bash
qemu-system-x86_64 \
    -nographic \
    -m 256 \
    -machine q35,confidential-guest-support=sev0,memory-backend=ram1 \
    -object memory-backend-memfd,id=ram1,size=256M,share=yes,prealloc=yes \
    -object sev-guest,id=sev0,cbitpos=51,reduced-phys-bits=1 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -device vhost-vsock-pci,guest-cid="${2}" \
    -fsdev local,id=fs0,path="${3}",security_model=none \
    -device virtio-9p-pci,fsdev=fs0,mount_tag=fs0 \
    -kernel "${1}" \
    -append "vfs.rootdev=fs0"
