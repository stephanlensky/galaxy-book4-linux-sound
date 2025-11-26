# Bug Bounty for Galaxy Book4 Pro 360 Speaker Support on Linux

**💰 I am offering a $500 USD bug bounty to anyone who can get the speakers working on Linux for the Samsung Galaxy Book4 Pro 360 laptop (NP960QGK).**

- If this issue is also affecting you, please consider adding to this pledge! Just submit a pull request with the amount you would like to contribute.
- See [PLEDGE.md](./PLEDGE.md) for the full terms of the pledge.

## What is the problem?

The internal speakers on the Samsung Galaxy Book4 Pro 360 laptop (NP960QGK) and other related models do not produce any sound on Linux.

- This laptop uses the Realtek ALC298 codec and MAX98390 amplifiers.
- Headphone jack is working, but not the internal speakers.
- This issue is similar to previous Samsung Galaxy Book models, which required HDA verb speaker amplifier quirks.
- However, unlike previous models, we have not yet been able to hear output from the speakers while running Windows in QEMU with official drivers. This model may require additional initialization of the MAX98390 amplifiers over I2C.

Tracking issues:

- [thesofproject/linux#5606](https://github.com/thesofproject/linux/issues/5606) Samsung Galaxy Book4 Pro 360 (NP960QGK) - No sound from internal speakers
- [Kernel Bugzilla #220808](https://bugzilla.kernel.org/show_bug.cgi?id=220808) Samsung Galaxy Book4 Pro 360 (NP960QGK) Laptop - No sound from internal speakers

### Other affected models

The following other Book4 models are also known to be affected:

- Samsung Galaxy Book4 Pro (NP940XGK)

[Speakers are also broken on the Galaxy Book5](https://github.com/thesofproject/linux/issues/5572), but that is outside the scope of this bug bounty.

**I personally own the Galaxy Book4 Pro 360 (NP960QGK), and all hardware information and debugging output in this repository will reference this model unless otherwise specified.**

## Other existing discussions

- [thesofproject/linux#5002](https://github.com/thesofproject/linux/issues/5002) Samsung Galaxy Book4 Pro 14" (NP940XGK) - speakers do not work
  - This is the original SOF issue for the Book4 series. @dgunay provided a lot of useful information near the start of the issue, but later discussion is mostly unhelpful.
  - I already submitted a [$100 bounty on BountyHub](https://www.bountyhub.dev/bounty/view/b1ccd1f8-9d97-4cf4-8b86-2250fccd0dab) for this particular issue. If you are also able to claim this, please consider it a bonus on top of the already promised $500.
- [thesofproject/linux#5568](https://github.com/thesofproject/linux/issues/5568) Samsung Galaxy Book 4 Pro (940XGK) - No speaker audio, MAX98390 amplifiers not integrated
  - More recent issue with a lot of useful technical details courtesy of @BreadJS.
- [Kernel Bugzilla #218862](https://bugzilla.kernel.org/show_bug.cgi?id=218862) [Samsung Galaxy Book4 Pro - 940XGK] No sound from internal speakers
- [Manjaro Forums](https://forum.manjaro.org/t/no-sound-from-speakers-on-samsung-book4-360-pro/161175) No sound from speakers on Samsung Book4 360 Pro

## Additional technical details

### Running Windows in QEMU

I was ultimately unable to get the speakers working in virtualized Windows, but I compiled a list of notes from my attempt.

- [QEMU Windows notes](./qemu/README.md)

### Hardware information

Additional log files to help with debugging are available in this repository. All logs were captured on EndeavourOS kernel `6.17.8-arch1-1` on the NP960QGK.

- [acpidump.log](./dumps/acpidump.log) - Output of `acpidump`
- [alsa-info.txt](./dumps/alsa-info.txt) - Output of `alsa-info.sh`
- [build.config](./dumps/build.config) - Contents of `/usr/lib/modules/$(uname -r)/build/.config`
- [dmesg.log](./dumps/dmesg.log) - Output of `dmesg` directly after boot
- [lspci.txt](./dumps/lspci.txt) - Output of `lspci -knn`

### Previous Galaxy Book models

Things are likely slightly different for the newer models, but here is a thread on speaker support for the older Galaxy Book2 and Book3:

- [thesofproject/linux#4055](https://github.com/thesofproject/linux/issues/4055) [BUG] Samsung Galaxy Book2 Pro 360 no sound through speaker

These laptops required HDA verb quirks to properly initialize the amplifiers, it may be similar on the Book4.

## Testing your solution

I am willing to run any commands for you to help test things. Please just reach out, either here on GitHub or in our Discord server: https://discord.gg/msgJHDwTfe

## If you are also having this problem...

Please reach out on one of the issue threads linked above to let Linux maintainers know this issue is important to you. Also, remember that they are mostly unpaid volunteers!

**With that in mind, please consider donating to the bug bounty pledge by submitting a pull request and adding your amount above and in [PLEDGE.md](./PLEDGE.md).**
