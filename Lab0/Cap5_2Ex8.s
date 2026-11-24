; Seção 5.2, Ex.8: busca 0x7E570170 entre 0x20000000 e 0x20000100
; R0 = endereço atual da varredura
; R1 = endereço limite superior
; R2 = constante procurada (0x7E570170)
; R3 = resultado (endereço encontrado, ou 0 se não achar)
; R4 = valor lido da memória

		AREA reset, READONLY
		DCD 0
		DCD inicio

		AREA principal, CODE, READONLY
		ENTRY

inicio
		LDR R0, =0x20000000   ; Ponteiro inicial
		LDR R1, =0x20000100   ; Ponteiro limite
		LDR R2, =0x7E570170   ; Valor procurado
		MOV R3, #0            ; R3 = 0 ,não encontrado

busca
		CMP R0, R1
		BGT fim_busca         ; Se R0 > R1, encerra a busca

		LDR R4, [R0]          ; Lê palavra de 32 bits da memória
		CMP R4, R2
		BEQ achou             ; Se encontrou o valor, vai para achou

		ADDS R0, R0, #4       ; Incrementa 4 bytes (próxima word)
		B busca

achou
		MOV R3, R0            ; Salva o endereço onde foi encontrada em R3

fim_busca
		NOP                   ; R3 conterá 0x20000040 ao final do teste
final
		B final
		END