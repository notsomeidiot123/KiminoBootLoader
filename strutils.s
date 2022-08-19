printstr:
    mov ah, 0xe
    mov si, bx
    .strloop:
        lodsb
        or al, al
        jz .strret
        int 0x10
        jmp .strloop
    .strret:
        ret