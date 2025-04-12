global _start

section .text
_start:
  mov rsi, [rsp + 16]           ; pointer to arg1

  xor rdx, rdx
.count_len:
  cmp byte [rsi + rdx], 0x00
  je .print_arg
  inc rdx
  jmp .count_len
.print_arg:
  mov rax, 0x01
  mov rdi, 0x01
  syscall
.exit:
  mov rax, 0x3c
  mov rdi, 0x00
  syscall
