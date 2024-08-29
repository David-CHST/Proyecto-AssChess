; Proyecto de Arquitectura de Computadoras
; David Molina Guerrero

include irvine32.inc
include Macros.inc

.data
	; ##########################
	; Códigos ASCII de cada pieza
	; 7Bh 7Dh |  {  }    Knight
	; 5Bh 5Dh |  [  ]    Tower
	; 28h 29h |  (  )    Bishop

	; 20h Espacio Vacio // ALT 22h o 27h o 3Ah

	; 2Bh 2Ah  |  + *  King
	; 26h 24h  |  & $ Queen
	; 3Ch 3Eh  |  < >  Pawn

	; ##########################

	; - Lógica de cada pieza -
	; 2Bh y 2Ah | King: No puede tener diferencia de indices mayor a 1
	; 26h y 24h | Queen: Bishop + Tower
	; 28h y 29h | Bishop: diferencia de indices deben ser números iguales
	; 7Bh y 7Dh | Knight: La suma (unsigned) de distancia debe ser 3 cuadros, no pueden ser el mismo número ni pueden ser 3 o 0 la diferencia de indices del movimiento  
	; 5Bh y 5Dh | Tower: Mismo indice en X o Y // Diferencia de indices 0 en alguno de los dos ejes.
	; 3Eh | Pawn Blanca: Diferencia de indices positivo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en positivo
	; 3Ch | Pawn Negra: Diferencia de indices negativo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en negativo

	; - Generalidades -
	; Superior Izquierda 5Bh = indice [0,0] = A1
	; Inferior derecha 5Dh = indice [7,7] = H8
	; Ninguna pieza puede tener coordenada -1 ni 8
	; Todas las piezas deben cruzar exitosamente su camino sin cruzar espacios ocupados, salvo los Knight

	; ##########################

	Tablero BYTE 5Bh, 28h, 7Bh, 26h, 2Bh, 7Bh, 28h, 5Bh,  0
	        BYTE 3Ch, 3Ch, 3Ch, 3Ch, 3Ch, 3Ch, 3Ch, 3Ch,  0
	        BYTE 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h,  0
            BYTE 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h,  0
		    BYTE 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h,  0
		    BYTE 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h,  0
		    BYTE 3Eh, 3Eh, 3Eh, 3Eh, 3Eh, 3Eh, 3Eh, 3Eh,  0
		    BYTE 5Dh, 29h, 7Dh, 24h, 2Ah, 7Dh, 29h, 5Dh,  0

	; ##########################

	ColorJugador SDWORD 0
	MovidaExisteEnTablero SDWORD 0
	PiezaExisteEnTablero SDWORD 0
	MovidaEsPosible SDWORD 0
	PiezaX SDWORD 0
	PiezaY SDWORD 0
	MovidaX SDWORD 0
	MovidaY SDWORD 0
	DiferenciaX SDWORD 0
	DiferenciaY SDWORD 0
	DiferenciaAbsX SDWORD 0 ; Se usan variables sin signo para valores absolutos
	DiferenciaAbsY DWORD 0 ; Se usan variables sin signo para valores absolutos
	PiezaMovida SDWORD 0
	PiezaAtacada SDWORD 0

	; ### DEBUG
	msg1 BYTE "-num-", 0
	msg2 BYTE "-minuscula-", 0
	msg3 BYTE "-saliendo-", 0
	msg4 BYTE "-valido-", 0

	; ##########################

.code

; ## PROCEDURES necesarios

; main PROC // contiene el código principal que se ejecuta
; recibirPieza PROC // Recibe y guarda variables de pieza de inicio y el movimiento deseado, según los datos define si MovidaExisteEnTablero
; limpiarRegistros PROC // Limpia todos los registros en uso
; realizarMovimiento PROC // Convierte el espacio anterior en vacio y el actual en la pieza seleccionada
; validarMovimiento<TIPOPIEZA> PROC // Múltiples procedimientos encargados de validar las reglas especificas según el tipo de pieza del macro
; validarCaminoPieza PROC // NO APLICA A KNIGHT, recorre el camino entre el inicio y el destino de la pieza para verificar que es un movimiento posible
; obtenerDiferenciaIndices PROC // Resta la coordenada de la pieza con la coordenada del movimiento indicado para obtener 1 diferencia en eje X y 1 diferencia en eje Y
; printTablero PROC // Se ejecuta cada vez que se actualiza el tablero
; manejarDestino PROC // Revisa el destino de la pieza y en caso de haber pieza enemiga se consume y se almacena, en caso de ser pieza aliada cancela el movimiento
; obtenerTipoPieza PROC // Establece una variable con el tipo de pieza que existe en ese cuadro


limpiarRegistros PROC
	xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
	ret
limpiarRegistros ENDP

