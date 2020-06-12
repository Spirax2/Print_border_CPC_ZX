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
	ld (cambio_interrupcion),hl	;place it for next junp on ISR 

	;reiniciamos la interrupcion
	ld hl, #38
	ld (hl), #C3			;place JP opt code on RST #38
	inc l
	ld (hl), low interrupcion_ISR	;Place low address of ISR on #39
	inc l
	ld (hl), high interrupcion_ISR	;Place High address of ISR on #3A
	ei				;enable interrupts

	call wait_vsync			;wait for Vertical Sync signal
	halt				;wait for new interrupt
	halt				;wait for new interrupts
	call wait_vsync			;wait for Vertical Sync signal

	ld hl, interrupcion1_general	;address for the1st interrupt code
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
	jr end_cambio_interrupcion


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
	jr end_cambio_interrupcion


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

end_cambio_interrupcion:
	ld (cambio_interrupcion), hl
	ret


;---------------------------
;INTERRUPCION 4 GENERAL
;---------------------------
interrupcion4_general:
	;codigo interrupcion


	;preparamos la siguiente interrupcion
	ld hl, interrupcion5_general
	jr end_cambio_interrupcion

;---------------------------
;INTERRUPCION 5 GENERAL
;---------------------------
interrupcion5_general:
	;codigo interrupcion



	;preparamos la siguiente interrupcion
	ld hl, interrupcion6_general
	jr end_cambio_interrupcion


;---------------------------
;INTERRUPCION 6 GENERAL
;---------------------------
interrupcion6_general:
	;codigo interrupcion



	;preparamos la primera interrupcion
	ld hl, interrupcion1_general
	jr end_cambio_interrupcion

