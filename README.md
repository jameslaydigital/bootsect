# bootsect
Just another assembly x86 BIOS bootloader

###build process
The relevant file is `bootloader.asm`, which contains the MBR and subsequent
sectors.  

To build and run the emulator, I run `build.sh`. `build.sh` assembles asm into
a raw binary "disk", then runs it with qemu.  

When you build a kernel, you'll want to concatenate the resulting binary data
to raw.bin, so it can be loaded into memory by the bootloader.  

For additional information, check [./TUTORIAL.md](the accompanying tutorial).
