# QEMU/KVM on Docker and CoreOS

Fork from [ulexus/qemu](https://github.com/Ulexus/docker-qemu)

## Usage

Start with specific ISO

```
docker run --name ubuntu-14.04 --privileged -v ${PWD}:/data \
    -e VM_DISK_IMAGE=/data/disk-image \
    -e ISO=http://releases.ubuntu.com/14.04.2/ubuntu-14.04.2-desktop-amd64.iso \
    -p 15900:5900
    dorowu/qemu-iso
```

Turn on machine with last image
```
docker run --name ubuntu-14.04 --privileged -v ${PWD}:/data \
    -e VM_DISK_IMAGE=/data/disk-image \
    -e ISO= \
    -p 15900:5900
    dorowu/qemu-iso
```

Using spicec to access remote desktop
```
sudo apt-get install spice-client
spicec -h 127.0.0.1 -p 15900
```
