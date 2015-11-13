; load DH sectors to ES:BX from drive DL
disk_load :

    mov ah, 0x02            ;read from disk
    mov al, [num_sectors]   ;read sector(s)

    mov bx, 0
    mov es, bx

    mov ch, 0x00    ;track 0
    mov cl, 0x02    ;start from 2nd sector
    mov dh, 0x00    ;head 0
    ;mov dl, 0x80    ;HDD 1

    mov bx, LOAD_ADDR  ;Where we read to in RAM.
    int 0x13        ; BIOS interrupt

    jc disk_error   ; Jump if error ( i.e. carry flag set )

    cmp al, [num_sectors]   ; if num read != num expected
        jne disk_error      ; display error message

    mov ax, READ_SUCCESS
    call print_string
    ret

disk_error :
    mov ax, DISK_ERROR_MSG
    call print_string

    ; Get the status of the last operation.
    xor ax, ax      ; nullify ax
    mov ah, 0x01    ; status fxn
    ;mov dl, 0x80    ; 0x80 is our drive
    int 0x13        ; call fxn

    ;mov ah, 0       ; when we print ax, we only care about the status, 
                    ; which is in al. So, we probably want to nullify
                    ; 'ah' to prevent confusion.

    call print_hex  ; print resulting status msg.
    jmp $

status_error:
    mov ax, STATUS_ERROR
    call print_string
    jmp $

num_sectors: db 0x01

; Variables
DISK_ERROR_MSG: db "Disk read error: status = " , 0
STATUS_ERROR: db 'status failed.', 0
READ_SUCCESS: db 'Read success! ', 0

;AH  02h
;AL  Sectors To Read Count
;CH  Cylinder
;CL  Sector
;DH  Head
;DL  Drive
;ES:BX   Buffer Address Pointer

%include "print.asm"
