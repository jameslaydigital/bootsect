;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒▒┌─────────────────────────────────┐▒▒▒▒▒▒
;▒▒▒▒▒│ VGA FUNCTIONS                   │▒▒▒▒▒▒
;▒▒▒▒▒├─────────────────────────────────┤▒▒▒▒▒▒
;▒▒▒▒▒│     void set_bg ( color )       │▒▒▒▒▒▒
;▒▒▒▒▒│     void set_video_mode ()      │▒▒▒▒▒▒
;▒▒▒▒▒│     void set_pxl ( color, x, y )│▒▒▒▒▒▒
;▒▒▒▒▒└─────────────────────────────────┘▒▒▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

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

set_video_mode:
    mov ah, 0x0     ;Set video mode
    mov al, 0x13    ;256-color
    int 0x10
    ret

set_pxl:
    ;; set_pxl ( color, x, y )

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

set_character:
    ;; set_title(offset_x, offset_y)
    push bp
    mov bp, sp

    mov bx, letter_a

    .loop:
    push 10

    mov ax, [bp + 4]    ; ax gets arg
    add ax, [bx]        ; ax += letter_a[bx] 
    push ax             ; save that number

    add bx, 2           ; c++
    mov ax, [bp + 6]    ; ax gets arg
    add ax, [bx]        ; ax += letter_a[bx] 
    push ax             ; save that number

    call set_pxl

    add sp, 6

    ; if [bx] != 0; jmp .loop
    add bx, 2           ; c++
    cmp bx, 0
    jne .loop
    .end:

    mov sp, bp
    pop bp
    ret

letter_a: dd 9,9, 9, 5, 0, 0
count: dw 0
