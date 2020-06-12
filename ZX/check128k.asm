	define  BANKM $5b5c
	define  BANK678 $5b67

	;entrada ninguna, OJO asume Interrupciones estan desabilitadas
	;modifica BC, DE, HL A y A'
	;salida A=1 con el carry activado para 128k
	;salida A=0 con el carry desactivado para 48k
	
check128k	
	ld bc, $7ffd
	ld de, $1110
	ld hl, $C000

	out (c),d		;cambio al banco 11
	ld a, (hl)		;guardamos el contenido de 11 en A
	out (c),e		;cambiamos a 10
	ex af, af'
	ld a, (hl)		;guardamos el contenido de 10 en A'
	ex af, af'
	cpl				;invertimos A
	ld (hl),a		;lo guardammos en 10
	cpl				;restauramos A
	out (c),d		;cambiamos a 11
	cp (hl)			;comparamos con 11
	out (c),e		;cambiamos a 10
	ex af, af'
	ld (hl), a		;restauramos el contenido de 10 de A'
	ex af, af'
	jr nz, es48k
	ld a, (BANKM)	;pero si es un 128k cogemos el banco que habia en BANKM
	out (c),a		;lo paginamos antes de regresar
	ld a, 1			;ponemos A con valor 1
	scf				;y si es 128k activamos el carry
	ret
es48k
	xor a			;si es 48k resetamos el carry
	ret
	