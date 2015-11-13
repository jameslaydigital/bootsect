[bits 16]
[org 0x7c00]
LOAD_ADDR: equ 0x9000   ; This is where I'm loading the 2nd stage in RAM.

start:

    xor ax,ax      ; We want a segment of 0 for DS for this question
    mov ds,ax      ; Set AX to appropriate segment value for your situation
    mov es,ax      ; In this case we'll default to ES=DS
    mov bx,0x8000  ; Stack segment can be any usable memory

    cli            ; Disable interrupts to circumvent bug on early 8088 CPUs
    mov ss,bx      ; This places it with the top of the stack @ 0x80000.
    mov sp,ax      ; Set SP=0 so the bottom of stack will be @ 0x8FFFF
    sti            ; Re-enable interrupts

    cld            ; Set the direction flag to be positive direction

    ; my version
    ;xor ax, ax          ; nullify ax so we can set 
    ;mov ds, ax          ; ds to 0
    ;mov sp, bp          ; relatively out of the way
    ;mov bp, 0x8000      ; set up the stack

    pusha
    mov ah, 0x0e
    mov al, 0x0e
    int 0x10
    popa

    call disk_load      ; load the new instructions
                        ; at 0x9000
    jmp LOAD_ADDR
%include "disk_load.asm"
times 510 - ($ - $$) db 0
dw 0xaa55 ;; end of bootsector
