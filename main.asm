global main

;; utils (`utils.asm`)
extern match_buffers
extern read_arg
extern print

;; parsers (`parser.asm`)
extern parse_base10
extern parse_base2

;; conversions (`conversions.asm`)
extern base10_to_base2
extern base2_to_base10
extern u64_to_ascii

;; help commands (`help_commands.c`)
extern print_commands

section .data
  msg_invalid_args db "Invalid Arguments", 0x0a
  msg_invalid_args_len equ $ - msg_invalid_args

  buf_d2b db "d2b"
  buf_b2d db "b2d"

section .bss
  ;; result buffer for d2b
  d2b_res_buf resb 65           ; 64 bits + 1 null terminator

  ;; buffers for b2d
  b2d_inp_buf resb 64            ; input binary num should be max 64 bits
  b2d_out_buf resb 21            ; (20 + 1) 20 bytes for u64 num

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

  jmp match_cmds

;; match user's cmd with available cmds
;;
;; available cmds,
;; - d2b
;; - b2d
match_cmds:
  ;; pointer to user's cmd
  mov r8, [rcx + 8]

  ;; max len allowed for cmd
  mov r10, 0x03

  ;; match w/ `d2b`
  lea r9, [buf_d2b]
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_d2b

  ;; match w/ `b2d`
  lea r9, [buf_b2d]
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_b2d

  ;; show unknown arg err if not matched with any cmds
  jmp error_args

;; handle `d2b` command
cmd_d2b:
  ;; parse user provided base10 num
  mov r8, [rcx + 16]
  call parse_base10

  ;; check for parse errors (rax == -1)
  test rax, rax
  js error_args

  ;; convert base10 to base2
  mov rdi, rax                  ; `rax` holds parsed base10 value
  lea rsi, [d2b_res_buf]
  call base10_to_base2          ; returns `rax` (error state), `rbx` (len of buf)

  ;; check for conversion error (rax == 1)
  test rax, rax
  jnz error_args

  ;; print the result
  lea rsi, [d2b_res_buf]
  mov rdx, rbx
  call print

  jmp exit

;; handle `b2d` command
cmd_b2d:
  ;; parse user provided base2 num
  mov r8, [rcx + 16]
  lea rsi, [b2d_inp_buf]        ; buf to store users input
  call parse_base2              ; returns `rax` (no. of bytes written in buf)

  ;; check for parse errors
  test rax, rax
  js error_args

  ;; convert base2 to base10
  lea rsi, [b2d_inp_buf]       ; pointer to input buf
  mov r8, rax                  ; size of input buf
  call base2_to_base10         ; returns `rax` (base10 number)

  ;; check for conversions error (rax == -1)
  test rax, rax
  js error_args

  ;; convert u64 (base10) to ascii
  lea rsi, [b2d_out_buf]
  call u64_to_ascii             ; returns `rax` (size of out buf)

  ;; print the result
  lea rsi, [b2d_out_buf]
  mov rdx, rax
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
