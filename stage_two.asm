[bits 16]
;[org 0x9000]
seg_two:
    ;;set the segment registers
    mov ax, 0x900
    mov ds, ax
    mov es, ax
    mov ah, 0x0e
    mov al, 0x05
    int 0x10
    jmp $

; %include "gdt.asm"
; %include "print.asm"
; %include "a20.asm"

times 2048 db 0xf
