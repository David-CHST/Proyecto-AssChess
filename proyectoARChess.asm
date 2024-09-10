; Proyecto de Arquitectura de Computadoras
; David Molina Guerrero
; Mariano Elizondo Alonso

include irvine32.inc
include Macros.inc

.data
	; ##########################
	; Codigos ASCII de cada pieza

	; Blanco | Negro

	;  B   N     B  N
	; 7Bh 7Dh |  {  }    Knight
	; 5Bh 5Dh |  [  ]    Tower
	; 28h 29h |  (  )    Bishop
	
	;  B   N      B  N
	; 2Bh 2Ah  |  +  *  King
	; 26h 24h  |  &  $ Queen
	; 3Ch 3Eh  |  <  >  Pawn

	; 20h Espacio Vacio 

	; ##########################

	; - Logica de cada pieza -
	; Movimiento en ejes: De arriba a abajo es positivo, de izquierda a derecha es positivo

	; 2Bh y 2Ah | King: No puede tener diferencia de indices mayor a 1
	; 26h y 24h | Queen: Bishop + Tower
	; 28h y 29h | Bishop: diferencia de indices deben ser n�meros iguales
	; 7Bh y 7Dh | Knight: La suma (unsigned) de distancia debe ser 3 cuadros, no pueden ser el mismo n�mero ni pueden ser 3 o 0 la diferencia de indices del movimiento  
	; 5Bh y 5Dh | Tower: Mismo indice en X o Y // Diferencia de indices 0 en alguno de los dos ejes.
	
	; Recordar que los indices son negativos si la pieza se hace mas para arriba
	; 3Eh | Pawn Negra: Diferencia de indices positivo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en positivo
	; 3Ch | Pawn Blanca: Diferencia de indices negativo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia con Y en negativo

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

	ColorJugador SDWORD 1
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
	PiezaMovida BYTE 0
	PiezaAtacada BYTE 0
	PiezaPuedeComer BYTE 1

	; Variables para Ingreso del Jugador
	usrCurrent BYTE 20 DUP(0) 
	usrPassword BYTE 20 DUP(0)
	usrOponent BYTE 20 DUP(0)


	; ### MENSAJES AL JUGADOR
	DigitarUsuario BYTE "Ingrese el usuario con el que desea iniciar la sesion: ", 0
	DigitarContra BYTE "Ingrese la contraseña de su usuario para utilizarlo: ", 0
	DigitarOpp BYTE "Ingrese el nombre de usuario de su oponente para vincular las partidas: ", 0
	TipoJuego BYTE "Ingrese 0 si desea vincular una nueva partida // Ingrese 1 si desea cargar partida: ", 0
	EscogerColor BYTE "Ingrese el color con el que comienza en esta partida (0 Blancas / 1 Negras): ", 0
	PreSeleccion BYTE "Ingrese la casilla de la pieza que desea mover (Columna Letra y luego Fila Numero): ", 0
	PostSeleccion BYTE "Ingrese la casilla a la que se desea mover (Columna Letra y luego Fila Numero): ", 0
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
	msgDebug BYTE "HERE", 0
	msgDebog BYTE " bug black", 0
	msgDeboog BYTE " bug white", 0

	; ##########################

.code

; ## PROCEDURES necesarios

; main PROC // contiene el codigo principal que se ejecuta
; leerUsuarioJugando PROC // Lee un usuario y una contraseña, inicio y carga de partida y selecciona color del jugador
; recibirPieza PROC // Recibe y guarda variables de pieza de inicio y el movimiento deseado, seg�n los datos define si MovidaExisteEnTablero
; limpiarRegistros PROC // Limpia todos los registros en uso
; realizarMovimiento PROC // Convierte el espacio anterior en vacio y el actual en la pieza seleccionada
; validarMovimiento<TIPOPIEZA> PROC // Multiples procedimientos encargados de validar las reglas especificas seg�n el tipo de pieza del macro
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
	mov PiezaPuedeComer, 1
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
		mov PiezaExisteEnTablero, 1
	salir:
	ret
recibirPieza ENDP

