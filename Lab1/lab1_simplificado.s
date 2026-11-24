; ==================================================================
; LAB 1 - Primos da lista em ordem crescente
;
; Ideia do programa:
;   1) copia a lista para a RAM, a partir de 0x20000400   (item 4)
;   2) ordena essa lista com bubble sort                   (item 3)
;   3) passa pela lista ordenada e copia so os primos
;      para 0x20000500                                      (item 5)
;      - para cada numero, testa se e primo                 (item 2)
;      - o teste de primo usa o teste de multiplo           (item 1)
;   Como a lista ja foi ordenada antes, os primos ficam em
;   ordem crescente. No final, R0 = quantidade de primos.  (item 6)
;
; Registradores:
;   R0 = quantidade de primos encontrados (resultado)
;   R1 = ponteiro que le a lista
;   R2 = ponteiro que escreve (ou aponta o vizinho, na ordenacao)
;   R3 = contador de numeros / de passadas
;   R4 = divisor (itens 1 e 2) / contador de comparacoes (item 3)
;   R5 = resposta do item 2 (1 = primo, 0 = nao primo)
;   R6 = num, o numero testado no item 2
;   R7 = tam, tamanho da lista
;   R8, R9 = auxiliares
; ==================================================================

ORIGEM      EQU     0x20000400      ; lista original na RAM
DESTINO     EQU     0x20000500      ; lista de primos
TAM         EQU     20              ; quantidade de numeros da lista

            AREA    reset, READONLY
            DCD     __initial_sp    ; SP inicial
            DCD     inicio          ; primeira instrucao

            AREA    constantes, DATA, READONLY
lista       DCD     193, 63, 176, 127, 43, 13, 211, 3, 203, 5
            DCD     21, 7, 206, 245, 157, 237, 241, 105, 252, 19

            AREA    principal, CODE, READONLY
inicio

; ------------------------------------------------------------------
; ITEM 4 - copia a lista para a RAM (0x20000400)
; ------------------------------------------------------------------
            LDR     R1, =lista      ; de onde le
            LDR     R2, =ORIGEM     ; para onde copia
            MOV     R3, #TAM        ; quantos numeros copiar
copia
            LDR     R8, [R1]        ; pega um numero
            STR     R8, [R2]        ; grava na RAM
            ADD     R1, R1, #4      ; proximo numero (4 bytes)
            ADD     R2, R2, #4
            SUBS    R3, R3, #1      ; menos um
            BNE     copia

; ------------------------------------------------------------------
; ITEM 3 - bubble sort dos R7 numeros a partir de 0x20000400
; faz tam-1 passadas; em cada uma compara os tam-1 pares vizinhos
; ------------------------------------------------------------------
            MOV     R7, #TAM        ; tam = 20
            SUB     R3, R7, #1      ; R3 = passadas que faltam
passada
            LDR     R1, =ORIGEM     ; volta para o comeco da lista
            SUB     R4, R7, #1      ; R4 = comparacoes nesta passada
compara
            LDR     R8, [R1]        ; R8 = numero atual
            ADD     R2, R1, #4      ; R2 = endereco do vizinho
            LDR     R9, [R2]        ; R9 = vizinho
            CMP     R8, R9
            BLE     nao_troca       ; atual <= vizinho: ja esta em ordem
            STR     R9, [R1]        ; senao troca os dois de lugar
            STR     R8, [R2]
nao_troca
            ADD     R1, R1, #4      ; anda para o proximo par
            SUBS    R4, R4, #1
            BNE     compara
            SUBS    R3, R3, #1      ; terminou uma passada
            BNE     passada

; ------------------------------------------------------------------
; ITEM 5 - copia os primos de 0x20000400 para 0x20000500
; ------------------------------------------------------------------
            LDR     R1, =ORIGEM     ; le daqui
            LDR     R2, =DESTINO    ; escreve aqui
            MOV     R3, R7          ; vai olhar os tam numeros
            MOV     R0, #0          ; ainda nao achou nenhum primo
filtra
            LDR     R6, [R1]        ; num = numero atual

; ------------------------------------------------------------------
; ITEM 2 - num (R6) e primo? resposta em R5
; testa os divisores 2, 3, 4, ... ate num-1
; ------------------------------------------------------------------
            MOV     R5, #0          ; comeca supondo que nao e primo
            CMP     R6, #2
            BLT     fim_primo       ; 0 e 1 nao sao primos
            MOV     R4, #2          ; primeiro divisor
testa
            CMP     R4, R6
            BEQ     e_primo         ; chegou no proprio num: ninguem dividiu

; ------------------------------------------------------------------
; ITEM 1 - num (x) e multiplo de R4 (y)?
; z = x / y ; w = z * y ; se x - w = 0, x e multiplo de y
; ------------------------------------------------------------------
            UDIV    R8, R6, R4      ; z = x / y (divisao inteira)
            MUL     R9, R8, R4      ; w = z * y
            SUB     R9, R6, R9      ; diferenca x - w
            CMP     R9, #0
            BEQ     fim_primo       ; e multiplo: achou divisor, nao e primo

            ADD     R4, R4, #1      ; tenta o proximo divisor
            B       testa
e_primo
            MOV     R5, #1          ; nenhum divisor: e primo
fim_primo

; ------------------------------------------------------------------
; volta para o item 5: se for primo, copia
; ------------------------------------------------------------------
            CMP     R5, #1
            BNE     proximo         ; nao e primo: pula
            STR     R6, [R2]        ; guarda o primo em DESTINO
            ADD     R2, R2, #4
            ADD     R0, R0, #1      ; mais um primo
proximo
            ADD     R1, R1, #4      ; proximo numero da lista
            SUBS    R3, R3, #1
            BNE     filtra

; ------------------------------------------------------------------
; ITEM 6 - fim: R0 = quantidade de primos,
; primos em ordem crescente a partir de 0x20000500
; ------------------------------------------------------------------
fim
            B       fim

; pilha
            AREA    stack, NOINIT, READWRITE, ALIGN=3
stack_mem
            SPACE   0x00000200
__initial_sp
            END
