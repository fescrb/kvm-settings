# KVM Settings

This repository holds the steps taken to configure a passthrough KVM virtual instance of Windows 10. To aid with maintenance and/or future upgrades and some notes for the next setup.

For the initial setup [this tutorial was followed](https://heiko-sieger.info/running-windows-10-on-linux-using-kvm-with-vga-passthrough/). Modifications and observation were made which are documented here. 

## Initial Setup

As I typically run an Intel CPU. The fisrt step is enabling VT-d on the BIOS settings, [which is the hardware support for virtualization of IO](https://software.intel.com/en-us/articles/intel-virtualization-technology-for-directed-io-vt-d-enhancing-intel-platforms-for-efficient-virtualization-of-io-devices). This was already enabled for this computer.

Then the Linux kernel must be given extra arguments to enable io memory mapping. Edit the grub file (`/etc/default/grub`) and add the following argument to the `GRUB_CMDLINE_LINUX_DEFAULT` line:

`intel_iommu=on`

It must go in between the quotes, this was the line after our edit:

`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on"`

Then update grub with the change:

`sudo update-grub`

**Restart the system.** IOMMU is needed for some of the following steps.

If the switch to AMD happens in the future, the above steps must be changed. Look up how. 

The following packages must be installed:

* **qemu-kvm:** The virtualization program.
* **ovmf:** UEFI bios firmware needed to boot the VM into Windows 10.

Following the tutorial, these were also installed: 

* **qemu-utils**: Utilities for qemu. Unused atm but might come in handy in the future.
* **seabios**: Legacy BIOS image. I see no reason for it for Win10.
* **hugepages**: Change memory page size. To improve performance. Might be useful in the futute.

As far as I can tell, these are not required.

## PCI Passthrough

This feature enables giving control of PCI slots to the VM, with bare metal-like performance. For this setup we use this feature with two different pieces of hardware:

* **GPU:** Hardware acceletion for games.
* **USB3.0 Card:** A PCIx4 card which gives two USB3.0 sockets and a header. Used to provide USB3.0 connections to the front of the case with incompatible motherboards in the past.

The steps taken to enable the passthrough are documented in the [pci-passthrough](https://github.com/fescrb/kvm-settings/tree/master/pci-passthrough) subfolder.

## Storage



## The Script

### First Run

## Resolved Issues

The following issues were fixed satisfactorily:

### Crackling Audio In Guest

Solved through matching the audio quality to the pulseaudio server running in the host.

## Ongoing Issues

Will be removed as fixes are found:
* **Guest cannot recover from sleep mode:** When the guest system goes to sleep/hibernation I've been unable to recover it. Only restarting the VM works. Disabled automatic hibernation in Windows for a workaround.

## Wishlist for Future 

The following is a list of hardware improvements that could be made for the next version of this setup.

* **PCI SATA Controller:** PCI passthrough is fast and (now) familiar technology. A SATA PCI card would allow us to isolate it to hand it to the VM.
* **Full Drive Handover:** If the above wishlist item does not pan out. It would be good to fix handing over the full drive to qemu instead of having lvm over it. We've seen this working with the large storage drive. And it would enable us to access the windows drive more easily and boot straight from it. 
