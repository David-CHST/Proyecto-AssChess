; Proyecto de Arquitectura de Computadoras
; David Molina Guerrero

include irvine32.inc
include Macros.inc

.data
	; ##########################
	; Códigos ASCII de cada pieza

	; NEGRO | BLANCO


	;  N   B     N  B
	; 7Bh 7Dh |  {  }    Knight
	; 5Bh 5Dh |  [  ]    Tower
	; 28h 29h |  (  )    Bishop
	
	;  N    B     N  B
	; 2Bh 2Ah  |  +  *  King
	; 26h 24h  |  &  $ Queen
	; 3Ch 3Eh  |  <  >  Pawn

	; 20h Espacio Vacio 

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
	DiferenciaAbsX DWORD 0 ; Se usan variables sin signo para valores absolutos
	DiferenciaAbsY DWORD 0 ; Se usan variables sin signo para valores absolutos
	PiezaMovida BYTE 0, 0
	PiezaAtacada BYTE 0, 0

	; ### MENSAJES AL JUGADOR

	PreSeleccion BYTE "Ingrese la casilla de la pieza que desea mover (Columna Letra y luego Fila Numero) ", 0
	PBSeleccionado BYTE "Se ha elegido un Peon Blanco... Ingrese el movimiento que desea: ", 0
	TBSeleccionado BYTE "Se ha elegido una Torre Blanca... Ingrese el movimiento que desea: ", 0
	ABSeleccionado BYTE "Se ha elegido un Alfil Blanco... Ingrese el movimiento que desea: ", 0
	KBSeleccionado BYTE "Se ha elegido un Rey Blanco... Ingrese el movimiento que desea: ", 0
	RBSeleccionado BYTE "Se ha elegido una Reina Blanca... Ingrese el movimiento que desea: ", 0
	CBSeleccionado BYTE "Se ha elegido un Caballo Blanco... Ingrese el movimiento que desea: ", 0
	PNSeleccionado BYTE "Se ha elegido un Peon Negro... Ingrese el movimiento que desea: ", 0
	TNSeleccionado BYTE "Se ha elegido una Torre Negra... Ingrese el movimiento que desea: ", 0
	ANSeleccionado BYTE "Se ha elegido un Alfil Negro... Ingrese el movimiento que desea: ", 0
	KNSeleccionado BYTE "Se ha elegido un Rey Negro... Ingrese el movimiento que desea: ", 0
	RNSeleccionado BYTE "Se ha elegido una Reina Negra... Ingrese el movimiento que desea: ", 0
	CNSeleccionado BYTE "Se ha elegido un Caballo Negro... Ingrese el movimiento que desea: ", 0
	NULLSELECCIONADO BYTE "Se ha elegido una ficha invalida... Presione cualquier tecla para volver...", 0
	
	
	; ### DEBUG
	msg1 BYTE "-num-", 0
	msg2 BYTE "-minuscula-", 0
	msg3 BYTE "-saliendo-", 0
	msg4 BYTE "-valido-", 0
	msgDebug BYTE "HERE", 0
	msgDebog BYTE " bug black", 0
	msgDeboog BYTE " bug white", 0

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
		call CRLF
		call CRLF
		lea edx, PreSeleccion
		call WriteString
		call CRLF
		xor edx, edx
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
		xor ah, ah
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
	ret
recibirPieza ENDP

recibirMovimiento PROC
	cicloInputLetra:
		call CRLF
		call CRLF
		lea edx, PreSeleccion
		call WriteString
		call CRLF
		xor edx, edx
		call ReadChar
		call WriteChar
		xor ah, ah
		cmp al, 41h
		jl salir ; JUMP IF LESS
		cmp al, 48h
		jg verMinuscula
		sub al, 41h
		mov MovidaX, eax
		jmp cicloInputNum
	verMinuscula:
		mov edx, offset msg2
		call writestring
		xor ah, ah
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
	mov DiferenciaX, ebx ; se guarda el valor de MovidaX en DiferenciaX
	mov edx, PiezaX
	sub DiferenciaX, edx ; se le resta el movimiento en X
	; Ahora se calcula el valor absoluto de diferencia X
	call limpiarRegistros
	mov eax, DiferenciaX
	test eax, eax ; Prueba de Negatividad
	jns sinCambioX ; en caso de ser positivo no requiere cambio
	neg eax ; en caso de ser negativo se niega el valor para ser positivo
	sinCambioX:
	mov DiferenciaAbsX, eax ; se guarda el absoluto en variable
	mov ebx, MovidaY
	mov DiferenciaY, ebx ; se guarda el valor de MovidaY en DiferenciaY
	mov edx, PiezaY
	sub DiferenciaY, edx ; se le resta el movimiento en Y
	call limpiarRegistros
	mov eax, DiferenciaY
	test eax, eax ; Prueba de Negatividad
	jns sinCambioY ; en caso de ser positivo no requiere cambio
	neg eax ; en caso de ser negativo se niega el valor para ser positivo
	sinCambioY:
	mov DiferenciaAbsY, eax ; se guarda el absoluto en variable
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

