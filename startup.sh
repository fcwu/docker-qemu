#!/bin/bash

set -e

[ -n "$DEBUG" ] && set -x

# Create the kvm node (required --privileged)
if [ ! -e /dev/kvm ]; then
   set +e
   mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')   
   set -e
fi

# If we have a NETWORK_BRIDGE_IF set, add it to /etc/qemu/bridge.conf
if [ -n "$NETWORK_BRIDGE_IF" ]; then
    echo "allow $NETWORK_BRIDGE_IF" >/etc/qemu/bridge.conf

    # Make sure we have the tun device node
    if [ ! -e /dev/net/tun ]; then
       set +e
       mkdir -p /dev/net
       mknod /dev/net/tun c 10 $(grep '\<tun\>' /proc/misc | cut -f 1 -d' ')
       set -e
    fi

    FLAGS_NETWORK="-netdev bridge,br=${NETWORK_BRIDGE_IF},id=net0 -device virtio-net,netdev=net0"
fi

# If we were given arguments, override the default configuration
if [ $# -gt 0 ]; then
   exec "$@"
fi

# mountpoint check
if [ ! -d /data ]; then
    if [ "${ISO:0:1}" != "/" ] || [ -z "$VM_DISK_IMAGE" ]; then
        echo "/data not mounted: using -v to mount it"
        exit 1
    fi
fi

VM_RAM=${VM_RAM:-2048}
VM_DISK_IMAGE_SIZE=${VM_IMAGE:-10G}
SPICE_PORT=5900

echo "[iso]"
if [ -n "$ISO" ]; then
    if [ "${ISO:0:1}" != "/" ]; then
        basename=$(basename $ISO)
        if [ ! -f "/data/${basename}" ] || [ "$ISO_FORCE_DOWNLOAD" != "0" ]; then
            wget -O- "$ISO" > /data/${basename}
            ISO=/data/${basename}
        fi
    fi
    FLAGS_ISO="-cdrom $ISO"
    if [ ! -f "$ISO" ]; then
        echo "ISO fild not found: $ISO"
        exit 1
    fi
fi

echo "[disk image]"
if [ -z "${VM_DISK_IMAGE}" ] || [ "$VM_DISK_IMAGE_CREATE_IF_NOT_EXIST" != "0" ]; then
    FLAGS_DISK_IMAGE=${VM_DISK_IMAGE:-/data/disk-image}
    if [ ! -f "$VM_DISK_IMAGE" ]; then
        qemu-img create -f qcow2 ${FLAGS_DISK_IMAGE} ${VM_DISK_IMAGE_SIZE}
    fi
fi
[ -f "$FLAGS_DISK_IMAGE" ] || { echo "VM_DISK_IMAGE not found: ${FLAGS_DISK_IMAGE}"; exit 1; }

# Execute with default settings
set -x
exec /usr/bin/kvm -vga qxl -spice port=${SPICE_PORT},addr=127.0.0.1,disable-ticketing \
   -k en-us -m ${VM_RAM} -cpu qemu64 \
   ${FLAGS_NETWORK} \
   ${FLAGS_ISO} \
   ${FLAGS_DISK_IMAGE}
