[bits 16]
jmp h
h:
    jmp 0:0x7e00
    mov bx, hw
    call printstr
jmp $
hw db "Hello, World", 0xa, 0xd, 0x0
%include "bootloader/strutils.s"
times 8192-($-$$) db 0xff

