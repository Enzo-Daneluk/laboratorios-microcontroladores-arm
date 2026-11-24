; Exercício 3 (Cap. 1) - soma de 1 a 12
; R0 = acumulador da soma

		AREA reset,READONLY
		DCD 0
		DCD inicio

		AREA principal,CODE,READONLY
		ENTRY
inicio

		MOV R0,#0 ; R0 = soma, inicia zerada
		ADDS R0,R0,#1 ; soma o termo 1 -> R0=1, depois 2, 3...
		ADDS R0,R0,#2 
		ADDS R0,R0,#3 
		ADDS R0,R0,#4 
		ADDS R0,R0,#5 
		ADDS R0,R0,#6 
		ADDS R0,R0,#7 
		ADDS R0,R0,#8 
		ADDS R0,R0,#9 
		ADDS R0,R0,#10 
		ADDS R0,R0,#11 
		ADDS R0,R0,#12 ; soma o termo 12 -> R0=78 (resultado final)

final
		B final ; loop infinito para observar o resultado
		END
