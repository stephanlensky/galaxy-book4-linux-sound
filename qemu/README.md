# Galaxy Book4 Pro 360 QEMU Setup

This folder contains notes and scripts related to setting up a Windows QEMU environment for dumping HDA verbs.

I did not succeed in getting anything working, just including it here in case someone else finds this useful in the future.

All testing was done on EndeavourOS (Arch Linux).

Links:

- https://jcs.org/2018/11/12/vfio

## Dumping HDA verbs

Following this guide: https://github.com/Conmanx360/QemuHDADump/wiki/Setup-and-usage-of-the-program

First, we need to identify the devices to pass through to the VM. Get the `pci-id` of the sound card:

```
$ lspci -nn
...
00:1f.3 Multimedia audio controller [0401]: Intel Corporation Meteor Lake-P HD Audio Controller [8086:7e28] (rev 20)
```

We need to pass through this sound card as well as all other devices in the same iommu group. Do `find /sys/kernel/iommu_groups/ -type l` and we see our `1f.3` device is in group 17:

```
/sys/kernel/iommu_groups/17/devices/0000:00:1f.3
```

Find all other devices in group 17:

```
slensky@book:~$ find /sys/kernel/iommu_groups/ -type l | grep iommu_groups/17/
/sys/kernel/iommu_groups/17/devices/0000:00:1f.0
/sys/kernel/iommu_groups/17/devices/0000:00:1f.5
/sys/kernel/iommu_groups/17/devices/0000:00:1f.3
/sys/kernel/iommu_groups/17/devices/0000:00:1f.4
slensky@book:~$ lspci -nn | grep 1f.
00:1f.0 ISA bridge [0601]: Intel Corporation Meteor Lake-H eSPI Controller [8086:7e02] (rev 20)
00:1f.3 Multimedia audio controller [0401]: Intel Corporation Meteor Lake-P HD Audio Controller [8086:7e28] (rev 20)
00:1f.4 SMBus [0c05]: Intel Corporation Meteor Lake-P SMBus Controller [8086:7e22] (rev 20)
00:1f.5 Serial bus controller [0c80]: Intel Corporation Meteor Lake-P SPI Controller [8086:7e23] (rev 20)
```

These all seem safe to pass through.

Load these devices with `pci-stub` to prevent them from being used in the running system:

- Documentation for adding kernel parameters is [here](https://wiki.archlinux.org/title/Kernel_parameters#systemd-boot).
- Add a new entry in `/efi/loader/entries` with the following additional `options`: `pci-stub.ids=8086:7e02,8086:7e28,8086:7e22,8086:7e23 intel_iommu=on`
  - In my case, I created `/efi/loader/entries/5e1450eea7324302a5d2b163296edb94-6.15.9-arch1-1-pci-stub.conf`
- Reboot using new entry
  - Can be verified using `lspci -nnk` (our device should show `Kernel driver in use: pci-stub`)

Then, bind with `vfio` to prepare for pass-through:

```sh
sudo ./vfio-bind.sh 0000:00:1f.0
sudo ./vfio-bind.sh 0000:00:1f.5
sudo ./vfio-bind.sh 0000:00:1f.3
sudo ./vfio-bind.sh 0000:00:1f.4
```

`lspci -nnk` should now show `Kernel driver in use: vfio-pci`.

### Compiling QEMU

**Note: to get a complete dump, we are eventually going to need to apply a [code patch](https://github.com/joshuagrisham/galaxy-book2-pro-linux/tree/main/sound/qemu) here in addition to the `./configure` option. Didn't see the point in bothering with this until we get the drivers working properly in virtualized Windows.**

Resources:

- Arch Linux package - https://gitlab.archlinux.org/archlinux/packaging/packages/qemu
- `makepkg` docs - https://wiki.archlinux.org/title/Makepkg

Steps:

1. `git clone https://gitlab.archlinux.org/archlinux/packaging/packages/qemu.git && cd qemu`
2. Add `--enable-trace-backends=log`

   ```diff
    diff --git a/PKGBUILD b/PKGBUILD
    index 227a2a5..82cbc31 100644
    --- a/PKGBUILD
    +++ b/PKGBUILD
    @@ -21,7 +21,7 @@ pkgname=(
      qemu-tests
      qemu-tools
      qemu-ui-{curses,dbus,egl-headless,gtk,opengl,sdl,spice-{app,core}}
    -  qemu-user{,-static}{,-binfmt}
    +  qemu-user{,-binfmt}
      qemu-vhost-user-gpu
      qemu-vmsr-helper
      qemu-{base,desktop,emulators-full,full}
    @@ -369,7 +369,7 @@ build() {

      (
        cd build-static
    -    ../$pkgbase-$pkgver/configure "${configure_static_options[@]}"
    +    ../$pkgbase-$pkgver/configure "${configure_static_options[@]}" --enable-trace-backends=log
        ninja
      )

    @@ -379,7 +379,7 @@ build() {

      (
        cd build
    -    ../$pkgbase-$pkgver/configure "${configure_options[@]}"
    +    ../$pkgbase-$pkgver/configure "${configure_options[@]}" --enable-trace-backends=log
        ninja
      )
   ```

3. `makepkg --syncdeps --skippgpcheck`
4. `makepkg --install`

### Cloning Existing Windows partition

When I first purchased the laptop, I took a full disk backup onto an external drive. Then, I used gparted to shrink the Windows partition so it didn't take an excessive amount of space.

Clone the disk to a QEMU image:

- I created a new partition at `/dev/nvme0n1p10` to house the QEMU image (`sudo mount /dev/nvme0n1p10 /mnt`).
- Create the image: `sudo qemu-img convert -f raw -O qcow2 /dev/sda /mnt/samsung-windows.qcow2`
- Verify image: https://unix.stackexchange.com/questions/268460/how-to-mount-qcow2-image
- Create overlay for persistent storage: `sudo qemu-img create -f qcow2 -b /mnt/samsung-windows.qcow2 -F qcow2 /mnt/overlay.qcow2`

### Starting VM

Run `./startvm.sh`. Notes:

- `-cpu qemu64` is required to avoid BSOD (`-cpu host` doesn't work). TPM issue?
- `-bios /usr/share/OVMF/x64/OVMF.4m.fd` enables UEFI

I installed Windows and then downloaded the audio driver [from Samsung](https://www.samsung.com/global/galaxybooks-downloadcenter/model/?modelCode=NP960QGK-KG1US&siteCode=us). It's unclear if this installed correctly, the setup window appeared and said it was installing, but then the window closed with no confirmation.

After this, the speakers were still not working:

<img width="573" height="264" alt="image" src="https://github.com/user-attachments/assets/e32f4f35-c1a6-4a5d-a511-7d09a175f63f" />
<img width="1797" height="882" alt="image" src="https://github.com/user-attachments/assets/f05fea10-bed3-455b-8531-c86bbb060ff6" />
<img width="1805" height="872" alt="image" src="https://github.com/user-attachments/assets/77632df6-ac1c-4a61-88c5-0e8d19c3092c" />

Reboot did not help.

Possibilities I could think of:

- I missed a PCI device that should have been passed through. I included the full output of `lspci -knn` in [lspci.txt](../dumps/lspci.txt).
- We are missing ACPI methods to initialize/control the codec. These would not be passed through to the VM with my configuration.
