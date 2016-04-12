[bits 16]
[org 0x9000]
seg_two:
    jmp main
%include "print.asm"
%include "vga.asm"

main:
    call set_video_mode
    ;push 247
    ;call set_bg

    mov word ax, j_bmp
    mov word [sayhi], ax
    mov ax, a_bmp
    mov word [sayhi+2], ax
    mov ax, m_bmp
    mov word [sayhi+4], ax
    mov ax, e_bmp
    mov word [sayhi+6], ax
    mov ax, s_bmp
    mov word [sayhi+8], ax
    mov ax, space_bmp
    mov word [sayhi+10], ax
    mov ax, o_bmp
    mov word [sayhi+12], ax
    mov ax, s_bmp
    mov word [sayhi+14], ax
    xor ax, ax
    mov word [sayhi+16], ax

    push 200/3 ;y
    push 320/3+14 ;x
    push word sayhi
    push 9
    call set_string
    add sp, 8

    push 200/3
    push 320/3
    push square_bmp
    push 4
    call set_character
    add sp, 8

    push 200/3+3
    push 320/3+3
    push square_bmp
    push 5
    call set_character
    add sp, 8

    ;; NOW ENTER LONG MODE:
    jmp $

sayhi: times 10 dw 0x0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 2048 db 0xf