limpiarVariables PROC
	mov PiezaExisteEnTablero, 0
	mov MovidaExisteEnTablero, 0
	mov MovidaEsPosible, 0
	mov PiezaX, 0
	mov PiezaY, 0
	mov MovidaX, 0
	mov MovidaY, 0
	mov DiferenciaX, 0
	mov DiferenciaY, 0
	mov DiferenciaAbsX, 0
	mov DiferenciaAbsY, 0
	mov PiezaMovida, 0
	mov PiezaAtacada, 0
	ret
limpiarVariables ENDP

recibirPieza PROC
	cicloInputLetra:
		call ReadChar
		call WriteChar
		xor ah, ah
		cmp al, 41h
		jl salir ; JUMP IF LESS
		cmp al, 48h
		jg verMinuscula
		sub al, 41h
		mov PiezaX, eax
		jmp cicloInputNum
	verMinuscula:
		mov edx, offset msg2
		call writestring
		cmp al, 61h
		jl salir
		cmp al, 68h
		jg salir
		sub al, 61h
		mov PiezaX, eax
		jmp cicloInputNum
	cicloInputNum:
		call limpiarRegistros
		call ReadChar
		call WriteChar
		xor ah, ah
		cmp al, 31h
		jl salir ; JUMP IF LESS
		cmp al, 38h
		jg salir
		sub al, 31h
		mov PiezaY, eax
		jmp PiezaExiste
	PiezaExiste:
		mov edx, offset msg4
		call writestring
		mov PiezaExisteEnTablero, 1
	salir:
		mov edx, offset msg3
		call writestring
	ret
recibirPieza ENDP

recibirMovimiento PROC
	cicloInputLetra:
		call ReadChar
		call WriteChar
		cmp al, 41h
		jl salir
		cmp al, 48h
		jg verMinuscula
		sub al, 41h
		mov MovidaX, eax
		jmp cicloInputNum
	verMinuscula:
		mov edx, offset msg2
		call writestring
		cmp al, 61h
		jl salir
		cmp al, 68h
		jg salir
		sub al, 61h
		mov MovidaX, eax
		jmp cicloInputNum
	cicloInputNum:
		call limpiarRegistros
		call ReadChar
		call WriteChar
		cmp al, 31h
		jl salir
		cmp al, 38h
		jg salir
		sub al, 31h
		mov MovidaY, eax
		jmp MovidaExiste
	MovidaExiste:
		mov edx, offset msg4
		call writestring
		mov MovidaExisteEnTablero, 1
	salir:
		mov edx, offset msg3
		call writestring
	ret
recibirMovimiento ENDP

; Fácilmente la función más importante | Se encarga de calcular el desplazamiento entre pieza seleccionada y movimiento seleccionado
; Define las variables de DiferenciaXY y DiferenciaAbsXY, una es con signos negativos otra sin signos negativos.
obtenerDiferenciaIndices PROC
	call limpiarRegistros
	mov ebx, MovidaX
	mov DiferenciaX, ebx
	mov edx, PiezaX
	sub DiferenciaX, edx
	call limpiarRegistros
	mov ebx, MovidaY
	mov DiferenciaY, ebx
	mov edx, PiezaX
	sub DiferenciaX, edx
	call limpiarRegistros
	mov ebx, DiferenciaX
	mov edx, DiferenciaY
	mov DiferenciaAbsX, ebx
	mov DiferenciaAbsY, edx
	ret
obtenerDiferenciaIndices ENDP

; King: No puede tener diferencia de indices absolutos mayor a 1 en ningun eje
validarMovimientoKing PROC
	condicionUnoKing:
		cmp DiferenciaAbsX, 1
		jle condicionDosKing
		jmp KingNoValido
	condicionDosKing:
		cmp DiferenciaAbsY, 1
		jle KingValido
		jmp KingNoValido
	KingValido:
		mov MovidaEsPosible, 1
	KingNoValido:
		mov MovidaEsPosible, 0
	ret
validarMovimientoKing ENDP
	
; Queen: Bishop + Tower
validarMovimientoQueen PROC
	ret
validarMovimientoQueen ENDP
	
; Bishop: diferencia de indices deben ser números iguales
validarMovimientoBishop PROC
	ret
validarMovimientoBishop ENDP
	
; Knight: La suma (unsigned) de distancia debe ser 3 cuadros, ningun numero puede ser 3 la diferencia de indices del movimiento  
validarMovimientoKnight PROC
	condicionUnoKnight:
		call limpiarRegistros
		mov ebx, DiferenciaAbsX
		add ebx, DiferenciaAbsY
		cmp bl, 3
		je condicionDosKnight
		jmp KnightNoValido
	condicionDosKnight:
		cmp DiferenciaAbsX, 3
		jne condicionTresKnight
		jmp KnightNoValido
	condicionTresKnight:
		cmp DiferenciaAbsY, 3
		jne KnightValido
		jmp KnightNoValido
	KnightValido:
		mov MovidaEsPosible, 1
	KnightNoValido:
		mov MovidaEsPosible, 0
	ret
