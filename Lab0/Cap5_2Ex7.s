; Cap 5.2, Ex.7: soma de (i+j) em que 3i+j-17>0
; R0 = i: laço externo, 0 a 30
; R1 = j: laço interno, 0 a 30
; R2 = soma acumulada-resultado final
; R3 = 3*i 
; R4 = auxiliar, vale 3*i+j-17
; R5 = auxiliar, vale i+j

		AREA reset, READONLY
		DCD 0
		DCD inicio

		AREA principal, CODE, READONLY
		ENTRY

inicio
		MOV R2, #0      ; soma = 0
		MOV R0, #0      ; i = 0

for_i
		CMP R0, #30
		BGT fim_for_i  ; se i > 30, encerra o laço externo
		
		; Cálculo de 3*i
		ADD R3, R0, R0  ; R3 = 2*i
		ADD R3, R3, R0  ; R3 = 3*i
		
		MOV R1, #0      ; j = 0 (reiniciar a cada i)

for_j
		CMP R1, #30
		BGT fim_for_j  ; se j > 30, encerra o laço interno
		
		ADDS R4, R3, R1 ; R4 = 3i + j
		SUBS R4, R4, #17; R4 = 3i + j - 17
		BLE prox_j      ; se <= 0, não soma, pula pro próximo j
		
		ADDS R5, R0, R1 ; R5 = i + j
		ADDS R2, R2, R5 ; acumula na soma total

prox_j
		ADDS R1, R1, #1 ; j++
		B for_j

fim_for_j
		ADDS R0, R0, #1 ; i++
		B for_i

fim_for_i
		NOP             ; R2 contém o resultado final
		END