#!/bin/sh
set -o pipefail
set -o errexit

if [ "$#" != 1 ]; then
    echo "Usage: $0 <pid>"
    exit 1
fi

TMP=$(mktemp)

peer_ifidx_line="$(nsenter --target "$1" --net ethtool -S eth0 | grep peer_ifindex)"
peer_ifidx="$(echo "$peer_ifidx_line" | sed 's/.* \([0-9]*\)$/\1/')"

nsenter --target 1 --net ip link | grep "^$peer_ifidx: " > $TMP
if [ "$(cat $TMP | wc -l)" -ne 1 ]; then
    echo "Found incorrect number of interfaces"
    exit 1
fi

echo $(cat $TMP | awk '{print $2}' | sed 's/\([^:]*\).*/\1/')
