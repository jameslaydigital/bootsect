load_gdt:
    cli
    pusha
    lgdt [toc]
    sti
    popa
    ret

gdt_data: 
        dd 0            ; null descriptor
        dd 0 

gdt_code_descriptor:
        dw 0FFFFh   ;limit low, FFFF = 65535 bytes, or 64k
        dw 0        ;ptr low, offset of mem segment
        db 0        ;ptr middle, offset of mem seg
        db 10011010b;access:
                    ; 1bit is present? (required to be 1)
                    ; 2bit ring level (0-3)
                    ; 1bit is executable?
                    ; 1bit direction (0 grows up, 1 grows down, e.g. ptr > limit)
        db 11001111b;granularity
        db 0        ;ptr high

gdt_data_descriptor:
        dw 0FFFFh   ;limit low (Same as code)
        dw 0        ;ptr low
        db 0        ;ptr middle
        db 10010010b;access
        db 11001111b;granularity
        db 0        ;ptr high

end_of_gdt:
toc: 
        dw end_of_gdt - gdt_data - 1    ; limit (Size of GDT)
        dd gdt_data                     ; base of GDT

code_descriptor_offset equ gdt_code_descriptor - gdt_data
data_descriptor_offset equ gdt_data_descriptor - gdt_data

;; start_of_gdt:
;; 
;;     ; null descriptor 
;;         dd 0                ; null descriptor--just fill 8 bytes with zero
;;         dd 0 
;;      
;;     ; Notice that each descriptor is exactly 8 bytes in size. THIS IS IMPORTANT.
;;     ; Because of this, the code descriptor has offset 0x8.
;;      
;;     ; code descriptor:          ; code descriptor. Right after null descriptor
;;         dw 0x0FFFF          ; limit low
;;         dw 0                ; base low
;;         db 0                ; base middle
;;         db 10011010b        ; access
;;         db 11001111b        ; granularity
;;         db 0                ; base high
;;      
;;     ; Data descriptor is 0x10 bytes offset from GDT start
;;      
;;     ; data descriptor:      ; data descriptor
;;         dw 0FFFFh           ; limit low (Same as code)
;;         dw 0                ; base low
;;         db 0                ; base middle
;;         db 10010010b        ; access
;;         db 11001111b        ; granularity
;;         db 0                ; base high
;; end_of_gdt:
;; toc:    ;;table of contents
;;     dw start_of_gdt
;;     dw end_of_gdt - start_of_gdt - 1

;   BITLIST OF DESCRIPTOR ENTRY:
;;  Bits 56-63: Bits 24-32 of the base address
;;  Bit 55: Granularity
;;      0: None
;;      1: Limit gets multiplied by 4K
;;  Bit 54: Segment type
;;      0: 16 bit
;;      1: 32 bit
;;  Bit 53: Reserved-Should be zero
;;  Bits 52: Reserved for OS use
;;  Bits 48-51: Bits 16-19 of the segment limit
;;  Bit 47 Segment is in memory (Used with Virtual Memory)
;;  Bits 45-46: Descriptor Privilege Level
;;      0: (Ring 0) Highest
;;      3: (Ring 3) Lowest
;;  Bit 44: Descriptor Bit
;;      0: System Descriptor
;;      1: Code or Data Descriptor
;;  Bits 41-43: Descriptor Type
;;  Bit 43: Executable segment
;;      0: Data Segment
;;      1: Code Segment
;;  Bit 42: Expansion direction (Data segments), conforming (Code Segments)
;;  Bit 41: Readable and Writable
;;      0: Read only (Data Segments); Execute only (Code Segments)
;;      1: Read and write (Data Segments); Read and Execute (Code Segments)
;;  Bit 40: Access bit (Used with Virtual Memory)
;;  Bits 16-39: Bits 0-23 of the Base Address
;;  Bits 0-15: Bits 0-15 of the Segment Limit

; A NOTE ABOUT DESCRIPTORS - by James Lay ;-P
; Each descriptor takes four pieces of info: base pointer (begin address),
; limit (end address), access code (permissions), and some flags.
; 
; Now, these four pieces of information are fragmented across the 8 byte
; descriptor. The reason is a cautionary tale of poor design and failure to
; accomodate the future.  For instance, the limit variable was originally only
; an 16 bits, which means the maximum limit for a segment was 65535, or 64kB.
; Upon realizing this wouldn't be enough, they said, maybe 20 bits will be
; enough, and with no regard to Moore's law, or even Murphy's law, they
; inserted another nibble in the first half of the flags byte to extend the
; limit integer to 20 bits.  Surely, nobody will ever need to address more
; than a megabyte!? So, now they were in a pickle. They've basically used up
; the entire 8 bytes that is the descriptor, and they only have a couple of
; bits that can be reused. In the flags nibble, they decided they'd add a
; "granularity" flag, which effectively says the memory references are
; multipliers of 4kB instead of 1B, finally allowing the entire 4GB addressable
; range to be addressed in a descriptor.
;
; Here's a little snippet from OSDev about the granularity bit:
;    "Gr: Granularity bit. If 0 the limit is in 1 B blocks (byte granularity),
;    if 1 the limit is in 4 KiB blocks (page granularity)."
; 
