[bits 16]
;[org 0x9000]
seg_two:
    ;;set the segment registers
    mov ax, 0x900
    mov ds, ax
    mov es, ax
    jmp main

%include "gdt.asm"
%include "print.asm"

test: db 'testing', 0
string_a: db 'checking status register: ', 0

main:
    mov ax, 0x900
    mov ds, ax
    mov ax, 0xF000
    mov ss, ax
    call print_newline
    mov ax, string_a
    call print_string
    call print_newline
    ;call enable_A20
    mov ax, 0x0004 
    call print_binary_byte

    jmp $

enable_A20:
    cli

    in ax, 0x60
    call print_hex
    call print_newline
    

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
;
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
;
;  ┌─Bit 0: Output Buffer Status
;  │     ├─ 0: Output buffer empty, dont read yet
;  │     └─ 1: Output buffer full, please read me :)
;  │
;  ├─Bit 1: Input Buffer Status
;  │     ├─ 0: Input buffer empty, can be written
;  │     └─ 1: Input buffer full, dont write yet
;  │
;  ├─Bit 2: System flag
;  │     ├─ 0: Set after power on reset
;  │     └─ 1: Set after successfull completion of the keyboard controllers
;  │           self-test (Basic Assurance Test, BAT)
;  │
;  ├─Bit 3: Command Data
;  │     ├─ 0: Last write to input buffer was data (via port 0x60)
;  │     └─ 1: Last write to input buffer was a command (via port 0x64)
;  │
;  ├─Bit 4: Keyboard Locked
;  │     ├─ 0: Locked
;  │     └─ 1: Not locked
;  │
;  ├─Bit 5: Auxiliary Output buffer full
;  │     ├─ PS/2 Systems:
;  │     │   ├─ 0: Determins if read from port 0x60 is valid If valid,
;  │     │   │     0=Keyboard data
;  │     │   └─ 1: Mouse data, only if you can read from port 0x60
;  │     └─ AT Systems:
;  │         ├─ 0: OK flag
;  │         └─ 1: Timeout on transmission from keyboard controller to
;  │               keyboard. This may indicate no keyboard is present.
;  │
;  ├─Bit 6: Timeout
;  │     ├─ 0: OK flag
;  │     ├─ 1: Timeout
;  │     ├─ PS/2:
;  │     │   └─ General Timeout
;  │     └─ AT:
;  │         └─ Timeout on transmission from keyboard to keyboard controller.
;  │            Possibly parity error (In which case both bits 6 and 7 are set)
;  │
;  └─Bit 7: Parity error
;        ├─ 0: OK flag, no error
;        └─ 1: Parity error with last byte


    pusha

    call print_newline

    call    .empty_8042
    mov     al,0xd1     ;command write
    out     0x64,al
    call    .empty_8042
    mov     al,0xdf     ;A20 on
    out     0x60,al
    call    .empty_8042

    mov ax, a20_done_msg
    call print_string
    call print_newline

    popa
    ret

    .empty_8042:
        ;call   delay
        in      al,0x64
        push ax
        xor ah, ah
        call print_hex
        call print_newline
        test    al,2
        jnz     .empty_8042
        ret

times 2048 db 0xf
