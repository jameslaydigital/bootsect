set_a20:;ENTRY POINT
    pusha
    call check_A20
    cmp ax, 1
    je .a20_is_set
    ;call set_a20_bios ;;check a20 after each of these...
    ;call set_a20_ps2
    ;call set_a20_fast
    mov ax, .fail_msg
    call 0x7c0:print_string
    call 0x7c0:print_newline
    .fail_msg: db 'Failed to set A20. Please reboot.', 0
    jmp $
    .a20_is_set:
    popa
    ret

check_A20:
    pushf                           ; Save only the regs we're using here
    push ds
    push es
    push di
    push si
    cli
    xor ax, ax                      ; 1MB = 16^5, or 1048576, or 0x100000
    mov es, ax                      ; Set es:di = 0000:0500
    mov di, 0x0500
    mov ax, 0xffff                  ; Set ds:si = ffff:0510
    mov ds, ax                      ; ffff0 + 510 = 0x100500
    mov si, 0x0510
    mov al, byte [es:di]            ; Save [es:di] on stack
    push ax                         ; for retrieval later.
    mov al, byte [ds:si]            ; Save [ds:si] on stack.
    push ax                         ; for later retrieval.
    mov byte [es:di], 0x00          ; [es:di] = 0x00
    mov byte [ds:si], 0xFF          ; [ds:si] = 0xff
    cmp byte [es:di], 0xFF          ; Did memory wrap around?
    pop ax
    mov byte [ds:si], al            ; Restore byte at ds:si
    pop ax
    mov byte [es:di], al            ; Restore byte at es:di
    mov ax, 0
    je .return_a20                  ; Return 0 if memory wrapped around
    mov ax, 1                       ; return 1.
    .return_a20:
        pop si                      ; Restore saved regs
        pop di
        pop es
        pop ds
        popf
    ret

;DOCUMENTATION FOR THE KEYBOARD CONTROLLER
;
;┌──────────────────────────────────────────┐
;│       PORT MAPPING                       │
;├─────┬───────┬────────────────────────────┤
;│PORT │ R/W   │ DESCRIPTON                 │
;├─────┼───────┼────────────────────────────┤
;│0x60 │ R+W   │ Read/Write Data            │
;│0x64 │ R     │ Read Status Register       │
;│0x64 │ W     │ Send Command to controller │
;└─────┴───────┴────────────────────────────┘
;0001110000011100
; 0┌─Bit 0: Output Buffer Status
;  │     ├─ 0: Output buffer empty, dont read yet
;  │     └─ 1: Output buffer full, please read me :)
;  │
; 0├─Bit 1: Input Buffer Status
;  │     ├─ 0: Input buffer empty, can be written
;  │     └─ 1: Input buffer full, dont write yet
;  │
; 1├─Bit 2: System flag
;  │     ├─ 0: Set after power on reset
;  │     └─ 1: Set after successfull completion of the keyboard controllers
;  │           self-test (Basic Assurance Test, BAT)
;  │
; 1├─Bit 3: Command Data
;  │     ├─ 0: Last write to input buffer was data (via port 0x60)
;  │     └─ 1: Last write to input buffer was a command (via port 0x64)
;  │
; 1├─Bit 4: Keyboard Locked
;  │     ├─ 0: Locked
;  │     └─ 1: Not locked
;  │
; 0├─Bit 5: Auxiliary Output buffer full
;  │     ├─ PS/2 Systems:
;  │     │   ├─ 0: Determines if read from port 0x60 is valid If valid,
;  │     │   │     0=Keyboard data
;  │     │   └─ 1: Mouse data, only if you can read from port 0x60
;  │     └─ AT Systems:
;  │         ├─ 0: OK flag
;  │         └─ 1: Timeout on transmission from keyboard controller to
;  │               keyboard. This may indicate no keyboard is present.
;  │
; 0├─Bit 6: Timeout
;  │     ├─ 0: OK flag
;  │     ├─ 1: Timeout
;  │     ├─ PS/2:
;  │     │   └─ General Timeout
;  │     └─ AT:
;  │         └─ Timeout on transmission from keyboard to keyboard controller.
;  │            Possibly parity error (In which case both bits 6 and 7 are set)
;  │
; 0└─Bit 7: Parity error
;        ├─ 0: OK flag, no error
;        └─ 1: Parity error with last byte
;┌────────────────────────────────────────────────────────────┐
;│Keyboard Controller Commands                                │
;├──────────────────┬─────────────────────────────────────────┤
;│KEYBOARD COMMAND  │ DESCRIPTON                              │
;├──────────────────┼─────────────────────────────────────────┤
;│  0x20            │ Read Keyboard Controller Command Byte   │
;│  0x60            │ Write Keyboard Controller Command Byte  │
;│  0xAA            │ Self Test                               │
;│  0xAB            │ Interface Test                          │
;│  0xAD            │ Disable Keyboard                        │
;│  0xAE            │ Enable Keyboard                         │
;│  0xC0            │ Read Input Port                         │
;│  0xD0            │ Read Output Port                        │
;│  0xD1            │ Write Output Port                       │
;│  0xDD            │ Enable A20 Address Line                 │
;│  0xDF            │ Disable A20 Address Line                │
;│  0xE0            │ Read Test Inputs                        │
;│  0xFE            │ System Reset                            │
;└──────────────────┴─────────────────────────────────────────┘
