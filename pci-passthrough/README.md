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

The first set of numbers in this output is the bus index. In the above example, `00:01.0` for the integrated graphics card and `02:00.0` for the ethernet controller. This, however is not the full index, it is missing the domain number, we can see this with `lspci -D`:

```
[...]
0000:00:01.0 VGA compatible controller: Intel Integrated Graphics Controller
0000:02:00.0 Ethernet controller: PCI Express Gigabit Ethernet Controller
[...]
```

The domain name will almost always be 0000. The rest of the numbers are: `<bus>:<slot>.<function>`. The purpose of the *domain number* is to extend the number of PCI devices a system can have. Each bus addresses a different bridge and a device, well, is self-explanatory. Function number server to separate different functionalities in the same device. Importantly for us, the audio output of a graphics card wil be a separa function:

```
[...]
00:01.0 VGA compatible controller: NVIDIA Corporation
00:01.1 Audio device: NVIDIA Corporation
[...]
``` 

Make note of the numbers for the devices you want to pass through.

### Vendor-Device ID

The next piece of information is the vendor and device ID. These are unique identifiers for a maker and a product and are invariable accross instances of this product. In a system with two identical graphics cards, they will have the same *vendor and device IDs* but different *bus indices*.

To find out the vendor-device ID, execute `lspci -nn`:

```
[...]
00:01.0 VGA compatible controller: Intel Integrated Graphics Controller [1234:5678]
02:00.0 Ethernet controller: PCI Express Gigabit Ethernet Controller [9abc:def0]
[...]
```

Here, the vendor ID for the Ethernet controller is `9abc` and the device ID is `def0`.

### IOMMU Group

IOMMU groups physical devices into groups. These **must** be passed together and cannot be split or sent individually. To find out which devices are in each group we must explore the `/sys` filesystem. The folder `/sys/kernel/iommu_groups/` contains all groups in the system represented as folders:

```
user@host:~$ ls /sys/kernel/iommu_groups/
0  1  10  11  2  3  4  5  6  7  8  9
``` 

Each of these folders contains a symlink for each device in the group. The symlink leads to a folder which contains extra info for the device, and will be handy later. The symlink name itself is the *bus_index* of the device in the group, for example:

```
user@host:~$ ls /sys/kernel/iommu_groups/2/
0000:00:01.0
```

This way we are able to find which device is in each group.

### Modalias

This is the name that the kernel identifies the hardware with. We can use it to tell modprobe what hardware to assign a driver to. To obtain it we first need to know its **bus index**, instructions to obtain it are above. 

Once we know this, we can obtain the device's modalias through the `/sys` filesystem. The file `/sys/bus/pci/devices/<device_bus_index>/modalias` contains the modalias number. For example, to find out the Ethernet controller's modalias from the previous sections:

```
user@host:~$ ls /sys/bus/pci/devices/0000:02:00.0/modalias
pci:v00099086d01203EC2sv0000sd9sd00003EC2bc06sc01920
``` 

### Info Script

The script `print-pci-info.sh` found in this folder prints all of the information described in this section into stdout.

## Assigning The Driver

### Through Modprobe Configuration



### CLI Commands
