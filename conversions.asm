global base10_to_base2
global base2_to_base10
global u64_to_ascii
global base10_to_base16

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

;; Convert a num from base2 to base10
;;
;; args,
;; - rsi -> pointer to input buf
;; - r8 -> len of input buf
;;
;; ret,
;; - rax -> base10 value or `-1` on err
base2_to_base10:
  xor rax, rax                  ; result
  xor rdx, rdx                  ; current bit
  xor rbx, rbx                  ; index = 0

  ;; validate length (r8 > 0)
  test r8, r8
  jz .err                       ; error if 0
  js .err                       ; error if -ve

  ;; validate upper range (r8 <= 64)
  ;; no more then 64 bits
  cmp r8, 64
  jg .err
.loop:
  cmp rbx, r8
  jge .ret

  mov dl, [rsi + rbx]           ; lower 8 bits of `rdx`

  ;; check for (< 0)
  cmp dl, '0'
  jb .err

  ;; check for (> 1)
  cmp dl, '1'
  ja .err

  sub dl, '0'                   ; now dl = 0 or 1

  shl rax, 1                    ; res *= 2
  add rax, rdx                  ; res += bit

  inc rbx
  jmp .loop
.err:
  mov rax, -1
.ret:
  ret

;; Convert a u64 number to an ascii string
;;
;; args,
;; - rax -> u64 number
;; - rsi -> pointer to out buf
;;
;; ret,
;; - rax -> len of out buf or -1 on err
u64_to_ascii:
  xor r9, r9                  ; index = 0
.loop:
  ;; check for buf overflow, (index <= 20)
  cmp r9, 20
  jg .err

  ;;📝 NOTE: `rax` holds the value to be divided
  xor rdx, rdx                  ; clear for division
  mov rcx, 0x0A                 ; divide by 10
  div rcx                       ; divide `rax` by `rcx`, quotient in `rax`, remainder in `rdx`

  add rdx, '0'                  ; int to ascii, `itoa`
  mov [rsi + r9], dl            ; lower bytes of rdx

  inc r9                        ; increment index

  ;; break loop if `rax == 0`, i.e. the quotient
  test rax, rax
  jz .loop_done

  jmp .loop                     ; continue the loop
.loop_done:
  ;; we've stored digits in reverse order in buf
  ;; now we need to reverse their order,
  ;; here `r9` holds num of digits stored in out buf
  mov rbx, r9
  mov rcx, rbx                   ; loop counter
  xor rdx, rdx                   ; index = 0
  dec rbx                        ; the last index (index - 1)
.rev_loop:
  cmp rdx, rbx
  jge .done

  ;; swap the bytes
  mov al, [rsi + rdx]           ; lower bytes of `rax`
  mov cl, [rsi + rbx]           ; lower bytes of `rcx`
  mov [rsi + rdx], cl
  mov [rsi + rbx], al

  inc rdx
  dec rbx

  jmp .rev_loop
.done:
  ;; add newline in out buf
  mov byte [rsi + r9], 0x0a
  inc r9

  mov rax, r9                   ; size of out buf
  jmp .ret
.err:
  mov rax, -1
.ret:
  ret

;; Convert a base10 num to base16
;;
;; args,
;; rdi -> input base10 number
;; rsi -> pointer to out buf
;;
;; ret,
;; rbx -> size of out buf
;; rax -> `1` on error, `0` otherwise
base10_to_base16:
  xor rbx, rbx                  ; len = 0
  xor rax, rax

  ;; check if input num == 0 or -ve
  test rdi, rdi
  jz .zero                      ; handle zero case
  js .err                       ; error on -ve num
.loop:
  ;; check for buffer overflow, buf size should be `>= 64`
  cmp rbx, 64
  jg .err

  xor   rdx, rdx         ; clear for division
  mov   rax, rdi         ; dividend = current value
  mov   rcx, 16          ; divide by `16`
  div   rcx              ; rax = quotient, rdx = remainder (0–15)

  ;; convert remainder into ASCII
  cmp rdx, 9
  jle .write_digit
  add rdx, 55                   ; 10 -> 'A' (10+55=65), …, 15 -> 'F'
  jmp .write_char
.write_digit:
  add rdx, '0'                  ; convert digit to ascii

  ;; fall through and write char into out buffer
.write_char:
  mov [rsi + rbx], dl           ; store the char
  inc rbx                       ; bump len

  mov rdi, rax                  ; new val = quotient

  ;; repeat loop till (rdi != 0)
  test rdi, rdi
  jnz .loop
.loop_done:
  ;; we've stored digits in reverse order in buffer
  ;; now we need to reverse their order,
  ;; here `rbx` holds num of digits
  mov rcx, rbx                  ; loop counter
  mov r8, rbx                   ; save the len of the buffer
  xor rdx, rdx                  ; index = 0
  dec rcx                       ; rcx = rcx - 1 i.e. the last index
.rev_loop:
  cmp rdx, rcx
  jge .rev_loop_done

  ;; swap the bytes at index `rdx` and `rbx`
  mov al, [rsi + rdx]           ; lower bytes of `rax`
  mov r9b, [rsi + rcx]           ; lower bytes of `rcx`
  mov [rsi + rdx], r9b
  mov [rsi + rcx], al

  inc rdx
  dec rcx

  jmp .rev_loop
.rev_loop_done:
  mov rbx, r8                   ; restore len
  jmp .done
.zero:
  mov byte [rsi], '0'
  inc rbx
.done:
  ;; add null terminator for newline print
  mov byte [rsi + rbx], 0x0A
  inc rbx

  xor rax, rax                 ; no error
  jmp .ret
.err:
  mov rax, 1                    ; err code
.ret:
  ret
