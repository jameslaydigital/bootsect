# bootsect
just another assembly x86 BIOS bootloader

###build process
The relevant files are `stage_one.asm` and `stage_two.asm`. `stage_one.asm` is the MBR, which functionally loads `stage_two.asm` into memory.  

To build and run the emulator, I run `build.sh`. `build.sh` compiles stage one and stage two to `stage_one.bin` and `stage_two.bin` respectively.  Then it concatenates them in that order to `raw.bin`.  

