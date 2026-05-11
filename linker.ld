ENTRY(_start)

SECTIONS
{
    /*  Starting address at 1MB after BIOS data. */
    . = 1M;

    /*  Executable code. */
    .text:
    {
        *(.multiboot2)
        *(.text)
    }

    /* Read only data. */
    .rodata:
    {
        *(.rodata)
    }

    /* Initialized data. */
    .data:
    {
        *(.data)
    }

    /* Unitialized reserved memory. */
    .bss:
    {
        *(.bss)
    }
}