recibirMovimiento PROC
	cicloInputLetra:
		call CRLF
		call CRLF
		lea edx, PostSeleccion
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
		xor ah, ah
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
		xor ah, ah
		cmp al, 31h
		jl salir
		cmp al, 38h
		jg salir
		sub al, 31h
		mov MovidaY, eax
		jmp MovidaExiste
	MovidaExiste:
		mov MovidaExisteEnTablero, 1
	salir:
	ret
recibirMovimiento ENDP

; Facilmente la funci�n m�s importante | Se encarga de calcular el desplazamiento entre pieza seleccionada y movimiento seleccionado
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
		jle KingSemiValido
		jmp KingNoValido
	KingSemiValido:
		call validarCaminoPieza
		jmp salir
	KingNoValido:
		mov MovidaEsPosible, 0
	salir:
	ret
validarMovimientoKing ENDP
	

; Tower: Mismo indice en X o Y // Diferencia de indices 0 en alguno de los dos ejes.
validarMovimientoTower PROC
	posibilidadUnoTower: ; X = 0
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		add ebx, DiferenciaAbsY
		cmp ebx, DiferenciaAbsX
		je towerSemiValida
		jmp posibilidadDosTower
	posibilidadDosTower: ; Y = 0
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		add ebx, DiferenciaAbsY
		cmp ebx, DiferenciaAbsY
		je towerSemiValida
		jmp towerInvalida
	towerSemiValida:
		call validarCaminoPieza
		jmp salir
	towerInvalida:
		mov MovidaEsPosible, 0
	salir:
	ret
validarMovimientoTower ENDP
	
; Bishop: diferencia de indices deben ser n�meros iguales
validarMovimientoBishop PROC
	condicionUnoBishop:
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		cmp ebx, DiferenciaAbsY
		je bishopSemiValido
		jmp bishopNoValido
	bishopSemiValido:
		call validarCaminoPieza
		jmp salir
	bishopNoValido:
		mov MovidaEsPosible, 0
	salir:
	ret
validarMovimientoBishop ENDP

; Queen: Caracteristicas de Bishop OR Tower
validarMovimientoQueen PROC
	posibilidadUnoReina:
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		cmp ebx, DiferenciaAbsY
		je reinaSemiValida
		jmp posibilidadDosReina
	posibilidadDosReina: ; Y = 0
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		add ebx, DiferenciaAbsY
		cmp ebx, DiferenciaAbsX
		je reinaSemiValida
		jmp posibilidadTresReina
	posibilidadTresReina: ; X = 0
		xor ebx, ebx
		mov ebx, DiferenciaAbsX
		add ebx, DiferenciaAbsY
		cmp ebx, DiferenciaAbsY
		je reinaSemiValida
		jmp reinaInvalida
	reinaSemiValida:
		call validarCaminoPieza
		jmp salir
	reinaInvalida:
		mov MovidaEsPosible, 0
	salir:
	ret
validarMovimientoQueen ENDP
	
; Knight: La suma de las distancias absolutas debe ser 3 cuadros, ningun numero puede ser 3
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
		jne KnightSemiValido
		jmp KnightNoValido
	KnightSemiValido:
		cmp colorJugador, 1
		je revisarDestinoNegras
		revisarDestinoBlancas: ; Verifica que el caballo se coloque sobre espacio en blanco o pieza negra
			call limpiarRegistros
			lea esi, Tablero
			mov eax, 0
			mov bx, 0
			mov eax, MovidaY
			mov bl, 9
			mul bx
			add eax, MovidaX
			add esi, eax
			xor eax, eax
			mov al, [esi]
			cmp al, 20h ; comparar con espacio vacio
			je destinoValido
			cmp al, 7Dh ; comparar con Knight
			je destinoValido
			cmp al, 5Dh ; comparar con Tower
			je destinoValido
			cmp al, 29h ; comparar con Bishop
			je destinoValido
			cmp al, 2Ah ; comparar con King
			je destinoValido
			cmp al, 24h ; comparar con Queen
			je destinoValido
			cmp al, 3Eh ; comparar con Pawn
			je destinoValido
			jmp KnightNoValido
		revisarDestinoNegras:
			call limpiarRegistros
			lea esi, Tablero
			mov eax, 0
			mov bx, 0
			mov eax, MovidaY
			mov bl, 9
			mul bx
			add eax, MovidaX
			add esi, eax
			xor eax, eax
			mov al, [esi]
			cmp al, 20h ; comparar con espacio vacio
			je destinoValido
			cmp al, 7Bh ; comparar con Knight
			je destinoValido
			cmp al, 5Bh ; comparar con Tower
			je destinoValido
			cmp al, 28h ; comparar con Bishop
			je destinoValido
			cmp al, 2Bh ; comparar con King
			je destinoValido
			cmp al, 26h ; comparar con Queen
			je destinoValido
			cmp al, 3Ch ; comparar con Pawn
			je destinoValido
			jmp KnightNoValido
		destinoValido:
			mov MovidaEsPosible, 1
			jmp salir
	KnightNoValido:
		mov MovidaEsPosible, 0
	salir:
	ret
