global main

section .data
  msg_invalid_args db "Invalid Argument", 0x0a
  msg_invalid_args_len equ $ - msg_invalid_args

  arg_d2b db "d2b"

extern print_commands

section .bss
  d2b_buf resb 65               ; 64 bits + 1 null terminator

section .text
main:
  ;; print help cmds if no arg's are provided
  cmp rdi, 1
  jle help_cmds

  ;; note: `argc` stored in `rdi` also counts
  ;; application's name
  cmp rdi, 3                      ; user must provide 2 args (cmd + input)
  jne error_args

  ;; store pointer to list pointers to args
  mov rcx, rsi

  ;; read cmd arg from argv
  ;; 📝 NOTE: First arg is app's name
  mov rsi, [rcx + 8]           ; pointer to arg1
  call read_arg

  ;; check if cmd is valid
  ;; currently only `d2b` is valid
  mov r8, rsi
  lea r9, [arg_d2b]
  call match_arg

  ;; check for match errors (rax == 0)
  test rax, rax
  jz error_args

  ;; parse int from ascii
  mov r8, [rcx + 16]
  call parse_num

  ;; convert num to binary
  mov rdi, rax                  ; rax holds the parse num
  lea rsi, [d2b_buf]
  call num_to_binary

  ;; print the binary num
  mov rax, 0x01
  mov rdi, 0x01
  lea rsi, [d2b_buf]
  mov rdx, rbx
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

;; parse a decimal num from arg2
;;
;; 📝 NOTE: -ve nums are not supported
;;
;; args,
;; - r8 -> pointer to arg on stack
;;
;; ret,
;; - rax -> decimal value or -1 on error
parse_num:
  xor rax, rax
.loop:
  ;; read the next char from the buf
  movzx rcx, byte [r8]

  ;; check for null terminator
  cmp cl, 0x00
  je .ret

  ;; check for a valid digit (must be > '0' and < '9')
  cmp cl, '0'
  jl .err

  cmp cl, '9'
  jg .err

  ;; conver ascii to int `atoi`
  sub cl, '0'

  imul rax, 10             ; rax = rax * 10

  add rax, rcx
  inc r8

  jmp .loop
.err:
  mov rax, -1
.ret:
  ret

;; Convert num to binary string
;;
;; args,
;; - rdi -> input number
;; - rsi -> pointer to buf to store the binary (should be atleast 65 bytes)
;;
;; ret,
;; - rbx -> len of string
num_to_binary:
  xor rbx, rbx

  ;; check if input num == 0
  cmp rdi, 0
  jne .loop

  ;; if num == 0, output "0" and len "1"
  mov byte [rsi], '0'
  inc rbx
  jmp .ret
.loop:
  xor rdx, rdx                  ; clear rdx for division
  mov rax, rdi                  ; load the current num (dividend)
  mov rcx, 2
  div rcx                       ; divide `rax` by `rcx`, quotient in rax, remainder in rdx

  ;; rdx now holds '0' or '1',
  add rdx, '0'                  ; convert rdx into ascii from num, `itoa`
  mov [rsi + rbx], dl

  inc rbx                       ; increment buf pointer

  ;; update `rdi` w/ quotient
  mov rdi, rax

  ;; repeat loop till `rdi == 0`
  test rdi, rdi
  jz .done

  jmp .loop                     ; continue the loop
.done:
  ;; we've stored digits in reverse order in buffer
  ;; now we need to reverse their order,
  ;; here `rbx` holds num of digits
  mov rcx, rbx                  ; loop counter
  mov r8, rbx                   ; save the len of the buffer
  xor rdx, rdx                  ; index = 0
  dec rbx                       ; rcx = rcx - 1 i.e. the last index
.reverse_loop:
  cmp rdx, rbx
  jge .done_rev_loop

  ;; swap the bytes at index `rdx` and `rbx`
  mov al, [rsi + rdx]
  mov cl, [rsi + rbx]
  mov [rsi + rdx], cl
  mov [rsi + rbx], al

  inc rdx
  dec rbx

  jmp .reverse_loop
.done_rev_loop:
  mov rbx, r8                   ; load the saved len of buffer
.ret:
  ret

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
