;; THIS IS NOT MY CODE
;; This is NOT used in the bootloader and is only a reference.
;; Taken from http://stackoverflow.com/a/7716700/1461154

[bits 16]
[org 0x7c00]

Start: jmp EntryPoint

PrintString16:
        pusha
.PrintLoop:
        lodsb
        or al, al
        jz .PrintDone
        mov ah, 0xe
        int 0x10
        jmp .PrintLoop
.PrintDone:
        popa
        ret

EntryPoint:
        xor ax, ax
        mov ss, ax
        mov ds, ax
        mov sp, 0x7c00
.DiskReset:
        mov ah, 0
        int 0x13
        jc .DiskReset
        mov ax, 0x50 ; load to 0x500 linear address. It has unused space up to 0x7bff
        mov es, ax
        xor bx, bx
        mov ax, 0x023B ; count = 0x3b = 59, the maximum (while still leaving soom room for the stack and the boot sector code we're currently running)
        mov cx, 0x0002
        xor dh, dh ; leave dl intact
        int 0x13
        jnc .ReadDone
        mov si, ReadError
        call PrintString16
        jmp .DiskReset
.ReadDone:
        ;jmp 0x50:0x0  ;jump to stage 2 loaded at 0x500

        cli
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ax, 0x9000
        mov ss, ax
        mov sp, 0xffff 
        sti

        mov si, HelloMsg
        call PrintString16

        ; Disable interrupts until safely in protected mode
        cli

        ; Install GDT
        lgdt [toc]

        ; Enable A20
        mov al, 0xdd
        out 0x64, al

        mov si, GoPMode
        call PrintString16

        ; enable protected mode
        mov eax, cr0 
        or eax, 1
        mov cr0, eax

        jmp 0x8:PmodeStart      
        bits 32
PmodeStart:
        ; setup stack and datasegments
        mov ax, 0x10
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        ; Setup stack at 0x90000
        mov esp, 0x90000

        ; Jump to C-code
        jmp 0x8:0x500

        ; Reboot if C-code returns
Reboot:
        mov word [0x472], 0x1234
        jmp 0x8:0xffff0


ReadError: db 'Read error - retrying...', 13, 10, 0
HelloMsg: db 'Loading...',0
GoPMode: db 'Entering protected mode..',0
gdt_data: 
        dd 0                            ; null descriptor
        dd 0 

; gdt code:                             ; code descriptor
        dw 0FFFFh                       ; limit low
        dw 0                            ; base low
        db 0                            ; base middle
        db 10011010b                    ; access
        db 11001111b                    ; granularity
        db 0                            ; base high

; gdt data:                             ; data descriptor
        dw 0FFFFh                       ; limit low (Same as code)10:56 AM 7/8/2007
        dw 0                            ; base low
        db 0                            ; base middle
        db 10010010b                    ; access
        db 11001111b                    ; granularity
        db 0                            ; base high

end_of_gdt:
toc: 
        dw end_of_gdt - gdt_data - 1    ; limit (Size of GDT)
        dd gdt_data                     ; base of GDT


times 510 - ($-$$) db 0 ; pad to 512 bytees, will also warn if we exceed 512 bytes
dw 0xAA55 ; boot signature
times 512 db 0 ; add another sector
times 512 db 0 ; 
times 512 db 0 ;
times 512 db 0 ;
