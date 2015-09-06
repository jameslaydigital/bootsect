BITS 16
[org 0x7c00]

start:

    ;; TEXT SECTION

    mov [BOOT_DRIVE], dl    ; remember the boot drive addr in dl

    mov ah, 0
    mov al, dl
    call print_hex          ; printing the boot drive.

    mov bp, 0x8000          ; set up our stack safely out of the way
    mov sp, bp

    mov dh, 5               ; load 5 sectors
    mov bx, 0x9000          ; to 0x9000

    mov dl, [BOOT_DRIVE]    ; is this operation actually necessary?
    call disk_load

    mov ax, [0x9000 + 512]
    call print_hex

    jmp $               ;pause forever

    ;; DATA
    BOOT_DRIVE: db 0


    hello: db " Hi there! ", 0

    %include "print.asm"        ;functions that print
    %include "disk_load.asm"    ;functions that read from disks

    times 510-($-$$) db 0       ;Padd the remaining bytes with zero.
    dw 0xAA55                   ;End with BIOS magic number.


    times 256 dw 0xdada
    times 256 dw 0xface
