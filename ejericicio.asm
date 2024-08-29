; Basic input / output example using irvine32.inc

include irvine32.inc

.data
a dd ?
b dd ?
msg1 BYTE "Enter 1st number: ", 0
msg2 BYTE "Enter 2nd number: ", 0
msg3 BYTE "The result is: ", 0
result dd ?
.code

main PROC
; For print string we can use "writestring"
mov edx, offset msg1
call writestring

; For user input, we use "readint"
call readint
mov a, eax

mov edx, offset msg2
call writestring

call readint
mov b, eax

mov eax, a
mov ebx, b
mul ebx
mov result, eax

; "crlf" means "CR" "Carriage Return" (Retorno de carro) and "LF" "Line Feed" (salto de línea).
call crlf

mov edx, offset msg3
call writestring

; We use "writeint" to print numbers
mov eax, result
call writeint

call crlf


exit
main endP
end main