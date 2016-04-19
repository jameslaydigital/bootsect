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
string_b: db 'waiting for status ready...', 0
string_c: db 'status ready', 0
string_d: db '0x60 is ', 0

main:
    mov ax, 0x900
    mov ds, ax
    mov es, ax

    call print_newline
    mov ax, string_a
    call print_string
    call print_newline
    call enable_a20
    jmp $


enable_a20:
    pusha
    mov ax, string_b
    call print_string
    call print_newline

    mov ax, string_d
    call print_string
    call read_0x60
    call print_binary_byte
    call print_newline

    mov ax, string_c
    call print_string
    call print_newline

    popa
    ret

write_0x60:
    ;;void write_0x60(command ax)
    pusha

    call wait_0x60_writable
    out ax, 0x60

    popa
    ret

read_0x60:
    ;;ax = read_0x60()
    pusha
    
    call wait_0x60_readable
    in ax, 0x60
    popa
    ret

wait_0x60_readable:
    ;;void wait_0x60_readable()
    pusha

    ;while ( ax & 0001b == 0 ) wait; else return
    .start:
    xor ax, ax
    in ax, 0x64
    call print_binary_byte
    call print_newline
    test ax, 0001b ;lsb = output buff status
    jnz .start

    popa
    ret

wait_0x60_writable:
    ;;void wait_0x60_writable()
    pusha

    ;while ( ax & 0010b == 0 ) wait; else return
    .start:
    xor ax, ax
    in ax, 0x64
    call print_binary_byte
    call print_newline
    test ax, 0010b ;2nd lsb = input buff stat
    jnz .start

    popa
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

times 2048 db 0xf