; Pawn Blanca: Diferencia de indices positivo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia de índices
validarMovimientoPawnBlanca PROC
	ret
validarMovimientoPawnBlanca ENDP

; Pawn Negra: Diferencia de indices negativo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia de índices
validarMovimientoPawnNegra PROC
	ret
validarMovimientoPawnNegra ENDP

; Atravesar uno a uno el camino de los índices, revisando que no existan piezas en medio.
validarCaminoPieza PROC
	ret
validarCaminoPieza ENDP

; Verificar que la pieza destino está vacía o es enemiga
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

realizarMovimiento PROC
	ret
realizarMovimiento ENDP
; ============================== ;
; INICIO DEL CÓDIGO EN EJECUCIÓN ;
; ============================== ;

main PROC
	; antes de iniciar el turno falta un menu para iniciar un juego y seleccionar el color del jugador en este dispositivo
	cicloTurno:
			call limpiarVariables
			call limpiarRegistros
			call clrscr ; limpia la pantallita
			call printTablero
			call recibirPieza ; recibe la pieza que se desea mover
			cmp PiezaExisteEnTablero, 0
			je cicloTurno
			call crlf ; Salto de línea
			call crlf ; Salto de línea
			cmp ColorJugador, 1
			je validarBlanca
			jne validarNegra
			validarBlanca:
				call limpiarRegistros
				call obtenerTipoPieza
				mov PiezaMovida, al
				pawnBlanca:
					lea edx, PiezaMovida
					call writeString
					lea edx, msgDeboog
					call writeString
					cmp PiezaMovida, 3Ch  ; | Pawn
					jne towerBlanca
					call limpiarRegistros
					lea edx, PBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarMovimientoPawnBlanca
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				towerBlanca:
					lea edx, msgDeboog
					call writeString
					cmp PiezaMovida, 5Bh ; | Tower
					jne bishopBlanca
					call limpiarRegistros
					lea edx, TBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					; realizar movimiento
					jmp salirTurno ; termina el turno
				bishopBlanca:
					cmp PiezaMovida, 28h ; | Bishop
					jne kingBlanca
					call limpiarRegistros
					lea edx, ABSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					; realizar movimiento
					jmp salirTurno ; termina el turno
				kingBlanca:
					cmp PiezaMovida, 2Bh  ; | King
					jne queenBlanca
					call limpiarRegistros
					lea edx, KBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					; realizar movimiento
					jmp salirTurno ; termina el turno
				queenBlanca:
					cmp PiezaMovida, 26h ; | Queen
					jne knightBlanca
					call limpiarRegistros
					lea edx, RBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					; realizar movimiento
					jmp salirTurno ; termina el turno
				knightBlanca:
					cmp PiezaMovida, 7Bh ; | Knight 
					jne piezaInvalida
					call limpiarRegistros
					lea edx, CBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					; realizar movimiento
					jmp salirTurno ; termina el turno
			validarNegra:
				call limpiarRegistros
				call obtenerTipoPieza
				mov PiezaMovida, al
				pawnNegra:
					lea edx, PiezaMovida
					call writeString
					cmp PiezaMovida, 3Eh ; | Pawn
					jne towerNegra
					call limpiarRegistros
					lea edx, PNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					mov eax, DiferenciaAbsX
					add al, 30h
					xor ah, ah
					call writechar
					mov eax, DiferenciaAbsY
					add al, 30h
					xor ah, ah
					call writechar
					call readchar
					call validarMovimientoPawnNegra
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				towerNegra:
					cmp PiezaMovida, 5Dh ; | Tower
					jne bishopNegra
					call limpiarRegistros
					lea edx, TNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				bishopNegra:
					cmp PiezaMovida, 29h ; | Bishop
					jne kingNegra
					call limpiarRegistros
					lea edx, ANSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				kingNegra:
					cmp PiezaMovida, 2Ah ; | King
					jne queenNegra
					call limpiarRegistros
					lea edx, KNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				queenNegra:
					cmp PiezaMovida, 24h ; | Queen
					jne knightNegra
					call limpiarRegistros
					lea edx, RNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					call validarCaminoPieza
					jmp salirTurno ; termina el turno
				knightNegra:
					cmp PiezaMovida, 7Dh ; | Knight 
					jne piezaInvalida
					call limpiarRegistros
					lea edx, CNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					lea edx, DiferenciaAbsX
					call writeString
					lea ebx, DiferenciaAbsY
					call writeString
					call readchar
					jmp salirTurno ; termina el turno
			piezaInvalida:
				;desplegar mensaje
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				call readChar
				jmp cicloTurno
			movimientoInvalido:
				;desplegar mensaje
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				call readChar
				jmp cicloTurno
			salirTurno:
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				;desplegar mensaje 
	
	salir:

exit
main endP
end main