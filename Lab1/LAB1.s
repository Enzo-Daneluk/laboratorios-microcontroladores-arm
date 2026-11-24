		AREA reset,READONLY
		
		DCD 0
		DCD inicio
		
		AREA ctes,DATA,READWRITE
	
orig	EQU 0x20000400
prim	EQU 0x20000500
		
		AREA codigo,CODE,READONLY
		
inicio
		; fase 0 : inicializar todos os valores originais na força bruta
		LDR R0,=orig
		MOV R1,#193
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#63
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#176
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#127
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#43
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#13
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#211
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#3
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#203
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#5
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#21
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#7
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#206
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#245
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#157
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#237
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#241
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#105
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#252
		STR R1,[R0]
		
		ADD R0,R0,#4
		MOV R1,#19
		STR R1,[R0]
	
	; -------- fase 1 : bubbleSort na lista original --------
		
		LDR R0, =orig
		MOV R1,#20 	; tam da lista
		LSL R1,R1, #2           ;multiplica por 4 para o byte count 
		MOV R2, #0              ;contador do loop externo, inicializado
		;R3 contador do loop interno
		;R4 tamanho do loop interno
		;R5 índice reserva para o vetor
		;R6 primeiro em par
		;R10 segundo em par
		;R8 n comparacoes
							
loop_externo
		MOV R3, #0             ; reseta contador do loop interno
		SUB R4, R1, R2         ; seta o máximo do loop interno para tamanho - contador_loop_externo
		SUB R4, R4, #4         ; menos 4 para o vetor
		MOV R8, #0             ;
				
loop_interno
		ADD R9, R0, R3
		LDR R6, [R9]        ; carrega primeiro valor, base mais índice
		ADD R5, R3, #4         ; gera o indice para o segundo indice de comparação]
		ADD R9, R5, R0
		LDR R10, [R9]        ; carrega segundo valor
		CMP R6,R10
		BGT swap
		B continue_loop_interno
swap
		ADD R9, R0, R3
		STR R10, [R9]
		ADD R9, R0, R5
		STR R6, [R9]
		MOV R8, #1

continue_loop_interno
		ADD R3, R3,#4
		CMP R3,R4
		BLT loop_interno        ; verifica se chegou ao fim

continue_loop_externo
		CMP R8, #0
		BEQ prox                  ; termina se não houve comparações, vetor ordenado
		ADD R2, R2, #4
		CMP R2, R1
		BGT prox
		B loop_externo
	
		; -------- fase 2 : varrer o ordenado e buscar por primos pra ir pra lista de primos ------------------
prox

		MOV R0,#0 		; R0 será o contador de primos
		LDR R1,=prim	; R1 guarda o end da lista de primos
		
		; varre o ordenado
		LDR R7,=orig	; r7=i
		ADD R6,R7,#80	; r6=n
loop	CMP R7,R6		; i>n?
		BGT fim		; sim->fim , nao->verifica se é primo
		
		LDR R5,[R7] ; carrega ram[r7] em r5
		MOV R4,#2	; R4=1
next	ADD R4,R4,#1 ; R4++
		CMP R4,R5	; R4>R5?
		BEQ primo	; sim -> nao tem multiplo, é primo , nao -> confere se r4 é multiplo
		UDIV R3,R5,R4	; R3 = (int) R5/R4
		MUL R3,R3,R4	; R3 = 	R3*R4
		CMP R3,R5		; R3=R5?
		BEQ nprimo		; sim -> nao e primo (multiplo) , nao -> ve o proximo r4
		B next
		
primo	;nao achou multiplo, r5 é primo, vai pro novo vetor
		ADD R0,R0,#1 	; R0++
		STR R5,[R1]		; RAM[primos] = R5
		ADD R1,R1,#4	; R1+=4
		
nprimo	ADD R7,R7,#4	; r7++
		B loop
		
fim		NOP
		B fim
		
		END