global base10_to_base2

section .text

;; Convert a num from base10 to base2
;;
;; 📝 NOTE: dest buffer (`rsi`) should be 65 bytes (64 + 1), a num can only
;; be 64 bytes long, and one is for null terminator to break the line while
;; printing
;;
;; args,
;; - rdi -> input number
;; - rsi -> pointer to buf to store the binary (should be atleast 65 bytes)
;;
;; ret,
;; - rbx -> len of string stored in buf pointed by `rsi`
;; - rax -> `1` on error `0` if everything is good
base10_to_base2:
  xor rbx, rbx
  xor rax, rax

  ;; check if input num == 0 or is -ve
  cmp rdi, 0x00
  jz .zero
  jl .err
.loop:
  ;; check for buffer overflow, buf size should be `>= 64`
  cmp rbx, 64
  jg .err

  xor rdx, rdx                  ; clear rdx for division
  mov rax, rdi                  ; load the current num (dividend)
  mov rcx, 0x02                 ; need to div by `2`
  div rcx                       ; divide `rax` by `rcx`, quotient in rax, remainder in rdx

  ;; rdx now holds '0' or '1',
  add rdx, '0'                  ; convert rdx into ascii from num, `itoa`
  mov [rsi + rbx], dl

  inc rbx                       ; increment buf pointer

  ;; update `rdi` w/ quotient
  mov rdi, rax

  ;; repeat loop till `rdi == 0`
  test rdi, rdi
  jz .loop_done

  jmp .loop                     ; continue the loop
.loop_done:
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
  mov al, [rsi + rdx]           ; lower bytes of `rax`
  mov cl, [rsi + rbx]           ; lower bytes of `rcx`
  mov [rsi + rdx], cl
  mov [rsi + rbx], al

  inc rdx
  dec rbx

  jmp .reverse_loop
.done_rev_loop:
  mov rbx, r8                   ; load the saved len of buffer
  jmp .done
.zero:
  ;; as input is "0",
  ;; output "0" and len "1"
  mov byte [rsi], '0'
  inc rbx
.done:
  ;; add null terminator for newline print
  mov byte [rsi + rbx], 0x0a
  inc rbx

  mov rax, 0x00                 ; no error
  jmp .ret
.err:
  mov rax, 0x01
.ret:
  ret
