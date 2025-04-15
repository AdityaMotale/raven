global parse_base10

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
