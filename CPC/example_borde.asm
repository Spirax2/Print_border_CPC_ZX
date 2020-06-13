
	include "Rutina_borde_CPC_Defines.asm"

	org $8000
arranca:
	call int_init		;reinicia las interrupciones para impresion_borde


	ld hl, texto0		;TEXTO que queremos imprimir
	call init_border_efect	;INICIA el efecto Borde

  
check_keyb:
	halt
	;; read keyboard
	ld bc, #F40E    ;Select Ay reg 14 on ppi port A
	out (c), c
	ld bc, #F792    ;PPI port A in/C out 
        out (c), c      
        ld bc, #F648	;line keyboard 8
        out (c), c

 
	ld b, #F4	;PPI port A 
	in a, (c)	
	and #04		;check ESC key 
	jr nz, check_keyb	;if not preseed repeat loop



	call stop_border_efect	;desactiva la impresion del borde
	jp int_restore		;restaura interrupcion anterior y retorna


texto0:
	defb "   IMPRESION EN BORDE BY SPIRAX   ",0
endtexto0:

	include "interrupciones_CPC.asm"
	include "Rutina_borde_CPC.asm"
  display "Final rutina ",/d,$, " Bytes ",/d,$ - arranca
	
