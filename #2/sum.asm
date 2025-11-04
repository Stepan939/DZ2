section .data
    prompt1 db "Enter first number: ", 0
    prompt1_len equ $ - prompt1

    prompt2 db "Enter second number: ", 0
    prompt2_len equ $ - prompt2

    result_msg db "Sum = ", 0
    result_len equ $ - result_msg

    newline db 10

section .bss
    num1 resb 16       ; буфер для ввода первого числа
    num2 resb 16       ; буфер для второго числа
    sum_str resb 16    ; буфер для вывода суммы

section .text
    global _start


;  Читать число (строкой) и перевести в int
;  вход: rsi = адрес буфера
;  выход: rax = значение числа

read_number:
    mov rax, 0          
    mov rdi, 0
    mov rdx, 16
    syscall

    mov rbx, 0          ; результат
    mov rcx, rsi        ; указатель на строку
    mov r8, 1           ; знак = 1 (положительный)

    mov al, [rcx]
    cmp al, '-'
    jne parse_digits
    mov r8, -1          ; отрицательное число
    inc rcx

parse_digits:
    xor rax, rax        ; обнуляем rax перед циклом преобразования символов.
.convert_loop:
    mov al, [rcx]
    cmp al, 10          ; '\n'
    je .done
    cmp al, 0
    je .done
    sub al, '0'         ; превращаем символ в цифру 
    imul rbx, 10        ; умножаем на 10
    add rbx, rax        ; добавляем цифру
    inc rcx             ; переходим к следующему символу
    jmp .convert_loop

.done:
    imul rbx, r8        ; умножаем на знак
    mov rax, rbx        ; возвращаем результат в RAX
    ret


;  Печать числа из RAX

print_number:
    mov rbx, 10
    mov rcx, sum_str + 15  ; указатель на конец буфера
    mov byte [rcx], 0
;проверяем знак числа
    cmp rax, 0
    jge .positive
    neg rax
    mov r8b, '-'
    mov r9b, 1
    jmp .convert
;плаг: нет минуса
.positive:
    mov r9b, 0
;проверяем случай, когда число = 0
.convert:
    cmp rax, 0
    je .check_zero
;формируем строку числа, записывая цифры в буфер справа налево
.loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .loop
;если было отрицательное — добавляем '-' перед числом
    cmp r9b, 1
    jne .print
    dec rcx
    mov [rcx], r8b
    jmp .print
;обработка случая 0
.check_zero:
    dec rcx
    mov byte [rcx], '0'
;выводим готовую строку на экран.
.print:
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, sum_str + 16
    sub rdx, rcx
    syscall
    ret


_start:
    ; Ввод первого числа
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 16
    syscall

    mov rsi, num1
    call read_number
    mov rbx, rax        ; сохранить первое число

    ; Ввод второго числа
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 16
    syscall

    mov rsi, num2
    call read_number
    add rax, rbx        ; rax = num1 + num2

    ; Вывод результата
    mov rbx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_len
    syscall

    mov rax, rbx
    call print_number

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall


