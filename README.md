# WELCOME TO KIMINOBOOT

KiminoBoot is a 3-stage Partition & Master bootloader, as shown in [KiminoOS](https://github.com/notsomeidiot123/KiminoOS/)

## DETAILS:

  CURRENTLY NEITHER SUPPORT FLOPPY BOOT

### KiminoMBR

KiminoMBR is the name of the master boot record. All that it does relocate to 0x600 then look for and load the first bootable partition. 

FOR USE WITH YOUR OWN BOOTLOADER, THE BOOTDRIVE NUMBER IS STORED IN REGISTER DL, AND THE PARTITION OFFSET IS STORED IN CX

### KiminoBoot

KiminoBoot is the main bootloader in this project. It loads from a partition, and can read the partition table. It uses CX as the offset from
the partition table to determine where to start reading from the hard drive.

What KiminoBoot Does:
  - Set up a basic ring-0-only GDT with Code, Data, and TSS segments
  - Attempt to enable A20 Line (check BUGS.md)
  - Attempt to get a memory map, returns three (3) variables related, and two flags in a fourth (4th) variable
  - Attempt to check for and gather basic CPUINFO
  - Read from partition and jump to Kernel
  - enter protected mode

What KiminoBoot Does Not:
  - automatically detect size of your kernel, or appropriate amount to read. The amount read can be edited, but you are responsible for Recompiling
  - Act as good or as reliable as GRUB. This is just a small bootloader that fit MY needs, and I'm putting in a completely free repository for others to use
  
If someone stumbles across this, and decides they want to use it, but have a specific feature, PLEASE let me know! either through opening an issue, or whatever. I'd be glad to improve this!
