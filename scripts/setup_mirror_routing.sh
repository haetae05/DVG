#!/bin/bash
set -euo pipefail
# Load required modules for WSL2
modprobe nft_dup_ipv4 || true
modprobe nf_dup_ipv4 || true

nft add table ip filter || true
nft add chain ip filter prerouting '{ type filter hook prerouting priority -300 ; }' || true
nft add rule ip filter prerouting ip daddr "${1}" dup to "${2}" || true
