OBJS = main.o utils.o conversions.o help_commands.o

# Default target
.PHONY: all debug clean

# Release target
all: clean
	@echo "Building in release mode..."
	nasm -f elf64 main.asm -o main.o
	nasm -f elf64 utils.asm -o utils.o
	nasm -f elf64 conversions.asm -o conversions.o
	gcc -c help_commands.c -o help_commands.o
	gcc $(OBJS) -o main

# Debug target
debug: clean
	@echo "Building in debug mode..."
	nasm -g -F dwarf -f elf64 main.asm -o main.o
	nasm -g -F dwarf -f elf64 utils.asm -o utils.o
	nasm -g -F dwarf -f elf64 conversions.asm -o conversions.o
	gcc -g -c help_commands.c -o help_commands.o
	gcc -g $(OBJS) -o main

# Clean target
clean:
	@echo "Cleaning up build files..."
	rm -f $(OBJS) main
