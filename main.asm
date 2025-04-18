global main

;; utils (`utils.asm`)
extern match_buffers
extern read_arg
extern print

;; parsers (`parser.asm`)
extern parse_base10
extern parse_base2
extern parse_base16

;; conversions (`conversions.asm`)
extern base10_to_base2
extern base2_to_base10
extern u64_to_ascii
extern base10_to_base16
extern base16_to_base10

;; help commands (`help_commands.c`)
extern print_commands

section .data
  msg_invalid_args db "Invalid Arguments", 0x0a
  msg_invalid_args_len equ $ - msg_invalid_args

  buf_d2b db "d2b"
  buf_b2d db "b2d"
  buf_d2h db "d2h"
  buf_h2d db "h2d"

section .bss
  ;; 64 bits + 1 null terminator
  out_buf resb 65
  inp_buf resb 65

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
  mov r11, [rcx + 8]

  ;; max len allowed for cmd
  mov r10, 0x03

  ;; match w/ `d2b`
  lea r9, [buf_d2b]
  mov r8, r11
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_d2b

  ;; match w/ `b2d`
  lea r9, [buf_b2d]
  mov r8, r11
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_b2d

  ;; match w/ `d2h`
  lea r9, [buf_d2h]
  mov r8, r11
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_d2h

  ;; match w/ `h2d`
  lea r9, [buf_h2d]
  mov r8, r11
  call match_buffers

  ;; check if buffers match (rax == 0)
  test rax, rax
  jz cmd_h2d

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
  lea rsi, [out_buf]
  call base10_to_base2          ; returns `rax` (error state), `rbx` (len of buf)

  ;; check for conversion error (rax == 1)
  test rax, rax
  jnz error_args

  ;; print the result
  lea rsi, [out_buf]
  mov rdx, rbx
  call print

  jmp exit

;; handle `b2d` command
cmd_b2d:
  ;; parse user provided base2 num
  mov r8, [rcx + 16]
  lea rsi, [inp_buf]        ; buf to store users input
  call parse_base2              ; returns `rax` (no. of bytes written in buf)

  ;; check for parse errors
  test rax, rax
  js error_args

  ;; convert base2 to base10
  lea rsi, [inp_buf]       ; pointer to input buf
  mov r8, rax                  ; size of input buf
  call base2_to_base10         ; returns `rax` (base10 number)

  ;; check for conversions error (rax == -1)
  test rax, rax
  js error_args

  ;; convert u64 (base10) to ascii
  lea rsi, [out_buf]
  call u64_to_ascii             ; returns `rax` (size of out buf)

  ;; print the result
  lea rsi, [out_buf]
  mov rdx, rax
  call print

  jmp exit

;; handle `d2h` cmd
cmd_d2h:
  ;; parse user provided base10 num
  mov r8, [rcx + 16]
  call parse_base10             ; returns `rax` (parsed base10 value)

  ;; check for parse errors (rax == -1)
  test rax, rax
  js error_args

  ;; convert base10 to base16
  lea rsi, [out_buf]
  mov rdi, rax
  call base10_to_base16         ; returns `rax` (error status), `rbx` (size of out buf)

  ;; check for conversion error (rax == 1)
  test rax, rax
  jnz error_args

  ;; print the result
  lea rsi, [out_buf]
  mov rdx, rbx
  call print

  jmp exit

;; handle `h2d` cmd
cmd_h2d:
  ;; parse user provided base16 num
  mov r8, [rcx + 16]
  lea rsi, [inp_buf]
  call parse_base16

  ;; check for parse errors
  test rax, rax
  js error_args

  ;; convert base2 to base10
  lea rsi, [inp_buf]       ; pointer to input buf
  mov r8, rax              ; size of input buf
  call base16_to_base10    ; returns `rax` (base10 number)

  ;; check for conversions error (rax == -1)
  test rax, rax
  js error_args

  ;; convert u64 (base10) to ascii
  lea rsi, [out_buf]
  call u64_to_ascii             ; returns `rax` (size of out buf)

  ;; print the result
  lea rsi, [out_buf]
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