validarMovimientoKnight ENDP
	

; Pawn Blanca: Diferencia de indices positivo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia de �ndices
validarMovimientoPawnBlanca PROC
	mov MovidaEsPosible, 0
	cmp DiferenciaY, 0 ; verificar movimiento en Y positivo
	jle salir
	cmp DiferenciaAbsX, 0 ; verificar movimiento recto o diagonal
	jne tieneHorizontal
	cmp DiferenciaAbsY, 1 ; verificar solo 1 casilla de movimiento en X
	jne salir
	; llega aqui en caso de moverse recto una casilla en la direccion correcta
	mov PiezaPuedeComer, 0
	call obtenerCasillaAtacada ; coloca su resultado en AL
	mov PiezaAtacada, al
	call validarCaminoPieza ; modifica la variable MovidaEsPosible segun el resultado de sus procesos
	jmp salir
	; llega aqui en caso de moverse en diagonal una casilla en la direccion correcta
	tieneHorizontal:
	cmp DiferenciaAbsY, 1 ; verificar solo 1 casilla movimiento en Y
	jne salir
	cmp DiferenciaAbsX, 1 ; verificar solo 1 casilla de movimiento en X
	jne salir
	call obtenerCasillaAtacada
	mov PiezaAtacada, al
	cmp PiezaAtacada, 20h
	je salir
	call validarCaminoPieza ; modifica la variable MovidaEsPosible segun el resultado de sus procesos
	jmp salir
	salir:
	ret
validarMovimientoPawnBlanca ENDP

; Pawn Negra: Diferencia de indices negativo, solo 1 en eje Y excepto cuando hay oponente ahi, en ese caso permite bishop de 1 diferencia de indices
validarMovimientoPawnNegra PROC
	mov MovidaEsPosible, 0
	cmp DiferenciaY, 0 ; verificar movimiento en Y negativo
	jge salir
	cmp DiferenciaAbsX, 0 ; verificar movimiento recto o diagonal
	jne tieneHorizontal
	cmp DiferenciaAbsY, 1 ; verificar solo 1 casilla de movimiento en X
	jne salir
	; llega aqui en caso de moverse recto una casilla en la direccion correcta
	mov PiezaPuedeComer, 0
	call obtenerCasillaAtacada ; coloca su resultado en AL
	mov PiezaAtacada, al
	call validarCaminoPieza ; modifica la variable MovidaEsPosible segun el resultado de sus procesos
	jmp salir
	; llega aqui en caso de moverse en diagonal una casilla en la direccion correcta
	tieneHorizontal:
	cmp DiferenciaAbsY, 1 ; verificar solo 1 casilla movimiento en Y
	jne salir
	cmp DiferenciaAbsX, 1 ; verificar solo 1 casilla de movimiento en X
	jne salir
	call obtenerCasillaAtacada
	mov PiezaAtacada, al
	cmp PiezaAtacada, 20h
	je salir
	call validarCaminoPieza ; modifica la variable MovidaEsPosible segun el resultado de sus procesos
	jmp salir
	salir:
	ret
