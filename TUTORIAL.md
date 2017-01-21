Useful Links
============

- Info on nasm mnemonics:

    http://www.posix.nl/linuxassembly/nasmdochtml/nasmdoca.html#section-A.107

- Info on PS/2 Controller

    http://wiki.osdev.org/%228042%22_PS/2_Controller#PS.2F2_Controller_IO_Ports

- Info on A20 Line

    http://wiki.osdev.org/A20_Line#Keyboard_Controller_2

- General reading

    http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf

Descriptor Tables
=================

Global Descriptor Table:
========================

The GDT is a memory map for the CPU.
It divides available memory into __segments__.
Segments are ranked by permission levels, AKA "rings".
Ring 0 is system-level and Ring 3 is application-level.
We segment mem for two reasons:

- You can address a huge range of memory.
- The CPU will throw an exception when code tries to access memory it is not
  privy to.


The GDT defines segments by using "descriptors".
A descriptor is an 8-byte data structure. There are (at least) three:

- Null Descriptor (all zeroes)
- Code Descriptor
- Data Descriptor

The GDT is expected to have certain information in certain locations relative
to the start of the GDT. Once you have defined the GDT, it is loaded by
specifying the GDT start location in memory and its size limit as operands to
the LGDT opcode/mnemonic, which loads a special register the CPU uses to make
its segment definitions.

At any time, you can specify a new GDT and run LGDT to redefine segments.

The simplest GDT will define overlapping code and data segments that cover all
available memory. This basically gives us a flat memory model, which the kernel
will manage when it is loaded.

    ; null descriptor 
        dd 0                ; null descriptor--just fill 8 bytes with zero
        dd 0 
     
    ; Notice that each descriptor is exactally 8 bytes in size. THIS IS IMPORTANT.
    ; Because of this, the code descriptor has offset 0x8.
     
    ; code descriptor:          ; code descriptor. Right after null descriptor
        dw 0x0FFFF          ; limit low
        dw 0                ; base low
        db 0                ; base middle
        db 10011010b        ; access
        db 11001111b        ; granularity
        db 0                ; base high
     
    ; Data descriptor is 0x10 bytes offset from GDT start
     
    ; data descriptor:      ; data descriptor
        dw 0FFFFh           ; limit low (Same as code)
        dw 0                ; base low
        db 0                ; base middle
        db 10010010b        ; access
        db 11001111b        ; granularity
        db 0                ; base high

