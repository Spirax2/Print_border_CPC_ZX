;;	DEFINES for Routine PRINT BORDE CPC by Spirax
;;-------------------------------------------------------------------

;--------------------------------------------------------------------
;; this is the value for the scroll speed
	define pausaentreletras 8
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;; this is the address where the code for the lines will be generated
;; we need 160 bytes Free somewhere on memory ;)
	define linea1 		$8400
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;; Colors for the letters and Border 
	define colorborde1	$54	;BLACK
	define colorletra1	$52	;BRIGHT_GREEN
	define colorletra2	$53	;BRIGHT_CYAN
	define colorletra3	$4A	;BRIGHT_YELLOW
	define colorletra4	$4B	;BRIGHT_WHITE
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
	define linea2 		linea1+29
	define linea3		linea2+29
	define linea4		linea3+29
	define linea5		linea4+29
	
	define interrupcion_anterior linea5+29 ;DW

	define direcciontexto 	interrupcion_anterior+2 ;DW
	define textoactual 	direcciontexto+2 ;DW
	define contadorinterrupcion	textoactual+2


	define pixelesrotar 	contadorinterrupcion+1
	define ultimocaracter 	pixelesrotar+1
	define colortexto 	ultimocaracter+1
	define colorletra 	colortexto+1
	define rotacion 	colorletra+1
	define contadorpausaentreletras rotacion+1
	define impresion_borde	contadorpausaentreletras+1
;********************************************************************
