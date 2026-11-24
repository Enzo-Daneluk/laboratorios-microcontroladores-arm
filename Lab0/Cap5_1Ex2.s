;exercicio 2, cap 5.1
; Considerar inicialmente N=0 Z=0 C=0 V=0
		
		MOVS R0,#13 			; R0=13 N=0 Z=0 C=0 V=0
		MOV R1,#-51 			; R1=-51 sem S, flags não mudam, N=0 Z=0 C=0 V=0
		MOVS R2,#0 				; R2=0 N=0 Z=1 C=0 V=0
		MOVS R3,#-12 			; R3=-12 N=1 Z=0 C=0 V=0
		MOVS R4,#0xFEDCAB98 	; R4=0xFEDCAB98 N=1 Z=0 C=0 V=0
		ADDS R7,R1,R3 			; R7=R1+R3=-63 N=1 Z=0 C=1 V=0
		ADDS R7,R3,R0 			; R7=R3+R0=1 N=0 Z=0 C=1 V=0
		ADDS R7,R0,R2 			; R7=R0+R2=13 N=0 Z=0 C=0 V=0
		ADDS R7,R3,R0 			; R7=R3+R0=1 N=0 Z=0 C=1 V=0
		ADDS R5,R4,R0 			; R5=R4+R0 N=1 Z=0 C=0 V=0
		ADDS R5,R4,R1 			; R5=R4+R1 N=1 Z=0 C=1 V=0
		CMP R5,R2 				; R5-R2 (descarta) N=1 Z=0 C=1 V=0
		SUBS R6,R4,R0 			; R6=R4-R0 N=1 Z=0 C=1 V=0
		SUBS R6,R4,R1 			; R6=R4-R1 N=1 Z=0 C=0 V=0
		SUBS R6,R3,R4 			; R6=R3-R4 N=0 Z=0 C=1 V=0
