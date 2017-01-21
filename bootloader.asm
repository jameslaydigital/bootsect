[bits 16]
[org 0x0]
start:
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    xor ax, ax
    cli ; Disable interrupts to circumvent bug on early 8088 CPUs
    mov ss, ax ; set stack segment to 0
    mov ax, 0xFFF0 ; stack pointer to 0xFFF0
    mov sp, ax  ; ...should be enough room
    sti ; Re-enable interrupts
    cld            ; Set the direction flag to be positive direction (I don't think I use this)
    call disk_load ; loads next 4 sectors on boot disk to ram at location "sector2", which is 0x7c00+512.
    jmp sector2_code
%include "print.asm"
%include "disk_load.asm"

times 510 - ($ - $$) db 0
dw 0xaa55 ;; end of bootsector
sector2: ;; start of 2nd bootloader
%include "a20.asm"
%include "gdt.asm"
sector2_code:
    ;;set regs
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax

    call set_a20;;a20.asm

    mov ax, .pmode_msg
    call 0x7c0:print_string
    call 0x7c0:print_newline
    call load_gdt;;gdt.asm
    ;; GO INTO PMODE:
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp code_descriptor_offset:protected_mode      
    jmp $
    .setting_a20: db 'Setting the a20 line...', 0
    .set_a20: db 'A20 is set!', 0
    .pmode_msg: db 'Entering 32-bit protected mode.',0
[bits 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    jmp $

times 512 db 0 ; make sure there are plenty more sectors on disk (we read about 4)
times 512 db 0
times 512 db 0
times 512 db 0
