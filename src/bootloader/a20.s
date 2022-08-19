a20offmsg db "A20 Dis", 0x0
a20onmsg db "A20 En", 0x0
a db "abled", 0xa, 0xd, 0x0
check_a20:
    pushad
    mov edi, 0x012345
    mov ebx, 0x112345

    mov byte [edi], 0xaa
    mov byte [bx], 0x55

    cmp byte [edi], 0x55
    je a20_off
    
    mov bx, a20onmsg
    call printstr
    mov bx, a
    call printstr
    popad
    push 1
    ret

    a20_off:
        mov bx, a20offmsg
        call printstr
        mov bx, a
        call printstr
        popad
        push 0
        ret
    ret
jmp $

enable_a20:
    in al, 0x92
    or al, 2
    and al, 0xFE
    out 0x92, al
    ret
    
jmp $