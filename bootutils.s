clear_regs:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    ;clear index registers
    mov si, ax
    mov di, ax
    ;clear segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ret
clear_gp:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
clear_index:
    push ax
    xor ax, ax
    mov si, ax
    mov di, ax
    pop ax
    ret
clear_stack:
    push ax
    xor ax, ax
    mov sp, ax
    mov bp, ax
    pop ax
    ret
clear_segement:
    push ax
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    pop ax
    ret

hang:
    jmp $