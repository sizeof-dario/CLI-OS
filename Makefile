.PHONY: all run clean

# Variables
CC = gcc
AS = nasm
LD = ld

# Flags
CCFLAGS = -ffreestanding -mno-mmx -mno-sse -mno-sse2 -nostdlib -m32 -O0 -Wall -Wextra -Werror -g
ASFLAGS = -f elf32
LDFLAGS = -T linker.ld -nostdlib

# Directories
BOOT_DIR = boot
KERNEL_DIR = kernel
ISO_DIR = iso

# Source files
BOOT_SRC = $(BOOT_DIR)/boot.asm
KERNEL_SRC = $(KERNEL_DIR)/kernel.c

# Object files
BOOT_OBJ = $(BOOT_DIR)/boot.o
KERNEL_OBJ = $(KERNEL_DIR)/kernel.o

# Output files
KERNEL_BIN = cli-os.bin
ISO = cli-os.iso

# Rules
all: $(ISO)

$(BOOT_OBJ): $(BOOT_SRC)
	$(AS) $(ASFLAGS) $(BOOT_SRC) -o $(BOOT_OBJ)

$(KERNEL_OBJ): $(KERNEL_SRC)
	$(CC) $(CCFLAGS) -c $(KERNEL_SRC) -o $(KERNEL_OBJ)

$(KERNEL_BIN) : $(BOOT_OBJ) $(KERNEL_OBJ)
	cat -A Makefile | grep "^\^I\|^[^ ]"$(LD) $(LDFLAGS) $(BOOT_OBJ) $(KERNEL_OBJ) -o $(KERNEL_BIN)

# Create ISO
$(ISO): $(KERNEL_BIN)
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/
	grub2-mkrescue $(ISO_DIR) -o $(ISO)

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -f $(BOOT_OBJ) $(KERNEL_OBJ) $(KERNEL_BIN) $(ISO) $(ISO_DIR)/boot/cli-os.bin
