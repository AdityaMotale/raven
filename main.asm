global main

;; utils (`utils.asm`)
extern match_buffers
extern read_arg
extern print

;; parsers (`parser.asm`)
extern parse_base10

;; conversions (`conversions.asm`)
extern base10_to_base2

;; help commands (`help_commands.c`)
extern print_commands

section .data
  msg_invalid_args db "Invalid Arguments", 0x0a
  msg_invalid_args_len equ $ - msg_invalid_args

  arg_d2b db "d2b"

section .bss
  ;; result buffer for d2b
  d2b_res_buf resb 65           ; 64 bits + 1 null terminator

  ;; input buffer for b2d
  b2d_inp_buf resb 65           ; (64 + 1) input binary num should be max 64 bytes

section .text
main:
  ;; print help cmds if no arg's are provided
  cmp rdi, 0x01
  jle help_cmds

  ;; note: `argc` stored in `rdi` also counts
  ;; application's name
  cmp rdi, 0x03                 ; user must provide 2 args (cmd + input)
  jne error_args

  ;; store pointer to list pointers to args
  ;; which is stored in `rsi` by default
  mov rcx, rsi

  ;; check if cmd is valid
  ;; currently only `d2b` is valid
  mov r8, [rcx + 8]
  lea r9, [arg_d2b]
  mov r10, 0x03                 ; max len allowed for cmd
  call match_buffers

  ;; check for match errors (rax == 0)
  test rax, rax
  jz error_args

  ;; parse int from ascii
  mov r8, [rcx + 16]
  call parse_base10

  ;; check for parse errors (rax == -1)
  test rax, rax
  js error_args

  ;; convert num to binary
  mov rdi, rax                  ; rax holds the parse num
  lea rsi, [d2b_res_buf]
  call base10_to_base2

  ;; print the binary num
  lea rsi, [d2b_res_buf]
  mov rdx, rbx
  call print

  jmp exit

help_cmds:
  call print_commands
  jmp exit

error_args:
  mov rax, 0x01
  mov rdi, 0x01
  lea rsi, [msg_invalid_args]
  mov rdx, msg_invalid_args_len
  syscall

  jmp error_exit

error_exit:
  mov rax, 0x3c
  mov rdi, 0x01
  syscall

exit:
  mov rax, 0x3c
  mov rdi, 0x00
  syscall
