.model small
.stack 100h
.data
menu_msg db 0dh, 0ah, 'Select an option:', 0dh, 0ah
db '1) +', 0dh, 0ah
db '2) -', 0dh, 0ah
db '3) *', 0dh, 0ah
db '4) /', 0dh, 0ah
db '5) Exit', 0dh, 0ah
db 'Enter choice (1-5): $'
prompt1 db 0dh, 0ah, 'Enter first number (00-99): $'
prompt2 db 0dh, 0ah, 'Enter second number (00-99): $'
add_msg db 0dh, 0ah, 'The Result of addition is = $'
sub_msg db 0dh, 0ah, 'The Result of subtraction is = $'
mul_msg db 0dh, 0ah, 'The Result of multiplication is = $'
div_msg db 0dh, 0ah, 'The Result of division is = $'
error_msg db 0dh, 0ah, 'Error: Invalid input or division by zero$'
num1 db 0
num2 db 0
operator db 0
result dw 0

.code
main proc
mov ax, @data
mov ds, ax

main_loop:
; Display menu
call display_menu

; Read operation choice (1-5)
mov ah, 01h
int 21h
cmp al, '1'
je set_add
cmp al, '2'
je set_sub
cmp al, '3'
je set_mul
cmp al, '4'
je set_div
cmp al, '5'
je exit
jmp error ; Invalid choice

set_add:
mov operator, '+'
jmp read_inputs
set_sub:
mov operator, '-'
jmp read_inputs
set_mul:
mov operator, '*'
jmp read_inputs
set_div:
mov operator, '/'
jmp read_inputs

read_inputs:
; Prompt and read first number
mov ah, 09h
lea dx, prompt1
int 21h
call read_number
cmp al, 0ffh
je error
mov num1, al

; Prompt and read second number
mov ah, 09h
lea dx, prompt2
int 21h
call read_number
cmp al, 0ffh
je error
mov num2, al

; Perform calculation
mov al, num1
mov bl, num2
cmp operator, '+'
je do_add
cmp operator, '-'
je do_sub
cmp operator, '*'
je do_mul
cmp operator, '/'
je do_div
jmp error

do_add:
add al, bl
mov ah, 0
mov result, ax
lea dx, add_msg
jmp show_result

do_sub:
sub al, bl
cbw                ; Sign-extend AL into AX for negative results
mov result, ax
lea dx, sub_msg
jmp show_result

do_mul:
mov ah, 0
mul bl
mov result, ax
lea dx, mul_msg
jmp show_result

do_div:
cmp bl, 0
je error
mov ah, 0
div bl
mov result, ax
lea dx, div_msg
jmp show_result

error:
mov ah, 09h
lea dx, error_msg
int 21h
jmp main_loop

show_result:
mov ah, 09h
int 21h
mov ax, result
call display_number
jmp main_loop

exit:
mov ah, 4ch
int 21h
main endp

; Display menu
display_menu proc
mov ah, 09h
lea dx, menu_msg
int 21h
ret
display_menu endp

; Read two-digit number
read_number proc
push bx
push cx
mov ah, 01h
int 21h
sub al, '0'
cmp al, 9
ja invalid
mov bl, al
mov cl, 10
mul cl
mov bh, al
mov ah, 01h
int 21h
sub al, '0'
cmp al, 9
ja invalid
add al, bh
jmp done
invalid:
mov al, 0ffh
done:
pop cx
pop bx
ret
read_number endp

; Display number
display_number proc
push ax
push bx
push cx
push dx
mov ax, [result]
cmp ax, 0
jge positive
mov ah, 02h
mov dl, '-'
int 21h
neg ax
positive:
mov bx, 10
mov cx, 0
convert:
mov dx, 0
div bx
push dx
inc cx
cmp ax, 0
jne convert
display:
pop dx
add dl, '0'
mov ah, 02h
int 21h
loop display
pop dx
pop cx
pop bx
pop ax
ret
display_number endp

end main