validarMovimientoPawnNegra ENDP

; Atravesar uno a uno el camino de los indices, revisando que no existan piezas en medio.
validarCaminoPieza PROC
	mov MovidaEsPosible, 0
	call limpiarRegistros
	; Se emplean los siguientes registros:
	; EAX = Inicialmente para multiplicar y transferir, luego en desuso
	; AL = registro donde se guarda la pieza del cuadro actual
	; BX = para multiplicar, luego para Distancia en X por recorrer
	; CX = Distancia en Y por recorrer
	; DL = Distancia Absoluta en X por recorrer
	; DH = Distancia Absoluta en Y por recorrer
	; ESI = Direccion de la casilla en el tablero

	; Se coloca ESI en el offset de la casilla de la pieza seleccionada
	lea esi, Tablero
	mov eax, 0
	mov bx, 0
	mov eax, PiezaY
	mov bl, 9
	mul bx
	add eax, PiezaX
	add esi, eax

	; Se limpian registros involucrados con multiplicacion
	xor eax, eax
	xor ebx, ebx
	xor edx, edx

	; Se guardan las diferencias en los registros adecuados
	movsx bx, byte ptr DiferenciaX ; El Move with Sign Extension permite mover el numero con complemento para no perder el signo
	movsx cx, byte ptr DiferenciaY ; El byte pointer obtiene la parte menos significativa del numero, permitiendo convertir de 32bits a 16bits

	mov dl, byte ptr DiferenciaAbsX ; se usa un BYTE POINTER para que se tome solo el ultimo byte significativo del numero
	mov dh, byte ptr DiferenciaAbsY ; se usa un BYTE POINTER para que se tome solo el ultimo byte significativo del numero

	cmp PiezaPuedeComer, 0 ; Si la pieza no puede comer, es un peón moviéndose recto
	je destinoPasivo
	; Ciclo para el camino, no debe haber ninguna ficha en medio
	cicloCamino:
		cmp DL, 1
		je destinoAgresivoBlancas
		cmp DH, 1
		je destinoAgresivoBlancas
		; Se llega aqui cuando se tiene mas de una casilla por mover en X o Y
		; manejar indices en X
		moverX:
			cmp DL, 1
			jle moverY
			test BX, BX ; se prueba si es positivo o negativo
			jns positivoX
			negativoX:
			add BX, 1; sumar registros para acercarse a 0
			sub DL, 1; restar absolutos para acercarse a 0
			sub esi, 1; restar esi en 1 para desplazar en el tablero
			jmp moverY
			positivoX:
			sub BX, 1; sumar registros para acercarse a 0
			sub DL, 1; restar absolutos para acercarse a 0
			add esi, 1; restar esi en 1 para desplazar en el tablero
		; manejar indices en Y
		moverY:
			cmp DH, 1
			jle cicloCamino
			test CX, CX ; se prueba si es positivo o negativo
			jns positivoY
			negativoY:
			add CX, 1; sumar registros para acercarse a 0
			sub DH, 1; restar absolutos para acercarse a 0
			sub esi, 9; restar esi en 9 para desplazar una fila completaen el tablero 
			jmp revisarCuadro
			positivoY:
			sub CX, 1; sumar registros para acercarse a 0
			sub DH, 1; restar absolutos para acercarse a 0
			add esi, 9; restar esi en 9 para desplazar una fila completa en el tablero 
			jmp revisarCuadro
		; Verificar que NO sea una ficha
		revisarCuadro:
			mov al, [esi]
			cmp al, 20h ; 20h es el espacio vacio
			jne salir ; en caso de no ser un espacio vacio se sale del programa sin validar el movimiento
			jmp cicloCamino ; caso contrario continua el ciclo
		
	; Apartado para el destino sin comer, no debe haber ninguna ficha
	destinoPasivo:
		call limpiarRegistros
		lea esi, Tablero
		mov eax, 0
		mov bx, 0
		mov eax, MovidaY
		mov bl, 9
		mul bx
		add eax, MovidaX
		add esi, eax
		xor eax, eax
		mov al, [esi]
		cmp al, 20h
		je destinoValido
		jmp salir
		
	; Apartado para el destino comiendo, depende del color
	destinoAgresivoBlancas:
		call limpiarRegistros
		cmp colorJugador, 1
		je destinoAgresivoNegras
		lea esi, Tablero
		mov eax, 0
		mov bx, 0
		mov eax, MovidaY
		mov bl, 9
		mul bx
		add eax, MovidaX
		add esi, eax
		xor eax, eax
		mov al, [esi]
		cmp al, 20h ; comparar con espacio vacio
		je destinoValido
		cmp al, 7Dh ; comparar con Knight
		je destinoValido
		cmp al, 5Dh ; comparar con Tower
		je destinoValido
		cmp al, 29h ; comparar con Bishop
		je destinoValido
		cmp al, 2Ah ; comparar con King
		je destinoValido
		cmp al, 24h ; comparar con Queen
		je destinoValido
		cmp al, 3Eh ; comparar con Pawn
		je destinoValido
		jmp salir

	destinoAgresivoNegras:
		call limpiarRegistros
		lea esi, Tablero
		mov eax, 0
		mov bx, 0
		mov eax, MovidaY
		mov bl, 9
		mul bx
		add eax, MovidaX
		add esi, eax
		xor eax, eax
		mov al, [esi]
		cmp al, 20h ; comparar con espacio vacio
		je destinoValido
		cmp al, 7Bh ; comparar con Knight
		je destinoValido
		cmp al, 5Bh ; comparar con Tower
		je destinoValido
		cmp al, 28h ; comparar con Bishop
		je destinoValido
		cmp al, 2Bh ; comparar con King
		je destinoValido
		cmp al, 26h ; comparar con Queen
		je destinoValido
		cmp al, 3Ch ; comparar con Pawn
		je destinoValido
		jmp salir

	destinoValido:
		mov MovidaEsPosible, 1 ; en caso de ser un espacio vacio el destino, se permite el movimiento
		jmp salir
	salir:
	ret
