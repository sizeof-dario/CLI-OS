%define MAGIC       0xE85250D6
%define X86         0
%define POW2E32     0x100000000
%define SIZE6KB     0x4000
%define MB2_MAGIC   0x36d76289

global _start

extern kernel_main

section .multiboot2
header_start:
    dd  MAGIC                                                   ; Magic number.
    dd  X86                                                     ; Architecture.
    dd  header_end - header_start                               ; Header size.
    dd  POW2E32 - (MAGIC + X86 + (header_end - header_start))   ; Checksum.
    dw  0                                                       ; End tag.
    dw  0                                                       ; No option.
    dd  8                                                       ; End tag size.
header_end:

section .text
_start:
    ; After loading and verifying the kernel, GRUB puts a magic number and a
    ; pointer hardware info into eax and ebx respectively (they are 32-bit
    ; values). We move them into edi and esi to temporarily save them.
    mov     edi,    eax 
    mov     esi,    ebx

    ; We set the stack pointer.
    mov     esp,    stack_top

    ; We check the kernel was actually loaded by GRUB.
    cmp     edi,    MB2_MAGIC
    jne     .no_multiboot2

    ; We now load oad the GDT.
    lgdt    [gdt32.pointer]

    ; We update the data segments.
    mov     ax,     0x10
    mov     ds,     ax
    mov     es,     ax
    mov     fs,     ax
    mov     gs,     ax
    mov     ss,     ax

    ; We update the code segment.
    jmp     0x08:protected_mode

protected_mode:

    ; We push GRUB magic number and hardware info pointer onto the stack.
    push    esi
    push    edi

    ; We call kernel_main.
    call    kernel_main

    ; We halt if kernel_main returns for any reason.

.no_multiboot2:
    cli
.halt:
    hlt
    jmp     .halt

section .bss
stack_bottom:
    resb    SIZE16KB
stack_top:

section .rodata
gdt32:
    dq 0                    ; Null descriptor.
.code:
    dq 0x00CF9A000000FFFF   ; Code segment descriptor.
.data:
    dq 0x00CF92000000FFFF   ; Data segment descriptor.
.pointer:
    dw $ - gdt32 - 1        ; GDT size.
    dq gdt32                ; GDT address.
