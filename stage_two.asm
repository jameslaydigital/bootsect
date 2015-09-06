[bits 16]
[org 0x9000]
seg_two:
    jmp main
%include "print.asm"
%include "vga.asm"

main:
    call set_video_mode
    push 226
    call set_bg
    pop ax
    push 5
    push 5
    push 5
    call set_letter_a
    pop ax
    pop ax
    pop ax

    push 8
    push 8
    push 8
    call set_pxl
    pop ax
    pop ax
    pop ax
    jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 2048 db 0xf
