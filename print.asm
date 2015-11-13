print_char:
    pusha
        mov ah, 0x0e
        int 0x10
    popa
    ret

print_string:
    pusha           ; preserve the registers 
                    ; on the stack.
    mov bx, ax
    .print_string_loop:
        mov al, [bx]            ;move buffer character to al
        cmp al, 0               ;if [[ al == 0 ]]; then
        je .print_string_end    ;   goto .print_string_end
        inc bx                  ;else bx++
        call print_char
        jmp .print_string_loop  ;   goto .print_string_loop

    .print_string_end:
    popa
    ret

print_hex_char:
    pusha
    print_hex_loop:

        ;print a single hex digit
        cmp al, 0x9
        jg a_thru_f
        zero_thru_nine:
            add al, '0'
            call print_char
            jmp print_hex_char_end
        a_thru_f:
            add al, 'A'-0xA
            call print_char

    print_hex_char_end:
    popa
    ret

print_hex:

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
        call print_char

        mov al, 'x'
        call print_char

        mov al, ch
        call print_hex_char

        mov al, cl
        call print_hex_char

        mov al, bh
        call print_hex_char

        mov al, bl
        call print_hex_char

        mov al, ' '
        call print_char

    popa
    ret

