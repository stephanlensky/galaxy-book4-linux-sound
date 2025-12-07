# Galaxy Book4 Speaker Support for Linux

This repository contains instructions for applying [BreadJS's Linux kernel patch](https://github.com/thesofproject/linux/pull/5616) to fix the internal speakers on the Samsung Galaxy Book4 series. So far, the patch has been tested with the following laptop models:

- Samsung Galaxy Book4 Pro (NP940XGK)
- Samsung Galaxy Book4 Pro 360 (NP960QGK)

The below instructions are written for Arch Linux. The process for compiling and installing a modified kernel will vary depending on your distribution.

> [!WARNING]
> **Proceed at your own risk:** I am not responsible if this patch causes damage to your laptop speakers, if you mess up your bootloader configuration, if a random speaker malfunction causes your cat to get scared, etc. etc.
>
> **If you are unfamiliar with Linux, it would be better to wait for the patch to get merged so you can get it with a regular system update.**

## Instructions

### Arch Linux

#### Install SOF firmware

In addition to the patched kernel, you will need the following packages for the speakers to show up:

```sh
pacman -S sof-firmware linux-firmware-intel alsa-firmware
```

#### Compile the kernel

1. Install build dependencies:

   ```sh
   sudo pacman -S base-devel devtools xmlto kmod inetutils bc libelf git rust rust-bindgen rust-src texlive-latexextra
   ```

2. Clone the git repository for the `linux` package and `cd` to it:

   ```sh
   pkgctl repo clone --protocol=https linux && cd linux
   ```

3. Download and apply [`arch-linux-linux.patch`](./arch-linux-linux.patch) to the cloned directory:

   ```sh
   git apply arch-linux-linux.patch
   ```

4. Create `galaxy-book4-max98390-support.patch` from [BreadJS's pull request](https://github.com/thesofproject/linux/pull/5616) in the root of the cloned package directory:

   ```sh
   wget https://github.com/thesofproject/linux/pull/5616.diff -O galaxy-book4-max98390-support.patch
   ```

5. **(Optional)** Edit `/etc/makepkg.conf` to [enable `ccache`](https://wiki.archlinux.org/title/Ccache) and and [parallel compilation](https://wiki.archlinux.org/title/Makepkg#Improving_build_times).

6. Compile the kernel:

   ```sh
   makepkg -s
   ```

   - If you see a PGP verification error like:

     ```
     ==> Verifying source file signatures with gpg...
     linux-6.18.tar ... FAILED (unknown public key 38DBBDC86092693E)
     linux-v6.18-arch1.patch.zst ... FAILED (unknown public key B8AC08600F108CDF)
     ==> ERROR: One or more PGP signatures could not be verified!
     ```

     Run `gpg -recv-key ...` for each of the unknown public keys listed in the error message.

   - If you see `ERROR: A failure occurred in prepare()` directly after patches are applied, it may be caused by the `patch` command returning non-zero exit status when patches have already been applied. Run `rm -rf src` and try again.

After completing the above steps, you should have the following newly built packages in the repository root:

- `linux-galaxy-audio-6.18.arch1-1-x86_64.pkg.tar.zst`
- `linux-galaxy-audio-docs-6.18.arch1-1-x86_64.pkg.tar.zst`
- `linux-galaxy-audio-headers-6.18.arch1-1-x86_64.pkg.tar.zst`

#### Installation

1. Install the patched kernel:

   ```
   sudo pacman -U linux-galaxy-audio-*.zst
   ```

   This will create `vmlinuz-linux-galaxy-audio` and `initramfs-linux-galaxy-audio.img` on your EFI partition (usually mounted at `/boot` or `/efi`).

2. Add an entry in your bootloader for the newly installed kernel. This will vary depending on the bootloader you selected during installation.

   - [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) - The easiest way is to copy your existing Arch Linux boot entry (found under `/loader/entries` on your EFI partition) and modify the `linux` and `initrd` options to point to the new kernel.

     For example, on my system I copied `/boot/loader/entries/arch.conf` to `/boot/loader/entries/arch-galaxy-audio.conf` and modified it to look like this:

     ```
     title   Arch Linux (Galaxy Audio)
     linux   /vmlinuz-linux-galaxy-audio
     initrd  /initramfs-linux-galaxy-audio.img
     options root=UUID=MY-ROOT-PARTITION-UUID rw
     ```

     Make sure to replace `MY-ROOT-PARTITION-UUID` with your actual root partition UUID (check `sudo blkid`). If you have different `options` in your existing Arch Linux entry, just copy them exactly.

   - [GRUB](https://wiki.archlinux.org/title/GRUB) - see wiki
   - [rEFInd](https://wiki.archlinux.org/title/REFInd) - rEFInd should detect the new kernel automatically, but check the wiki for additional information if it does not work.
   - Others - check the wiki!

#### Reboot and enjoy your working speakers

Reboot, making sure to select the newly created boot entry in your bootloader.

After rebooting, you can verify you are running the patched kernel:

```sh
$ uname -r
6.18.0-arch1-1-galaxy-audio
```

If you see this, your speakers should now work!

## Thank you

This is not my patch, actually I wrote no code for it at all!

BreadJS ultimately completed the final patch and collected [the bounty](./BUG_BOUNTY.md), but the patch was the combined effort of many people. A huge thank you also to:

- slaschinski, for risking his laptop during testing
- Lyapsus, for pointing us in the right direction and being the first to get sound from the laptop speakers
- All of the contributors on the various GitHub issues for this problem who provided debugging information along the way
