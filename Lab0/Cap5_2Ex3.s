;Cap 5.2, Ex.3: R0=1 se (R3<R4) OU (R5==R6)

		AREA reset,READONLY
		DCD 0
		DCD inicio

		AREA principal,CODE,READONLY
		ENTRY
inicio
;valores para testes
		MOV R3,#5
		MOV R4,#10
		MOV R5,#7
		MOV R6,#7
		
		CMP R3,R4
		BLT verdadeiro ; se R3<R4, satisfaz ou pula direto
		
		CMP R5,R6
		BEQ verdadeiro ; caso contrario, testa a segunda condição (R5==R6)
		
		MOV R0,#0 ; nenhuma condicao satisfeita
		B fim

verdadeiro
		MOV R0,#1 ; pelo menos uma condicao satisfeita
fim
		NOP
final
		B final
		END
