;;Inicializa las variables para iniciar la impresion del Texto en el Borde
;;crea las tablas de OUTs
;;e inicia la impresion
;ENTRADA HL dirección de la cadena de texto a imprimir
;SALIDA  --
;MODIFICA AF, BC, HL, DE
init_border_efect:
	ld (direcciontexto), hl
	ld (textoactual), hl

	xor a
	ld hl, pixelesrotar
	ld b, 7
bucleiniciovariables:
	ld (hl), a
	inc hl
	djnz bucleiniciovariables

	call create_lines
	call cambia_outs
	ld a, pausaentreletras		; reinicio contador
	ld (contadorpausaentreletras), a
	ld a, 1
	ld (impresion_borde), a
	ret

;;para la impresion
;ENTRADA --
;SALIDA  --
;MODIFICA AF	
stop_border_efect:
	xor a
	ld (impresion_borde), a
	ret


;--------------------------------------------------------------------
;Crea las lineas de OUTS a partir de la definicion de Linea1
;cada linea son 29 bytes, deben estar alineadas en el mismo byte alto
;ENTRADA	--
;SALIDA		--
;MODIFICA	HL, DE, BC
create_lines:
	ld hl, linea1
	ld de, $ED79	;$ED,$79 = OUT (C),a
	ld c, 05
modify_return_line:
	ld b, 14
modify_return_out:
	ld (hl), d	;ponemos 14 x OUT (C),a
	inc hl
	ld (hl), e
	inc hl
	djnz modify_return_out
	ld (hl), #C9	;RET
	inc hl
	dec c
	jr nz, modify_return_line
	ret


;Ejecuta las tablas de OUTs para imprimir el border
;se debe ajustar el timming antes de llamar para que imprima al inicio de la linea
;el resto de lineas estan sincronicadas
;ENTRADA --
;SALIDA  --
;MODIFICA AF,HL,BC,DE
;--------------------------------------------------------------------
print_letras_borde:
	ld hl, colorletra1 * 256 + colorletra2
	ld de, colorletra3 * 256 + colorletra4

	ld bc, $7F10
	out (c), c
	ld a, colorborde1	;for the out (c),a 

	call linea1				
	call linea1				
	call linea1				
;	call linea1				
;	call linea1				

	call linea2
	call linea2
	call linea2
;	call linea2				
;	call linea2				

	call linea3
	call linea3
	call linea3
;	call linea3				
;	call linea3				

	call linea4
	call linea4
	call linea4
;	call linea4				
;	call linea4				

	call linea5
	call linea5
	call linea5
;	call linea5
;	call linea5
	
	ret


;--------------------------------------------------------------------

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
	ld c, a
	ld b, 0
	add hl, bc

	xor a			;ponemos A a cero para imprimir los 4 pixeles 
	call caracter_imprimir
	ld bc, 8
	add hl, bc

	xor a			;ponemos A a cero para imprimir los 4 pixeles 
	call caracter_imprimir
	ld bc, 8
	add hl, bc

	
	ld a, (rotacion)
	inc a			;ponemos en A la posicion de la rotacion + 1
	ld (ultimocaracter), a	;indicamos que es el ultimo caracter por lo que la rotaciуn sera invertida
	call caracter_imprimir

	ld a, (rotacion)
	inc a			;incrementamos la rotaciуn
	and 3			;nos deja solo los valores de 0, 1, 2 o 3
	ld (rotacion), a
	ret nz			;retornamos con cualquier valor diferente de 0

	;si seguimos por aqui hay que cambiar el caracter del mensaje a imprimir en la proxima impresion
	ld a, (colortexto)
	inc a			;incrementamos el color del proximo caracter
	and 3			;nos deja solo los valores de 0, 1, 2 o 3
	ld (colortexto),a

	ld a, (de)		;cargamos el proximo caracter
	dec de			;como hemos impreso 4 carateres restamos 3
	dec de
	dec de			;DE -3 para dejarlo en el proximo a imprimir
	or a			;comprobamos si el caracter es 0
	jr nz, continuacontexto	;si no es cero continuamos
	ld de, (direcciontexto)	;recuperamos la direccion de inicio del texto
continuacontexto
	ld (textoactual), de	;guardamos la direccion del siguiente caracter
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
	rla			;lo rotamos 3 bits y el valor serб, $00, $08, $10, $18 
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
	inc hl			;nos saltamos el $ED
	rla			;ratamos la fuente
	jr c, carryenfont	;si hay carry hay poner color
	ld (hl), $79		;out (c), a
	inc hl			;siguiente pixel
	djnz bucle_font
	jr continuafont

carryenfont:
	ex af, af
	ld a, (colorletra)
	ld (hl), a		;out (c), hlde
	ex af, af
	inc hl			;siguiente pixel
	djnz bucle_font

continuafont:	
	pop hl
	ld a, l
	add a, 29		;siguiente linea
	ld l, a
	jr nc, nocarryonsiguientelinea
	inc h
nocarryonsiguientelinea	
	inc de
	dec c
	jr nz, caracter_font
	ret


;font
	include "Rutina_borde_CPC_Font_4x5.ASM"
	