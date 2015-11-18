[bits 16]
[org 0x9000]
seg_two:
    jmp main
%include "print.asm"
%include "vga.asm"

main:
    call set_video_mode
    push 247
    call set_bg

    push 14
    push 14
    push j_bmp
    push 12
    call set_character
    add sp, 6

    push 21
    push a_bmp
    push 12
    call set_character
    add sp, 6

    push 28
    push m_bmp
    push 12
    call set_character
    add sp, 6

    push 35
    push e_bmp
    push 12
    call set_character
    add sp, 6

    push 42
    push s_bmp
    push 12
    call set_character
    add sp, 6

    push 56
    push o_bmp
    push 15
    call set_character
    add sp, 6

    push 63
    push s_bmp
    push 15
    call set_character
    add sp, 8

    ;sti

    jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 2048 db 0xf
