print_char:
    ;print_char(char al)
    pusha
        mov ah, 0x0e
        int 0x10
    popa
    retf

print_string:
    ;print_string(buffer ax)
    pusha           ; preserve the registers 
                    ; on the stack.

    mov bx, ax
    .print_string_loop:
        mov al, [bx]            ;move buffer character to al
        cmp al, 0               ;if [[ al == 0 ]]; then
        je .print_string_end    ;   goto .print_string_end
        inc bx                  ;else bx++
        call 0x7c0:print_char
        jmp .print_string_loop  ;   goto .print_string_loop

    .print_string_end:
    popa
    retf

print_newline:
    ;print_newline()
    push ax

    mov al, 0x0a
    mov ah, 0x0e
    int 0x10
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10

    pop ax
    retf

__print_hex_char:
    ;__print_hex_char(char al)
    pusha
    .print_hex_loop:
        ;print a single hex digit
        cmp al, 0x9
        jg a_thru_f
        zero_thru_nine:
            add al, '0'
            call 0x7c0:print_char
            jmp __print_hex_char_end
        a_thru_f:
            add al, 'A'-0xA
            call 0x7c0:print_char

    __print_hex_char_end:
    popa
    ret

print_hex:
    ;print_hex(uint16 ax)
    pusha

        ;note on little-endianness:
        ;   If you store 1234 in AX,
        ;   4 is the LSB, therefore:
        ;   AH = 12
        ;   AL = 34
        ;
        ;   Moral of the story --
        ;   If you print, you need to
        ;   print AH first.

        mov bl, al
        and bl, 0xF

        mov bh, al
        shr bh, 4
        and bh, 0xF

        mov cl, ah
        and cl, 0xF

        mov ch, ah
        shr ch, 4
        and ch, 0xF

        mov al, '0'
        call 0x7c0:print_char

        mov al, 'x'
        call 0x7c0:print_char

        mov al, ch
        call __print_hex_char

        mov al, cl
        call __print_hex_char

        mov al, bh
        call __print_hex_char

        mov al, bl
        call __print_hex_char

        mov al, ' '
        call 0x7c0:print_char

    popa
    retf

print_binary_byte:
    ;;void print_binary_byte(uint8 al)
    pusha

    mov bl, al
    mov cl, 10000000b
    .start:
    ;;while ( c > 0 ) {
    cmp cl, 0
    jz .end
    ;;  if ( bl & c > 0 ) echo 1
    ;;  else echo 0
    test bl, cl
    mov ax, '1'  ;;ax = 1
    jnz .not_zero
    mov ax, '0' ;;ax = 0
    .not_zero:
    call 0x7c0:print_char

    ;;  c = c >> 1
    shr cl, 1

    jmp .start

    .end:
    popa
    ret

print_binary_word:
    ;;void print_binary_byte(uint16 ax)
    pusha

    mov bx, ax ; copy to bx so we can use ax

    ;;c = 128
    ;;while ( c > 0 ) {
    ;;  if ( bx & c > 0 ) echo 1
    ;;  else echo 0
    ;;  c = c / 2 //non float can divide to 0
    ;;}

    ;;c = 128
    mov cx, 1000000000000000b
    ;65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1

    .start:
    ;;while ( c > 0 ) {
    cmp cx, 0
    jz .end

    ;;  if ( bx & c > 0 ) echo 1
    ;;  else echo 0
    test bx, cx
    mov ax, '1'  ;;ax = 1
    jnz .not_zero
    mov ax, '0' ;;ax = 0
    .not_zero:
    call 0x7c0:print_char

    ;;  c = c >> 1
    shr cx, 1

    jmp .start

    .end:
    popa
    retf

newline_buffer: db 0x0a, 0x0d, 0
;A.25  = div
;A.107 = mul
;A.160 = test
