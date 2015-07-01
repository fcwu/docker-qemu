# QEMU/KVM on Docker and CoreOS

Fork from [ulexus/qemu](https://github.com/Ulexus/docker-qemu)

## Usage

Start with specific ISO

```
docker run --name ubuntu-14.04 --privileged --net=host -v ${PWD}:/data \
    -e VM_DISK_IMAGE=/data/disk-image \
    -e ISO=http://releases.ubuntu.com/14.04.2/ubuntu-14.04.2-desktop-amd64.iso \
    -e NETWORK_BRIDGE_IF=lxcbr0 \
    dorowu/docker-qemu
```

Turn on machine with last image
```
docker run --name ubuntu-14.04 --privileged --net=host -v ${PWD}:/data \
    -e VM_DISK_IMAGE=/data/disk-image \
    -e ISO= \
    -e NETWORK_BRIDGE_IF=lxcbr0 \
    dorowu/docker-qemu
```

Using spicec to access remote desktop
```
sudo apt-get install spice-client
spicec -h 127.0.0.1 -p 5900
```
