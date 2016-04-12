start_of_gdt:

    ; null descriptor 
        dd 0                ; null descriptor--just fill 8 bytes with zero
        dd 0 
     
    ; Notice that each descriptor is exactally 8 bytes in size. THIS IS IMPORTANT.
    ; Because of this, the code descriptor has offset 0x8.
     
    ; code descriptor:          ; code descriptor. Right after null descriptor
        dw 0x0FFFF          ; limit low
        dw 0                ; base low
        db 0                ; base middle
        db 10011010b        ; access
        db 11001111b        ; granularity
        db 0                ; base high
     
    ; Data descriptor is 0x10 bytes offset from GDT start
     
    ; data descriptor:      ; data descriptor
        dw 0FFFFh           ; limit low (Same as code)
        dw 0                ; base low
        db 0                ; base middle
        db 10010010b        ; access
        db 11001111b        ; granularity
        db 0                ; base high
end_of_gdt:
toc:    ;;table of contents
    dw start_of_gdt
    dw end_of_gdt - start_of_gdt - 1
