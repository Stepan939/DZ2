section .data
    prompt db "Enter your string (max 100 chars): ", 0
    prompt_len equ $ - prompt
    result db "Reversed: ", 0
    result_len equ $ - result
    newline db 10
    
    error_msg db "Error: String too long!", 0
    error_len equ $ - error_msg

section .bss
    buffer resb 101       ; 100 символов + 1 для символа новой строки
    reversed resb 101     ; 100 символов + 1 для нулевого терминатора

section .text
    global _start

_start:
    ; ВВОД 
    mov rax, 1            
    mov rdi, 1            
    mov rsi, prompt       
    mov rdx, prompt_len           
    syscall

    ;  ЧТЕНИЕ СТРОКИ 
    mov rax, 0            
    mov rdi, 0            
    mov rsi, buffer       
    mov rdx, 101          
    syscall

    ;  ПРОВЕРКА ДЛИНЫ 
    cmp rax, 101          
    jge too_long          

    ;  ПОДГОТОВКА К РАЗВОРОТУ 
    mov r8, rax           ; сохраняем длину в R8
    cmp r8, 1             ; проверяем пустую строку
    jle empty_string      ; если длина <= 1, строка пустая

    dec r8                ; убираем символ новой строки \n
    mov r9, 0             ; индекс для развернутой строки
    mov rcx, r8           ; счетчик цикла

    ;  ЦИКЛ РАЗВОРОТА СТРОКИ 
reverse_loop:
    dec r8                ; двигаемся с конца исходной строки
    mov al, [buffer + r8] ; берем символ из конца
    mov [reversed + r9], al ; записываем в начало развернутой
    inc r9                ; увеличиваем индекс развернутой строки
    loop reverse_loop     ; повторяем пока RCX > 0

    ;  НУЛЕВОЙ ТЕРМИНАТОР 
    mov byte [reversed + r9], 0

    ;  ВЫВОД РЕЗУЛЬТАТА 
    mov rax, 1           
    mov rdi, 1           
    mov rsi, result       
    mov rdx, 10           
    syscall

    mov rax, 1            
    mov rdi, 1            
    mov rsi, reversed     
    mov rdx, r9           
    syscall

    ;  ВЫВОД ПЕРЕВОДА СТРОКИ 
    mov rax, 1           
    mov rdi, 1           
    mov rsi, newline      
    mov rdx, 1            
    syscall

    jmp exit_program      
too_long:
    ;  ОБРАБОТКА ОШИБКИ - СЛИШКОМ ДЛИННАЯ СТРОКА 
    mov rax, 1            
    mov rdi, 1           
    mov rsi, error_msg   
    mov rdx, error_len          
    syscall
    jmp exit_program

empty_string:
    ;  ПУСТАЯ СТРОКА 
    mov rax, 1            
    mov rdi, 1            
    mov rsi, result       
    mov rdx, result_len        
    syscall

    mov rax, 1            
    mov rdi, 1            
    mov rsi, newline      
    mov rdx, 1            
    syscall

exit_program:
    mov rax, 60           
    mov rdi, 0            
    syscall

