; Exercício 4 (Cap. 1): (12+23)+(-51-7)+8
; R3 = primeiro parenteses (12+23)
; R6 = segundo parenteses (-51-7)
; R7 = soma dos dois parenteses
; R0 = resultado final

		AREA reset,READONLY
		DCD 0
		DCD inicio

		AREA principal,CODE,READONLY
		ENTRY
inicio
		MOV R1,#12
		MOV R2,#23
		ADDS R3,R1,R2 ; R3 = 12+23 = 35 (1o parênteses)
		
		MOV R4,#-51
		MOV R5,#7
		SUBS R6,R4,R5 ; R6 = -51-7 = -58 (2o parênteses)
		
		ADDS R7,R3,R6 ; R7 = 35+(-58) = -23
		
		MOV R0,#8
		ADDS R0,R7,R0 ; R0 = -23+8 = -15 (resultado final)
final
		B final
		END
