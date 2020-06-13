;;	DEFINES for Routine PRINT BORDE CPC by Spirax
;;-------------------------------------------------------------------

;--------------------------------------------------------------------
;; this is the value for the scroll speed
pausaentreletras 	EQU 8
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;; this is the address where the code for the lines will be generated
;; we need 160 bytes Free somewhere on memory ;)
linea1 			EQU #8400
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;; Colors for the letters and Border 
colorborde1		EQU #54	;BLACK
colorletra1		EQU #52	;BRIGHT_GREEN
colorletra2		EQU #53	;BRIGHT_CYAN
colorletra3		EQU #4A	;BRIGHT_YELLOW
colorletra4		EQU #4B	;BRIGHT_WHITE
;;      WHITE =            #40;
;;      SEA_GREEN =        #42;
;;      PASTEL_YELLOW =    #43;
;;      BLUE =             #44;
;;      PURPLE =           #45;
;;      CYAN =             #46;
;;      PINK =             #47;
;;      BRIGHT_YELLOW =    #4A;
;;      BRIGHT_WHITE =     #4B;
;;      BRIGHT_RED =       #4C;
;;      BRIGHT_MAGENTA =   #4D;
;;      ORANGE =           #4E;
;;      PASTEL_MAGENTA =   #4F;
;;      BRIGHT_GREEN =     #52;
;;      BRIGHT_CYAN =      #53;
;;      BLACK =            #54;
;;      BRIGHT_BLUE =      #55;
;;      GREEN =            #56;
;;      SKY_BLUE =         #57;
;;      MAGENTA =          #58;
;;      PASTEL_GREEN =     #59;
;;      LIME =             #5A;
;;      PASTEL_CYAN =      #5B;
;;      RED =              #5C;
;;      MAUVE =            #5D;
;;      YELLOW =           #5E;
;;      PASTEL_BLUE =      #5F;	
;--------------------------------------------------------------------


;********************************************************************
;; no more values need to be modified from this line	
;********************************************************************
linea2 			EQU linea1+29
linea3			EQU linea2+29
linea4			EQU linea3+29
linea5			EQU linea4+29
	
interrupcion_anterior 	EQU linea5+29 ;DW
cambio_interrupcion 	EQU interrupcion_anterior+2 ;DW

direcciontexto 		EQU cambio_interrupcion+2 ;DW
textoactual 		EQU direcciontexto+2 ;DW
contadorinterrupcion	EQU textoactual+2


pixelesrotar 		EQU contadorinterrupcion+1
ultimocaracter 		EQU pixelesrotar+1
colortexto 		EQU ultimocaracter+1
colorletra 		EQU colortexto+1
rotacion 		EQU colorletra+1
contadorpausaentreletras 	EQU rotacion+1
impresion_borde		EQU contadorpausaentreletras+1

;********************************************************************
