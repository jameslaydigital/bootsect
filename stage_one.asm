[bits 16]
[org 0x7c00]
REAL_LOAD_ADDR: equ 0x9000   ; This is where I'm loading the 2nd stage in RAM.
LOAD_ADDR: equ 0x900   ; This is where I'm loading the 2nd stage in RAM.

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

    mov ax, start
    call print_hex

    ;;let users know the next bootloader is loading
    call print_newline
    mov ax, loading_phase_1
    call print_string
    call print_newline

    call disk_load      ; load the new instructions
                        ; at 0x9000
    jmp 0000:0x9000     ; will take you to 0x9000 and set CS register automatically

%include "print.asm"
%include "disk_load.asm"

loading_phase_1: db 'Loading bootloader phase 1', 0

times 510 - ($ - $$) db 0
dw 0xaa55 ;; end of bootsector
