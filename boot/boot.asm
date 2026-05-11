%define MAGIC       0xE85250D6
%define X86         0
%define POW2E32     0x100000000
%define 16KB        0x4000
%define MB2_MAGIC   0x36d76289

global _start

section .multiboot2
header_start:
    dd  MAGIC                                                   ; Magic number
    dd  X86                                                     ; Architecture
    dd  header_end - header_start                               ; Header size
    dd  POW2E32 - (MAGIC + X86 + (header_end - header_start))   ; Checksum
    dw  0                                                       ; End tag
    dw  0                                                       ; No option
    dd  8                                                       ; End tag size
header_end:

section .text
_start:
    ; After loading and verifying the kernel, GRUB puts a magic number and a
    ; pointer hardware info into eax and ebx respectively (they are 32-bit
    ; values). We move them into edi and esi according to the System V AMD64 ABI
    ; standard.
    mov edi,    eax 
    mov esi,    ebx

    ; We set the stack pointer.
    mov rsp,    stack_top

    ; We check the kernel was actually loaded by GRUB.
    cmp edi,    MB2_MAGIC
    jne .no_multiboot2

.no_multiboot2:
    cli
.halt:
    hlt
    jmp .halt

section .bss
stack_bottom:
    resb    16KB
stack_top:
