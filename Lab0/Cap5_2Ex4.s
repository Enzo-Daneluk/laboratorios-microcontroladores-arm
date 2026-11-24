; Seção 5.2, Ex.4: decisão de 4 ramos
; R0=0 se R1>R2 e R3==R4
; R0=1 se R1<R2
; R0=2 se R1==R2 e R3<=R4
; R0=3 se R1==R2 e R3>R4

		AREA reset, READONLY
		DCD 0
		DCD inicio

		AREA principal, CODE, READONLY
		ENTRY

inicio
; valores para testes
		MOV R1, #5
		MOV R2, #5
		MOV R3, #3
		MOV R4, #8

		CMP R1, R2
		BLT caso1 ; R1 < R2 -> R0=1, não depende de R3/R4
		BGT maior ; R1 > R2 -> vai checar R3 vs R4

		; aqui R1 == R2
		CMP R3, R4
		BLE caso2 ; R1 == R2 e R3 <= R4 -> R0=2
		B caso3   ; R1 == R2 e R3 > R4  -> R0=3

maior
		; aqui R1 > R2
		CMP R3, R4
		BEQ caso0 ; R1 > R2 e R3 == R4 -> R0=0
		B fim     ; Se R3 != R4, ignora e vai direto para o fim

caso0
		MOV R0, #0
		B fim

caso1
		MOV R0, #1
		B fim

caso2
		MOV R0, #2
		B fim

caso3
		MOV R0, #3

fim
		NOP
final
		B final
		END