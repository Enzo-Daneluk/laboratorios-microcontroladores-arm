; Exercícios 7, 8 e 9 (Cap. 1) - y(x) = 3a + 2x + b
; a=13, b=-11, x=4 , via STR: exerc 7
; R1=a, R2=x, R3=b, R4=3a, R5=2x, R6=y: exerc 8 
; R0 = y, resultado final: exerc 9

		AREA reset,READONLY
		DCD 0
		DCD inicio
		
		AREA dados,DATA,READWRITE
a 		DCD 0
b 		DCD 0
x 		DCD 0

		AREA principal,CODE,READONLY
		ENTRY
inicio
; exercicio 7: inicializa as variáveis via STR
		LDR R0,=a
		MOV R7,#13
		STR R7,[R0] ; a = 13
		
		LDR R0,=b
		MOV R7,#-11
		STR R7,[R0] ; b = -11
		
		LDR R0,=x
		MOV R7,#4
		STR R7,[R0] ; x = 4
		
; exercicio 8: calcula y = 3a + 2x + b
		LDR R0,=a
		LDR R1,[R0] ; R1 = a
		LDR R0,=x
		LDR R2,[R0] ; R2 = x
		LDR R0,=b
		LDR R3,[R0] ; R3 = b
		
		ADDS R4,R1,R1 ; R4 = a+a = 2a
		ADDS R4,R4,R1 ; R4 = 2a+a = 3a
		ADDS R5,R2,R2 ; R5 = x+x = 2x
		
		ADDS R6,R4,R5 ; R6 = 3a+2x
		ADDS R6,R6,R3 ; R6 = 3a+2x+b = y

;exercicio 9: resultado final de y em R0
		MOV R0,R6 ; R0 = y
final
		B final
		END
