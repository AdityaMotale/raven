global _start

section .data
  msg_invalid_args db "Invalid Argument", 0x0a
  msg_invalid_args_len equ $ - msg_invalid_args

  arg_d2b db "d2b"

section .text
_start:
  mov rcx, [rsp]                  ; read `argc` from stack

  ;; note: `argc` also counts
  ;; application's name
  cmp rcx, 3                      ; user must provide 2 args (cmd + num)
  jne error_args

  ;; read cmd arg from argv
  mov rsi, [rsp + 16]           ; pointer to arg1
  call read_arg

  ;; check if cmd is valid
  ;; currently only `d2b` is valid
  mov r8, rsi
  lea r9, [arg_d2b]
  call match_arg

  ;; check for match errors (rax == 0)
  test rax, rax
  jz error_args

  ;; read num arg from argv
  mov rsi, [rsp + 24]           ; pointer to arg2
  call read_arg

  mov rax, 0x01
  mov rdi, 0x01
  syscall

  jmp exit

;; read arg from `argv`
;;
;; args,
;; - rsi -> pointer to arg in stack
;;
;; ret,
;; - rdx -> len of the arg
read_arg:
  xor rdx, rdx
.count:
  cmp byte [rsi + rdx], 0x00
  je .ret

  inc rdx
  jmp .count
.ret:
  ret

;; match user args with available arg
;;
;; 📝 NOTE: arg len must be 3
;;
;; args,
;; - r8 -> pointer to user arg buf
;; - r9 -> pointer to app arg buf
;;
;; ret,
;; - rax -> 1 if equal otherwise 0
match_arg:
  mov rdx, 0x01                 ; init the counter at `1`
.loop:
  mov al, [r8]
  cmp al, [r9]
  jne .error

  inc r8
  inc r9
  inc rdx

  cmp rdx, 3
  jl .loop
  je .done
.error:
  mov rax, 0
  jmp .ret
.done:
  mov rax, 1
.ret:
  ret

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
