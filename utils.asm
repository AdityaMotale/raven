global parse_base10
global match_buffers
global read_arg
global print

section .text

;; print a buf to `stdout`
;;
;; args,
;; - rsi -> pointer to buffer
;; - rdx -> buffer len
;;
;; ret,
;; - rax -> no. of bytes written, -ve value on error
print:
  mov rax, 0x01
  mov rdi, 0x01
  syscall

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

;; parse a base10 number from terminal args
;;
;; 📝 NOTE: negitive nums are not supported
;;
;; args,
;; - r8 -> pointer to arg on stack
;;
;; ret,
;; - rax -> decimal value or -1 on error
parse_base10:
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

;; match two buffers to check if they are equal
;;
;; args,
;; - r8 -> pointer to user arg buf
;; - r9 -> pointer to app arg buf
;; - r10 -> max len allowed
;;
;; ret,
;; - rax -> `1` if equal else `0`
match_buffers:
  mov rdx, 0x01                 ; init the counter at `1`
.loop:
  mov al, [r8]
  cmp al, [r9]
  jne .not_equal

  inc r8
  inc r9
  inc rdx

  cmp rdx, r10
  jl .loop
  je .equal
.not_equal:
  mov rax, 0x00
  jmp .ret
.equal:
  mov rax, 0x01
.ret:
  ret
