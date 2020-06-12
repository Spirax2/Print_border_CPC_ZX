;------------
;Vector de interrupciones
;se llama en cada RST #38 , 6 interrupciones por fotograma
;salta a una direccion diferente cada vez automodificando la llamada
;pudiendo ejecutar diferentes partes de codigo por interrupcion
;la rutina interrupcion_ISR debe estar en ram ya que se automodifica
;el resto de ruinas pueden estar en ROM si el codigo añadido no se automodifica
;al salir deja todos los registros como estaban
interrupcion_ISR
	di			;1	disable interrupts
	push af			;4	;backup ALL the registers
	push hl			;4
	push bc			;4
	push de			;4
	push ix			;5
	push iy			;5
	ex af,af'		;1
	push af			;4
	exx			;1
	push hl			;4
	push bc			;4
	push de			;4

cambio_interrupcion	 EQU $+1
	call interrupcion1_general	;5	call the code for interrupt

	pop de			;3	restore back ALL the registers
	pop bc			;3
	pop hl			;3
	exx			;1
	pop af			;3		
	ex af,af'		;1
	pop iy			;5
	pop ix			;5
	pop de			;3
	pop bc			;3
	pop hl			;3
	pop af			;3
	ei			;1	enable interrupts
interrupcion_none:
	ret			;3	return

;------------------------------------------------------------
;------------------------------------------------------------
