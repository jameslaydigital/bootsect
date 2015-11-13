[bits 16]
[org 0x7c00]
LOAD_ADDR: equ 0x9000   ; This is where I'm loading the 2nd stage in RAM.
start:
    xor ax, ax          ; nullify ax so we can set 
    mov ds, ax          ; ds to 0
    mov sp, bp          ; relatively out of the way
    mov bp, 0x8000      ; set up the stack
    call disk_load      ; load the new instructions
                        ; at 0x9000
    jmp LOAD_ADDR
%include "disk_load.asm"
times 510 - ($ - $$) db 0
dw 0xaa55 ;; end of bootsector
