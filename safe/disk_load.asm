disk_load:
    push dx         ; We'll need this to recall how many sectors were requested.
    mov ah, 0x02    ; BIOS read sector fxn
    mov al, dh      ; read 'dh' sectors.
    mov ch, 0x00    ; cylinder/track 0
    mov dh, 0x00    ; head 0
    mov cl, 0x02    ; 2nd sector (after the boot sector)

    int 0x13

    jc no_disk_err

    pop dx
    cmp dh, al
    jne partial_read_err
    ret

no_disk_err:
    mov ax, ENODISK_ERR
    call print_string
    jmp $

partial_read_err:
    mov ax, EPARTIAL_READ_ERR
    call print_string
    jmp $

ENODISK_ERR:
    db 'No disk found.', 0

EPARTIAL_READ_ERR:
    db 'Partial read error.', 0
