#!/bin/sh

sudo qemu-system-x86_64 \
	-M q35 -m 8G -cpu qemu64 \
	-enable-kvm \
	-device vfio-pci,host=00:1f.0,multifunction=on,x-no-mmap=on \
	-device vfio-pci,host=00:1f.5,multifunction=on,x-no-mmap=on \
	-device vfio-pci,host=00:1f.3,multifunction=on,x-no-mmap=on \
	-device vfio-pci,host=00:1f.4,multifunction=on,x-no-mmap=on \
	-hda /mnt/overlay.qcow2 \
	-bios /usr/share/OVMF/x64/OVMF.4m.fd \
	-trace events=events.txt \
    -monitor stdio 2>&1 | tee debug-output
