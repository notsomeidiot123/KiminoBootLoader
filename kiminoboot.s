[org 0x7c00]
bits 16
jmp entry
bootdisc db 0
part_table dw 0x600+446
part_num db 0
offset db 0
entry:
    
;todo:
;ENABLE A20
;READ PARTITION TABLE
;LOAD PART 2
    mov [bootdisc], dl 
    cmp dl, 0x80
    jne .cloop
    
    mov [part_num], cx ;move data from MBR
    mov ah, 0
    mov al, 0x3
    int 10h
    mov bx, mark
    call printstr
    
    mov ax, 0x9000;set stack
    mov bp, ax
    mov sp, bp
    
    mov edx, 0
    mov cx, [part_num]
    cmp cx, 0
    je .loopdone
    .cloop:
        cmp cx, 0
        je .loopdone
        add edx, 16
        jmp .cloop
    .loopdone:
        mov [offset], edx
    ;get offset to correct partition
        
    call clear_regs
    call enable_a20
    .a20_on:
        ; read second stage of the bootloader from boot drive
        mov edx, [offset]
        mov ebx, [part_table]
        mov eax, [ebx + edx + 8] ;extract start sector from MBR
        add eax, 1 ;add one to get 2nd boot part
        mov [DAP.start], eax
        mov word [DAP.sectors], 4
        mov word [DAP.offset], 0x7e00
        mov bx, 0
        mov ds, bx
        
        mov ah, 0x42
        mov dl, [bootdisc]
        mov si, DAP
        int 0x13
        jc .error
        add eax, 4
        push eax
        jmp part2
        jmp $
        .error:
            mov bx, berr
            call printstr
            jmp $
    jmp $ 
    
halt:
    jmp $
DAP:
    .size:
        db 0x10
    .res:
        db 0
    .sectors:
        dw 1
    .offset:
        dw 0x7e00
    .segemnt:
        dw 0
    .start:
        dd 0
        dd 0
mark db "KIMINOBOOT v0.3.0", 0xa, 0xd, 0x0
loadstr db "Loading KiminoOS...", 0xa, 0xd, 0
berr db "Error loading second part", 0xa, 0xd, 0x0
nl db 0xa, 0xd, 0x0
%include "bootloader/strutils.s"
%include "bootloader/bootutils.s"
%include "bootloader/a20.s"
times 510-($-$$) db 0
db 0x55, 0x00

%include "bootloader/detect_mem.s"

vendor_id times 13 db 0
vend__str times 12 db 0
DB  0xa, 0xd, 0x0
proc_info times 16 db 0


cpuid_pr db "CPUID PRESENT      ", 0xa, 0xd, "VENDOR:", 0x0
cpuid_np db "CPUID NOT SUPPORTED", 0xa, 0xd, 0x0
BOOT_FLAGS DB 0
part2:
    pushf
    pop eax
    mov ebx, eax
    and ebx, 1 << 21
    cmp ebx, 0
    jnz .unset
    jmp .reset
    
    .unset:
        mov ebx, eax
        xor ebx, 1 <<21
        push ebx
        popf
        jmp .check
    .reset:
        mov ebx, eax
        or ebx, 1 <<21
        push ebx
        popf
    .check:
    pushf
    pop eax
    and eax, 1 << 21
    cmp eax, 0
    jz .continue_cpuid_off
    mov byte [BOOT_FLAGS], 1
    .CCPUID:
        mov bx, cpuid_pr
        call printstr
        mov eax, 0
        cpuid
        
        mov [vendor_id+0], ebx 
        mov [vendor_id+8], ecx
        mov [vendor_id+4], edx 
        mov [vend__str+0], ebx
        mov [vend__str+8], ecx
        mov [vend__str+4], edx
        
        mov bx, vend__str
        call printstr
        mov eax, 1
        cpuid
        
        mov [proc_info+00], eax
        mov [proc_info+04], ebx
        mov [proc_info+08], ecx
        mov [proc_info+12], edx
        jmp .mem
    .continue_cpuid_off:
        mov bx, cpuid_np
        call printstr
    .mem:
        call get_mmap
        jc .e1
        jmp .start_protected_mode
        
        .e1:
            or byte [BOOT_FLAGS], 2
            call no_e820_mmap_res1
            jnc .start_protected_mode
            xor byte [BOOT_FLAGS], 2
        .e2:
            call all_failed
            or byte [BOOT_FLAGS], 4
            jnc .start_protected_mode
            or byte [BOOT_FLAGS], 2
    .start_protected_mode:
        pop eax
        mov word [DAP2.offset],0x800 
        mov word [DAP2.sectors], 1
        mov dword [DAP2.start], 4
        
        mov bx, 0
        mov ds, bx
        mov ah, 0x42
        mov dl, [bootdisc] ; <- will not load for some reason?
        mov si, DAP2
        int 0x13
        mov bx, berr
        
        jc .error
        jmp 0:0x800
        jmp $
        .error:
            mov bx, berr
            call printstr
            jmp $
    jmp $
DAP2:
    .size:
        db 0x10
    .res:
        db 0
    .sectors:
        dw 1
    .offset:
        dw 0
    .segemnt:
        dw 0
    .start:
        dd 0
        dd 0
;part2 TODO
;detect memory & produce memory map [X]
;load initial GDT <-- RELOAD A BETTER GDT DURING USERSPACE INITIALIZATION
;change video mode to basic text mode, until kernel changes it
;CPUID [x]
;jump to kernel
;BOOT_FLAGS: 
;BIT 7 = RES, BIT 6 = RES, BIT 5 = RES, BIT 4 = RES, BIT 3 = RES, BIT 2 = USE_MEMLOW, BIT 1=USE MEMLO+HI, BIT 0 = CPUINFO PRESENT
; if both bit 2 and bit 1 are high, error occured detecting memory


times 2048-($-$$) db 0