validarCaminoPieza ENDP

leerUsuarioJugando PROC
	call limpiarRegistros
	mov si, 0
	cicloIngresoUsuario:
		call clrscr
		lea eax, DigitarUsuario
		call WriteString
		xor eax, eax
		call readChar
		cmp al, 13 ; comparar si es enter
		je inicioPassword 
		lea usrCurrent[si], al
		inc si
		jmp cicloIngresoPassword
	inicioPassword:
		mov si, 0
		jmp cicloIngresoPassword
	cicloIngresoPassword:
		call clrscr
		lea eax, DigitarContra
		call WriteString
		xor eax, eax
		call readChar
		cmp al, 13 ; comparar si es enter
		je inicioOpp 
		lea usrPassword[si], al
		inc si
		jmp cicloIngresoPassword
	inicioOpp:
		mov si, 0
		jmp cicloIngresoOpp
	cicloIngresoOpp:
		call clrscr
		lea eax, DigitarOpp
		call WriteString
		xor eax, eax
		call readChar
		cmp al, 13 ; comparar si es enter
		je tipoInicio 
		lea usrOponent[si], al
		inc si
		jmp cicloIngresoOpp
	tipoInicio:
		call clrscr
		lea eax, TipoJuego
		call WriteString
		xor eax, eax
		call readChar
		cmp al, 30h
		je nuevaPartida
		cmp al 31h
		je cargarPartida
		jmp tipoInicio
	nuevaPartida:
		; procesamiento de nuevo archivo // Jug 1 sube archivo, Jug 2 recibe de nube 
	cargarPartida:
		; procesamiento preparativo de leer partida
	colorJugador:
		call clrscr
		lea eax, EscogerColor
		call WriteString
		xor eax, eax
		call readChar
		cmp al, 31h
		je empiezaNegras
		cmp al 30h
		je empiezaBlancas
		jmp colorJugador
	empiezaBlancas:
		mov colorJugador, 0
		jmp salir
	empiezaNegras:
		mov colorJugador, 1
		jmp salir
	salir:
	ret
leerUsuarioJugando ENDP

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

