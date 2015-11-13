[bits 16]
[org 0x9000]
seg_two:
    jmp main
%include "print.asm"
%include "vga.asm"

main:
    call set_video_mode ;set_video_mode()

    push 226
    call set_bg         ;set_bg(color)
    pop ax

    push 0 
    push 5
    call set_character
    add sp, 4

    jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 2048 db 0xf
