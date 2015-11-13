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

    push 9
    push 9
    push 9
    call set_pxl        ;set_pxl(color,x,y)
    add sp, 2           ;rewinding sp by only 2 bytes because I
                        ;will reuse the arguments from the stack

    push 8
    call set_pxl        ;set_pxl, changing only x
    add sp, 6

    jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 2048 db 0xf
