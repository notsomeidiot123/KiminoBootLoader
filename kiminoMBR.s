[org 0x600]
bits 16
;;NOTE SEGMENT ADDRESSING IS [SEGMENT * 16 + OFFSET]
;;FOR EXAMPLE: ES:DI ES=0X0111 DI=0X0055
;;THE PHYSICAL ADDRESS WOULD BE 0X11165
power:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov si, 0x7c00
    mov di, 0x600
    mov cx, 256
    rep movsw
    jmp 0x0:set_stack
    set_stack:
        mov ax, 0x9000 ;set stack pointer
        mov bp, ax
        mov sp, bp
        xor ax, ax
    mov [bootdisc], dl
    call clear_regs
    ; call relocate
    ; jmp 0:$-0x7c00+0x600 + 1
    ;print string
    mov bx, mark
    call printstr

    call clear_gp
    mov eax, KiminoOS_Part; base of the partition table
    looppart:
        cmp cx, 4
        je noboot;
        cmp byte [eax], 0x80
        jge load_os
        inc cx
        add ax, 16 
        jmp looppart;loop until found bootable sector
        ;TODO: CHANGE TO ALLOW SELECTION OF BOOTED PARTITION
        ;IDEA: GET ONE KEY INPUT, WHILE CHAR INP > '4' || INP < '0' GETKEY()
        ;if multiple bootable partitions found, change offset to proper number
        ;---------------;
        ;select: 6551   ;
        ;booting part. 1;
        ;//more boot\\  ;
        ;-not-my-problem;
    load_os:
        push cx
        mov [offset], eax
        cmp byte [bootdisc], 0x80
        jge .harddisk
        jmp .floppy

        .harddisk:

            mov ah, 0x41
            mov dl, [bootdisc]
            mov bx, 0x55aa
            int 13h
            jc noboot
            and cx, 1
            cmp cx, 1
            jne noboot
            
            mov eax, [offset]
            mov ebx, [KiminoOS_Part.]
            mov [DAP.start],ebx
            mov ah, 0x42
            mov dl, [bootdisc]
            mov si, DAP
            int 13h
            jc noboot
            mov dl, [bootdisc]
            pop cx
            jmp 0:PartBoot
            jmp $
        .floppy:
            mov bx, bfloppy
            call printstr
            jmp $
        jmp $
    noboot:
        mov bx, nobootstr
        call printstr
        jmp $

jmp $
    
%include "src/MBR/strutils.s"
%include "src/MBR/bootutils.s"

bfloppy: db "BOOTING FROM FLOPPY DISK", 0xa, 0xd, 0x0
nobootstr: db "NO BOOTABLE PARTITION FOUND", 0xa, 0xd, 0x0
mark: db "KIMINOMBR v1.1.0", 0xa, 0xd, 0
PartBoot equ 0x7c00
bootdisc db 0
offset dd 0
DAP:
    .size:
        db 0x1
    .res:
        db 0
    .sectors:
        dw 1
    .offset:
        dw PartBoot
    .segemnt:
        dw 0
    .start:
        dd 0
        dd 0
times 440-($-$$) db 0
db 'K', 'I','M','I'
dw 0
Part_0:
    .flags:
        db 0x81;bootable offset 0
    .start_head:
        db 0
    .start_sector:
        db 2
    .start_cyl:
        db 0
    .sys_id:
        db 0
    .end_head:
        db 0
    .end_sector:
        db 0
    .end_cyl:
        db 0
    .start_LBA:
        dd 0
    .size:
        dd 0
Part_1:
    .flags:
        db 0x81;bootable offset 0
    .start_head:
        db 0
    .start_sector:
        db 2
    .start_cyl:
        db 0
    .sys_id:
        db 0
    .end_head:
        db 0
    .end_sector:
        db 0
    .end_cyl:
        db 0
    .start_LBA:
        dd 0
    .size:
        dd 0
Part_2:
    .flags:
        db 0x81;bootable offset 0
    .start_head:
        db 0
    .start_sector:
        db 2
    .start_cyl:
        db 0
    .sys_id:
        db 0
    .end_head:
        db 0
    .end_sector:
        db 0
    .end_cyl:
        db 0
    .start_LBA:
        dd 0
    .size:
        dd 0
Part_3:
    .flags:
        db 0x81;bootable offset 0
    .start_head:
        db 0
    .start_sector:
        db 2
    .start_cyl:
        db 0
    .sys_id:
        db 0
    .end_head:
        db 0
    .end_sector:
        db 0
    .end_cyl:
        db 0
    .start_LBA:
        dd 0
    .size:
        dd 0
db 0x55, 0xaa