validarMovimientoKnight ENDP
	
; Tower: Mismo indice en X o Y // Diferencia de indices 0 en alguno de los dos ejes.
validarMovimientoTower PROC
	ret
validarMovimientoTower ENDP

; Pawn Blanca: Diferencia de indices positivo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en positivo
validarMovimientoPawnBlanca PROC
	ret
validarMovimientoPawnBlanca ENDP

; 3Ch | Pawn Negra: Diferencia de indices negativo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en negativo
validarMovimientoPawnNegra PROC
	ret
validarMovimientoPawnNegra ENDP

validarCaminoPieza PROC
	ret
validarCaminoPieza ENDP

validarDestinoKnight PROC
	ret
validarDestinoKnight ENDP

obtenerTipoPieza PROC
	lea esi, Tablero
	mov eax, 0
	mov bx, 0
	mov eax, PiezaY
	mov bl, 9
	mul bx
	add eax, PiezaX
	add esi, eax
	mov al, [esi]
	call writechar
	ret
obtenerTipoPieza ENDP

printTablero PROC
	call limpiarRegistros
	mov al, 5Ch
	call writechar
	mov al, 20h
	call writechar
	mov al, 41h
	call writechar
	mov al, 20h
	call writechar
	mov al, 42h
	call writechar
	mov al, 20h
	call writechar
	mov al, 43h
	call writechar
	mov al, 20h
	call writechar
	mov al, 44h
	call writechar
	mov al, 20h
	call writechar
	mov al, 45h
	call writechar
	mov al, 20h
	call writechar
	mov al, 46h
	call writechar
	mov al, 20h
	call writechar
	mov al, 47h
	call writechar
	mov al, 20h
	call writechar
	mov al, 48h
	call writechar
	call crlf ; salto de línea
	mov al, 31h
	call writechar
	mov al, 20h
	call writechar
	mov esi, offset Tablero
	mov cl, 0
	mov dx, 71
	cicloImprimir:
		mov al, [esi]
		cmp al, 0h
		je siguienteLinea
		call writechar
		mov al, 20h
		call writechar
		inc esi
		sub dx, 1
		cmp dx, 0
		je salir
		jmp cicloImprimir
	siguienteLinea:
		call crlf ; salto de línea
		inc esi
		sub dx, 1
		add cl, 1
		mov al, 31h
		add al, cl
		call writechar
		mov al, 20h
		call writechar
		jmp cicloImprimir
	salir:
		ret
printTablero ENDP

; ============================== ;
; INICIO DEL CÓDIGO EN EJECUCIÓN ;
; ============================== ;

main PROC
	cicloTurno:
			call limpiarVariables
			call limpiarRegistros
			call clrscr ; limpia la pantallita
			call printTablero
			call recibirPieza
			cmp PiezaExisteEnTablero, 0
			je cicloTurno
			call crlf ; Salto de línea
			cmp ColorJugador, 1
			je validarBlanca
			jne validarNegra
			validarBlanca:
				call limpiarRegistros
				call obtenerTipoPieza
				call obtenerDiferenciaIndices
				cmp PiezaMovida, 3Eh ; | Pawn
				call validarMovimientoPawnBlanca
				call validarCaminoPieza
				jne towerBlanca
				towerBlanca:
					cmp PiezaMovida, 5Dh ; | Tower
					jne bishopBlanca
				bishopBlanca:
					cmp PiezaMovida, 29h ; | Bishop
					jne kingBlanca
				kingBlanca:
					cmp PiezaMovida, 2Ah ; | King
					jne queenBlanca
				queenBlanca:
					cmp PiezaMovida, 24h ; | Queen
					jne knightBlanca
				knightBlanca:
					cmp PiezaMovida, 7Dh ; | Knight 
					jne piezaInvalida
			validarNegra:
				call obtenerTipoPieza
				call obtenerDiferenciaIndices
				cmp PiezaMovida, 3Ch ; | Pawn
				call validarMovimientoPawnNegra
				call validarCaminoPieza
				jne towerNegra
				towerNegra:
					cmp PiezaMovida, 5Bh ; | Tower
					jne bishopNegra
				bishopNegra:
					cmp PiezaMovida, 28h ; | Bishop
					jne kingNegra
				kingNegra:
					cmp PiezaMovida, 2Bh ; | King
					jne queenNegra
				queenNegra:
					cmp PiezaMovida, 26h ; | Queen
					jne knightNegra
				knightNegra:
					cmp PiezaMovida, 7Bh ; | Knight 
					jne piezaInvalida
			piezaInvalida:
				;desplegar mensaje
				jmp cicloTurno
			movimientoInvalido:
				;desplegar mensaje
				jmp cicloTurno
			salirTurno:
				;desplegar mensaje 
	
	salir:

exit
main endP
end main