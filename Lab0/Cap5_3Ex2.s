; Cap 5.3, Ex.2: R7=a-b usando pilha para preservar R0,R1
; a = R0+R1+R2 (gravado de volta em R0)
; b = R3+R4+R5 (gravado de volta em R1)

		AREA reset, READONLY
		DCD 0x20001000  ; Ponteiro inicial da pilha (SP) no topo da RAM: se colocar 0, na hora do PUSH, explode para fora da RAM
		DCD inicio

		AREA principal, CODE, READONLY
		ENTRY

inicio
		; Valores de teste
		MOV R0, #10
		MOV R1, #20
		MOV R2, #5
		MOV R3, #1
		MOV R4, #2
		MOV R5, #3

		PUSH {R0, R1}   ; Salva R0=10 e R1=20 na pilha RAM

		ADDS R0, R0, R1
		ADDS R0, R0, R2 ; R0=a=10+20+5=35

		ADDS R1, R3, R4
		ADDS R1, R1, R5 ; R1=b=1+2+3=6

		SUBS R7, R0, R1 ; R7=35-6=29

		POP {R0, R1}    ; Restaura R0=10 e R1=20

final
		B final
		END