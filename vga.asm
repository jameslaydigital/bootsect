set_bg:
    push bp
    mov bp, sp
    mov cx, [bp+4]  ;move arg 1 to cx
    mov bx, 0xA000  ;VGA video mem starts at 0xA0000
    mov es, bx  ;...because you can't directly set es.
    xor bx, bx  ;Nullify bx because we're done with it
    .start:
        cmp bx, 64000
        je .done
        mov word [es:bx], cx    ; actually write to video mem
        inc bx
        jmp .start
    .done:
    pop bp
    ret

set_letter_a;
    ;; set_letter( start_x, start_y, color )
    push bp
    mov bp, sp
    mov bx, 0xA000
    mov es, bx
    mov bx, 0
                        ;; (start_y * 320) + start_x
    mov cx, [bp + 4]    ;start_x
    mov dx, [bp + 6]    ;start_y
    mov ax, 320         ;screen width
    mul dx              ;multiply by dx
    add ax, cx

    mov bx, ax
    mov cx, [bp + 8]    ;color
    mov [es:bx], cl
    add cx, 1

    pop bp
    ret

set_video_mode:
    mov ah, 0x0     ;Set video mode
    mov al, 0x13    ;256-color
    int 0x10
    ret

set_pxl:
    push bp     ;save to return later
    mov bp, sp  ;set base of stack
    mov bx, 0xA000  ;VGA video mem starts at 0xA0000. The start address is too
                    ;large to be indexed without segment registers, so we have
                    ;to use es.
                ;   we use bx 
    mov es, bx  ;...because you can't directly set es.
    xor bx, bx  ;Nullify bx because we're done with it

    ;; CALCULATE OFFSET FOR X AND Y
    ;; ( y * numCols ) + x
    mov bx, [ bp + 4 ]      ; y coordinate
    mov ax, 320
    mul bx
    mov bx, ax
    add bx, [ bp + 6 ]      ; x coordinate
    mov cx, [ bp + 8 ]      ; move color to cx
    mov [es:bx], cl    ; actually write to video mem
    pop bp  ;return base pointer to original
    ret