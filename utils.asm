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
