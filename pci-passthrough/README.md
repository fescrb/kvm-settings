# PCI Passthrough

PCI passthrough is achieved through the vfio driver. It uses the iommu feature we enabled earlier to give protected i/o access to hardware components to virtualized machines. While the vfio driver is assigned to a piece of hardware the host machine has no access to it. We will give the VM access through it via commandline later,

This document describes how to set up and how to assign the driver to the pieces of hardware we want to passthrough.

## Driver Setup

The kernel does not load the vfio driver by default, thus we have to add them to the modules list of the [initramfs](http://www.linuxfromscratch.org/blfs/view/cvs/postlfs/initramfs.html). In order to do this, we will add the following list to the end of the `/etc/initramfs-tools/modules` file:

```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

Then update the initramfs image with the command `update-initramfs -u`.

## Obtaining Hardware Info

Before we can assign the driver to specific hardware we have to find some identifying information. 

### Bus Index

The first piece of information we need is the bus number. It can be obtained through `lspci`. The output will be in this format:

```
[...]
00:01.0 VGA compatible controller: Intel Integrated Graphics Controller
02:00.0 Ethernet controller: PCI Express Gigabit Ethernet Controller
[...]
```

The first set of numbers in this output is the bus index. In the above example, `00:01.0` for the integrated graphics card and `02:00.0` for the ethernet controller.

### Vendor-Device ID

### IOMMU Group

### Modalias

This is the name that the kernel identifies the hardware with. We can use it to tell modprobe what hardware to assign a driver to. To obtain it we first need to know its **bus index**, instructions to obtain it are above.

### Info Script

The script `print-pci-info.sh` found in this folder prints all of the information described in this section into stdout.

## Assigning The Driver

### Through Modprobe Configuration



### CLI Commands