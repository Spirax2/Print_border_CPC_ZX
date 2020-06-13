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

	ld hl, (cambio_interrupcion)
	call salta_interrupcion_hl	;5	call the code for interrupt on HL

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
salta_interrupcion_hl
	jp (hl)
;------------------------------------------------------------
;------------------------------------------------------------



;inicia las interrupciones
;Guarda la direccion actual de salto de interrupcion para poder restaurarlo despues
;ENTRADA --
;SALIDA  -- nuevo vector de interrupciones
;MODIFICA AF, HL, BC
int_init:
	di				;disable interrupts
	im 1				
	ld hl, (#39)			;take actual interrupt Jump
	ld (interrupcion_anterior), hl	;save it for later restore

	ld hl, interrupcion_none	;address for none interrupt code
	ld (cambio_interrupcion), hl	;place it for next junp on ISR 

	;reiniciamos la interrupcion
	ld hl, #38
	ld (hl), #C3			;place JP opt code on RST #38
	inc l
	ld (hl), interrupcion_ISR and #FF	;Place low address of ISR on #39
	inc l
	ld (hl), interrupcion_ISR/#FF	;Place High address of ISR on #3A
	ei				;enable interrupts

	call wait_vsync			;wait for Vertical Sync signal
	halt				;wait for new interrupt
	halt				;wait for new interrupts
	call wait_vsync			;wait for Vertical Sync signal

	xor a 
	ld (contadorinterrupcion), a	;reset the interrupt counter
	ld hl, interrupcion1_general	;address for the 1st interrupt code
	ld (cambio_interrupcion),hl	;place it for next junp on ISR 
	ret				;and return

;Restaura la interrupciones a su salto anterior
;previamente se han tenido que iniciar con int_init
;ENTRADA --  
;SALIDA  --
;MODIFICA HL
int_restore:
	di
	ld hl, (interrupcion_anterior)
	ld (#39), hl
	ei
	ret

;Espera el syncronismo Vertical
;ENTRADA --
;SALIDA  Al encontrar el sincronismo Vertical
;MODIFICA AF, BC
wait_vsync:
	ld b, #F5			;PPI Port B
wait_vsync_loop:                                   
        in a, (c)			;read port
        rra  
        jr nc,wait_vsync_loop		;check for Vsync bit
        ret


;---------------------------
;INTERRUPCION 1 GENERAL
;---------------------------
interrupcion1_general:
	;codigo interrupcion

	; play music, if needed
;	ld a, (music_playing)
;	and a
;	call nz, MUSIC_Play

;	call keyscan	





	;preparamos la siguiente interrupcion
	ld hl, interrupcion2_general
	jr end_interrupcion


;---------------------------
;INTERRUPCION 2 GENERAL
;---------------------------
interrupcion2_general:
	;codigo interrupcion
	ld a, (impresion_borde)
	or a					;check var impresion_borde
	jr z, saltar_print_letras_borde2	;if 0 skip print

	ld b, 8
pausa_sincronizacioni2:				;this is just an adjust for timming
	djnz pausa_sincronizacioni2

	call print_letras_borde		

saltar_print_letras_borde2:
	;additional interrupt code


	;preparamos la siguiente interrupcion
	ld hl, interrupcion3_general
	jr end_interrupcion


;---------------------------
;INTERRUPCION 3 GENERAL
;---------------------------
interrupcion3_general:
	;codigo interrupcion
	ld a, (impresion_borde)
	or a					;check var impresion_borde
	jr z, saltar_cambia_outs_general	;if 0 no need to change the OUTS

	ld a, (contadorpausaentreletras)
	dec a					;check counter for pause
	jr nz, seguimos_con_los_mismos_out	;if no 0 skip change OUTS

	call cambia_outs			;if 0 change the OUTS for the next letters
	ld a, pausaentreletras			;restart counter value

seguimos_con_los_mismos_out:
	ld (contadorpausaentreletras), a	;store the counter back

saltar_cambia_outs_general:
	;additional interrupt code



	;preparamos la siguiente interrupcion
	ld hl, interrupcion4_general

end_interrupcion:
	ld (cambio_interrupcion), hl
	ret


;---------------------------
;INTERRUPCION 4 GENERAL
;---------------------------
interrupcion4_general:
	;codigo interrupcion


	;preparamos la siguiente interrupcion
	ld hl, interrupcion5_general
	jr end_interrupcion

;---------------------------
;INTERRUPCION 5 GENERAL
;---------------------------
interrupcion5_general:
	;codigo interrupcion



	;preparamos la siguiente interrupcion
	ld hl, interrupcion6_general
	jr end_interrupcion


;---------------------------
;INTERRUPCION 6 GENERAL
;---------------------------
interrupcion6_general:
	;codigo interrupcion



	;preparamos la primera interrupcion
	ld hl, interrupcion1_general
	jr end_interrupcion

