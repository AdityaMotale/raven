global parse_base10
global parse_base2
global parse_base16

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

;; parse a base16 number from terminal args
;;
;; 📝 NOTE: input hex num should be <= 64 digits
;;
;; args,
;; - r8  -> pointer to arg string on stack
;; - rsi -> pointer to input buffer
;;
;; ret,
;; - rax -> number of bytes stored in input buffer,
;;         -1 on invalid input
parse_base16:
    xor   rax, rax            ; count = 0
.parse_loop:
    movzx rcx, byte [r8 + rax]
    cmp   cl, 0
    je    .done               ; end of string

    ;;--- digit? 0–9 ---
    cmp   cl, '0'
    jl    .check_lower        ; below '0' → not a digit
    cmp   cl, '9'
    jle   .store_digit        ; '0'–'9'
.check_lower:
    ;;--- lowercase hex? a–f ---
    cmp   cl, 'a'
    jl    .check_upper        ; below 'a'
    cmp   cl, 'f'
    jle   .store_lower        ; 'a'–'f'
.check_upper:
    ;;--- uppercase hex? A–F ---
    cmp   cl, 'A'
    jl    .error              ; below 'A'
    cmp   cl, 'F'
    jle   .store_upper        ; 'A'–'F'
.error:
    mov   rax, -1
    ret
.store_digit:
    mov   [rsi + rax], cl     ; keep '0'–'9'
    jmp   .advance
.store_lower:
    sub   cl, 32              ; 'a'–'f' → 'A'–'F'
    mov   [rsi + rax], cl
    jmp   .advance
.store_upper:
    mov   [rsi + rax], cl     ; keep 'A'–'F'
.advance:
    inc   rax
    cmp   rax, 64
    jge   .error              ; too many digits
    jmp   .parse_loop
.done:
    ret
