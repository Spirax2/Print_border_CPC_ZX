	define pausaentreletras 8

	define linea1 		$BA00
	define linea2 		linea1+36
	define linea3		linea2+36
	define linea4		linea3+36
	define linea5		linea4+36
	
	define interrupcion_anterior linea1+180
	define es128 		linea1+181
	define pixelesrotar 	linea1+182
	define ultimocaracter 	linea1+183
	define colortexto 	linea1+184
	define colorletra 	linea1+185
	define rotacion 	linea1+186
	define contador 	linea1+187
	define direcciontexto 	linea1+188 ;DW
	define textoactual 	linea1+190 ;DW


	display "el texto son -> ",/d, endtexto0-texto0 
	

	org $8000
IM2table:
	block 257, high inicioIM2 			; IM2 table (reserved)

arranca:
	display "arranca ",/a,$
	ld a, i
	ld (interrupcion_anterior), a
	di
	ld a, high IM2table
	ld i, a
	im 2

	xor a
	ld hl, es128
	ld b, 12
bucleiniciovariables:
	ld (hl), a
	inc l
	djnz bucleiniciovariables
	
	ld hl, texto0
	ld (direcciontexto), hl
	ld (textoactual), hl

	call check128k
	ld (es128), a
	call create_lines
	call cambia_outs
	ld a, pausaentreletras
	ld (contador), a
	ei
bucleborde:
	call check_keyb
	halt
	jr bucleborde


check_keyb:
	ld a, $7f
	in a, ($fe)
	bit 0, a
	ret nz
	di
	ld a, (interrupcion_anterior)
	ld i, a
	im 1
	pop bc
	ei
	ret

	include	"check128k.asm"

texto0:
	defb "   HOLA ESTO ES UNA PRUEBA DE TEXTO EN EL BORDE DEL ZX   ",0
endtexto0:


;Crea las lineas de OUTS a partir de la definicion de Linea1
;entrada necesita que previamente se haya comprovado si es un 48k o 128k y puesto en la variable es128
;cada linea son 36 bytes total 180 bytes, deben estar alineadas en el mismo byte alto
;ENTRADA	es128
;SALIDA		--
;MODIFICA	AF, HL, DE, BC
create_lines:
	ld hl, linea1
	ld a, (es128)
	or a
	ld de, $C900	;para el 48k haremos, RET, NOP
	jr z, modify_returns48
	ld de, $00C9	;para el 128k haremos , NOP, RET lo que incrementa en 4-tstates cada linea.
modify_returns48:
	xor a
	ld c, 05
modify_return_line:
	ld b, 16
modify_return_out:
	ld (hl), $ED	;ponemos 16 $ED,$41 que es  OUT (C),b
	inc l
	ld (hl), $41
	inc l
	djnz modify_return_out
	dec l
	ld (hl), $57	;en el ultimo cambiamos el $41 por $57 para que sea $ED,$57 = LD A, I
	inc l
	ld (hl), a	;NOP
	inc l
	ld (hl), a	;NOP
	inc l
	ld (hl), d	;en 48k RET en 128k NOP
	inc l
	ld (hl), e	;en 48k NOP en 128k RET
	inc l
	dec c
	jr nz, modify_return_line
	ret



;------------------------------------------------------------
	block $BCBC-$ ,0
inicioIM2:
;	di
	push af					;11	
	push hl					;11
	push de					;11
	push bc					;11
	ex af, af				;4
	push af					;11
	exx						;4
	push hl					;11
	push de					;11
	push bc					;11
	push ix					;15
	push iy					;15
	;						;137

	ld a, (es128)			;13
	or a				;4
	jp z, saltar_es48k_inicio	;10

;es_128k
	inc bc				;6
	ld bc, (0)			;20
	ld bc, $dbfe			;10
	jp continua_interrupcion_comun	;10


saltar_es48k_inicio:
;es_48k
	ld bc, $dffe			;10
	nop				;4

continua_interrupcion_comun:
	nop				;4
	xor a				;4
bucle_interrupcion:
	out (c), a 			;12
	inc hl				;6
	dec b				;4
	jp nz, bucle_interrupcion	;10	el bucle son 32 t-states por pasada

	ld hl, $0405			;10	colores de las letras
	ld de, $0607			;10	colores de las letras

	;out (c),b for black border
	call linea1				
	call linea1				
	call linea1				
	call linea1				
	call linea1				
	call linea1				

	call linea2
	call linea2
	call linea2
	call linea2
	call linea2
	call linea2

	call linea3
	call linea3
	call linea3
	call linea3
	call linea3
	call linea3

	call linea4
	call linea4
	call linea4
	call linea4
	call linea4
	call linea4

	call linea5
	call linea5
	call linea5
	call linea5
	call linea5
	call linea5

	inc hl				;6	ajuste

	ld a, (contador)		;13
	dec a				;4
	jp nz, saltar_cambia_outs	;10
	call cambia_outs		;17
	ld a, pausaentreletras		;7	reinicio contador
saltar_cambia_outs:
	ld (contador), a		;13

	pop iy				;14
	pop ix				;14
	pop bc				;10
	pop de				;10
	pop hl				;10
	exx				;4
	pop af				;10
	ex af, af			;4
	pop bc				;10
	pop de				;10
	pop hl				;10
	pop af				;10
	ei				;4
	ret				;10