obtenerCasillaAtacada PROC
	lea esi, Tablero
	mov eax, 0
	mov bx, 0
	mov eax, PiezaY
	add eax, DiferenciaY
	mov bl, 9
	mul bx
	add eax, PiezaX
	add eax, DiferenciaX
	add esi, eax
	mov al, [esi] ; se deja el resultado en el registro AL 
	ret
obtenerCasillaAtacada ENDP

printTablero PROC
	; Imprime las letras de las coordenadas
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
	call crlf ; salto de l�nea
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
		call crlf ; salto de l�nea
		inc esi
		sub dx, 1
		add cl, 1
		mov al, 31h
		add al, cl
		call writechar ; Imprime los numeros de las coordenadas
		mov al, 20h 
		call writechar 
		jmp cicloImprimir
	salir:
		ret
printTablero ENDP

realizarMovimiento PROC
	; obtener direccion de memoria del cuadro atacado
	; colocar pieza actual en ese cuadro
	lea esi, Tablero
	mov eax, 0
	mov bx, 0
	mov eax, MovidaY
	mov bl, 9
	mul bx
	add eax, MovidaX
	add esi, eax
	xor eax, eax
	mov al, PiezaMovida
	mov [esi], al
	
	; eliminar la posicion pasada de la pieza
	call limpiarRegistros
	lea esi, Tablero
	mov eax, 0
	mov bx, 0
	mov eax, PiezaY
	mov bl, 9
	mul bx
	add eax, PiezaX
	add esi, eax
	xor eax, eax
	mov al, 20h
	mov [esi], al
	ret
realizarMovimiento ENDP
; ============================== ;
; INICIO DEL CODIGO EN EJECUCION ;
; ============================== ;

main PROC
	; antes de iniciar el turno falta un menu para iniciar un juego y seleccionar el color del jugador en este dispositivo
	cicloTurno:
			call limpiarVariables
			call limpiarRegistros
			call clrscr ; limpia la pantallita
			call leerUsuarioJugando
			call printTablero
			call recibirPieza ; recibe la pieza que se desea mover
			cmp PiezaExisteEnTablero, 0
			je cicloTurno
			call crlf ; Salto de linea
			call crlf ; Salto de linea
			cmp ColorJugador, 1
			je validarNegra
			jne validarBlanca
			validarBlanca:
				call limpiarRegistros
				call obtenerTipoPieza
				mov PiezaMovida, al
				pawnBlanca:
					cmp PiezaMovida, 3Ch  ; | Pawn
					jne towerBlanca
					call limpiarRegistros
					lea edx, PBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					call validarMovimientoPawnBlanca
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
					jmp salirTurno ; termina el turno
				towerBlanca:
					cmp PiezaMovida, 5Bh ; | Tower
					jne bishopBlanca
					call limpiarRegistros
					lea edx, TBSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					call validarMovimientoTower
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoBishop
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoKing
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoQueen
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoKnight
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
					jmp salirTurno ; termina el turno
			validarNegra:
				call limpiarRegistros
				call obtenerTipoPieza
				mov PiezaMovida, al
				pawnNegra:
					cmp PiezaMovida, 3Eh ; | Pawn
					jne towerNegra
					call limpiarRegistros
					lea edx, PNSeleccionado
					call WriteString
					call CRLF
					call recibirMovimiento
					call obtenerDiferenciaIndices
					call validarMovimientoPawnNegra
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoTower
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoBishop
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoKing
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoQueen
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
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
					call validarMovimientoKnight
					cmp MovidaEsPosible, 0
					je salirTurno
					call RealizarMovimiento ; Todas las funciones anteriores se corren para decidir si se ejecuta este proceso
					jmp salirTurno ; termina el turno
			piezaInvalida:
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				;desplegar mensaje
				call readChar
				jmp cicloTurno
			movimientoInvalido:
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				;desplegar mensaje
				call readChar
				jmp cicloTurno
			salirTurno:
				mov PiezaExisteEnTablero, 0
				mov MovidaExisteEnTablero, 0
				jmp cicloTurno
				;desplegar mensaje 
	salir:

exit
main endP
end main