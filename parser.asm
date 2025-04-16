global parse_base10
global parse_base2

section .text

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
  jb .err
  cmp cl, '9'
  ja .err

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

;; parse a base2 number from terminal args
;;
;; 📝 NOTE: input binary num should be <= 64 bytes
;;
;; args,
;; - r8 -> pointer to arg on stack
;; - rsi -> pointer to input buffer
;;
;; ret,
;; - rax -> no. of bytes stored in input buffer,
;;         -1 on invalid input
parse_base2:
  xor rax, rax                  ; init `rax` at 0
.loop:
  ;; read the next char from the buf
  movzx rcx, byte [r8 + rax]

  ;; check for null terminator
  cmp cl, 0x00
  je .ret

  ;; validate input byte (must be either 0 or 1)
  cmp cl, '0'
  je .handle_0
  cmp cl, '1'
  je .handle_1

  jmp .err                      ; if input is nither 0 nor 1
.handle_0:
  mov byte [rsi + rax], '0'
  jmp .next
.handle_1:
  mov byte [rsi + rax], '1'
.next:
  inc rax

  ;; check for buffer overflow
  cmp rax, 64
  jge .err

  jmp .loop
.err:
  mov rax, -1
.ret:
  ret