;Cambia los outs con las letras del mensaje
;ENTRADA 	--
;SALIDA  	--
;MODIFICA	 AF, AF', HL, DE, BC
cambia_outs:
	ld de, (textoactual)	;DE = inico del texto a imprimir
	ld hl, linea1		;HL = direccion de la linea donde cambiar los outs

	xor a
	ld (ultimocaracter), a	;reseteamos la variable del ultimo caracter

	ld a, (rotacion)	;ponemos en A el numero de pixeles a imprimir 1,2,3 o 0, cero es igual a imprimir los 4 pixeles del caracter
	call caracter_imprimir
	
	ld a, (rotacion)	;sumamos el numero de pixeles en rotacion*2 a HL
	cpl
	and 3
	inc a
	add a, a
	add a, l
	ld l, a
	
	xor a			;ponemos A a cero para imprimir los 4 pixeles 
	call caracter_imprimir
	ld a, l			;sumamos un caracter completo de 4 pixeles x2 a HL
	add a, 8
	ld l, a

	xor a			;ponemos A a cero para imprimir los 4 pixeles 
	call caracter_imprimir
	ld a, l			;sumamos un caracter completo de 4 pixeles x2 a HL
	add a, 8
	ld l, a

	
	ld a, (rotacion)
	inc a			;ponemos en A la posicion de la rotacion + 1
	ld (ultimocaracter), a	;indicamos que es el ultimo caracter por lo que la rotación sera invertida
	call caracter_imprimir

	ld a, (rotacion)
	inc a			;incrementamos la rotación
	and 3			;nos deja solo los valores de 0, 1, 2 o 3
	ld (rotacion), a
	ret nz			;retornamos con cualquier valor diferente de 0

	;si seguimos por aqui hay que cambiar el caracter del mensaje a imprimir en la proxima impresion
	ld a, (colortexto)
	inc a			;incrementamos el color del proximo caracter
	and 3			;nos deja solo los valores de 0, 1, 2 o 3
	ld (colortexto),a

	ld hl, (textoactual)	;direccion del caracter actual
	inc hl			;+1
	ld a, (hl)
	or a			;comprobamos si es 0
	jr nz, continuacontexto	;si no es cero continuamos
	ld hl, (direcciontexto)	;recuperamos la direccion de inicio del texto
continuacontexto
	ld (textoactual), hl	;guardamos la direccion para el siguiente caracter
	ret

;ENTRADA	 A = numero de pixeles a rotar
;		 HL = direccion de la linea1 de outs donde modificarlo
;		 DE = direccion del caracter a imprimir
;SALIDA		 DE= DE+1
;MODIFICA   AF, AF', BC
caracter_imprimir:
	ld (pixelesrotar), a	;guardamos los pixeles a rotar
	
	;calculamos el color de la letra que vamos a imprimir
	ld a, (colortexto)
	inc a
	and 3			;el color sera 0,1,2 o 3
	ld (colortexto), a
	rla
	rla
	rla			;lo rotamos 3 bits y el valor será, $00, $08, $10, $18 
	add $51			;le sumamos $51 y tendremos el segundo byte del OUT (C),hlde
	ld (colorletra), a	;lo guardmaos en colorletra

	ld a, (de)		;caracter a imprimir
	push de
	push hl
	call modify_outs
	pop hl
	pop de
	inc de			;siguiente caracter
	ret

;ENTRADA 	A = caracter a imprimir
;		HL = direccion de la linea1 de outs donde modificarlo
;SALIDA		 --
;MODIFICA    AF, AF', DE, HL, BC
modify_outs:	
	ex de, hl		;guardamos el valor actual de HL en DE
	sub 32			;restamos 32 a A, para alinear con Fuente
	ld h, 0
	ld b, h
	ld c, a			;guardamos A temporalmente en C
	add a, a		;*2
	ld l, a
	add hl, hl		;*4
	add hl, bc		;*5
	ld bc, font
	add hl, bc
	ex de, hl 		;intercambiamos DE y recuperamos el HL anterior
	;HL = direccion de la linea1 de outs donde modificarlo
	;DE = direccion de incio de la fuente
	
	ld c, 5			;numero de lineas del caracter
caracter_font:
	push hl
	ld a, (de)		;cargamos el origen de la fuente
	ex af, af		;guardamos el caracter
	
	ld a, (ultimocaracter)
	or a
	ld a, (pixelesrotar)
	jr nz, salto_ultimo_caracter
	or a
	ld b, 4 		;numero de pixels a tratar, la fuente tiene 4 pero el derecho es siempre 0
	jr z, iniciorotacionfont
	ld b, a
	ex af, af
buclerotacionajuste:
	rla
	dec b
	jr nz, buclerotacionajuste
	ex af, af
	cpl
	and 3
	inc a
salto_ultimo_caracter:
	ld b, a
iniciorotacionfont:	
	ex af, af
bucle_font:
	inc l			;nos saltamos el $ED
	rla			;ratamos la fuente
	jr c, carryenfont	;si hay carry hay poner color
	ld (hl), $41		;out (c), b
	inc l			;siguiente pixel
	djnz bucle_font
	jr continuafont

carryenfont:
	ex af, af
	ld a, (colorletra)
	ld (hl), a		;out (c), hlde
	ex af, af
	inc l			;siguiente pixel
	djnz bucle_font

continuafont:	
	pop hl
	ld a, l
	add a, 36		;siguiente linea
	ld l, a
	inc de
	dec c
	jr nz, caracter_font
	ret

;font
	include "Font 4x5 izda.asm"

  display "Final rutina ",/d,$, " Bytes ",/d,$ - inicioIM2 , " Libres ",/d,$c000-$
	