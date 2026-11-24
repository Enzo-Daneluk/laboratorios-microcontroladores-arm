; =====================================================================
;  LAB 2 - Dois padroes de leds controlados pelas chaves
;  Placa: EK-TM4C1294XL
;
;  Leds (da esquerda para a direita):  D1 = PN1, D2 = PN0, D3 = PF4, D4 = PF0
;  Chaves: USR_SW1 = PJ0, USR_SW2 = PJ1 (com pull-up: apertada = 0)
;
;  USR_SW1: troca o padrao (passeio do cavaleiro <-> contagem binaria)
;  USR_SW2: troca o tempo de cada estado (1000 ms -> 500 ms -> 200 ms -> 1000 ms)
;
;  Registradores usados pelo programa principal (guardam o estado):
;    R4 = padrao atual (0 = cavaleiro, 1 = contagem binaria)
;    R5 = passo atual do padrao (cavaleiro: 0 a 5, contagem: 0 a 15)
;    R6 = tempo de cada estado, em ms (1000, 500 ou 200)
;    R7 = leitura anterior das chaves (para saber quando uma foi apertada)
;    R8 = quantos ms ja se passaram no estado atual
;    R9 = auxiliar (endereco da tabela do cavaleiro)
;    R10 = 1 se alguma chave foi apertada nesta leitura, 0 se nao
; =====================================================================

; =============================
;  DEFINICOES DE REGISTROS I/O
; =============================

SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_PRGPIO_R         EQU 0x400FEA08
GPIO_PORTN_AHB_DIR_R    EQU 0x40064400
GPIO_PORTN_AHB_AFSEL_R  EQU 0x40064420
GPIO_PORTN_AHB_DEN_R    EQU 0x4006451C
GPIO_PORTN_AHB_AMSEL_R  EQU 0x40064528
GPIO_PORTN_AHB_DATA_R   EQU 0x400643FC
GPIO_PORTF_AHB_DIR_R    EQU 0x4005D400
GPIO_PORTF_AHB_AFSEL_R  EQU 0x4005D420
GPIO_PORTF_AHB_DEN_R    EQU 0x4005D51C
GPIO_PORTF_AHB_AMSEL_R  EQU 0x4005D528
GPIO_PORTF_AHB_DATA_R   EQU 0x4005D3FC
GPIO_PORTJ_AHB_DIR_R    EQU 0x40060400
GPIO_PORTJ_AHB_AFSEL_R  EQU 0x40060420
GPIO_PORTJ_AHB_PUR_R    EQU 0x40060510
GPIO_PORTJ_AHB_DEN_R    EQU 0x4006051C
GPIO_PORTJ_AHB_AMSEL_R  EQU 0x40060528
GPIO_PORTJ_AHB_DATA_R   EQU 0x400603FC
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018

; =============================
;  TABELA DO PASSEIO DO CAVALEIRO
; =============================
; Cada byte e um estado: b3 = D1, b2 = D2, b1 = D3, b0 = D4

        AREA    dados, DATA, READONLY
cavaleiro
        DCB     2_1000, 2_0100, 2_0010, 2_0001, 2_0010, 2_0100

; =============================
;       PROGRAMA PRINCIPAL
; =============================

        AREA    principal, CODE, READONLY
        EXPORT  main

main
        BL      inicia_GPIO
        BL      inicia_systick

        MOV     R4, #0              ; comeca no passeio do cavaleiro
        MOV     R5, #0              ; no primeiro passo
        LDR     R6, =1000           ; com 1000 ms por estado
        BL      le_chaves
        MOV     R7, R0              ; guarda como as chaves estao agora

mostra_estado
        ; --- descobre o padrao de 4 bits do passo atual
        CMP     R4, #0
        BNE     padrao_contagem
        LDR     R9, =cavaleiro      ; cavaleiro: pega o byte da tabela
        LDRB    R0, [R9, R5]        ; R0 = cavaleiro[R5]
        B       acende
padrao_contagem
        MOV     R0, R5              ; contagem: o proprio numero e o padrao
acende
        BL      display_leds
        MOV     R8, #0              ; comeca a contar o tempo deste estado

espera
        ; --- espera em pedacos de 10 ms, olhando as chaves entre eles
        MOV     R0, #10
        BL      wait_ms
        ADD     R8, R8, #10         ; mais 10 ms se passaram

        BL      le_chaves           ; R0 = chaves agora (b0 = SW1, b1 = SW2)
        MOV     R10, #0             ; ainda nenhuma chave foi apertada

        ; --- SW1 acabou de ser apertada? (antes solta = 1, agora apertada = 0)
        TST     R7, #2_01
        BEQ     ve_sw2              ; ja estava apertada antes: ignora
        TST     R0, #2_01
        BNE     ve_sw2              ; continua solta: nada a fazer
        EOR     R4, R4, #1          ; troca o padrao (0 vira 1, 1 vira 0)
        MOV     R5, #0              ; o novo padrao comeca do primeiro passo
        MOV     R10, #1

ve_sw2
        ; --- SW2 acabou de ser apertada?
        TST     R7, #2_10
        BEQ     fim_chaves
        TST     R0, #2_10
        BNE     fim_chaves
        CMP     R6, #1000           ; troca o tempo: 1000 -> 500 -> 200 -> 1000
        BNE     nao_era_1000
        MOV     R6, #500
        B       tempo_trocado
nao_era_1000
        CMP     R6, #500
        BNE     nao_era_500
        MOV     R6, #200
        B       tempo_trocado
nao_era_500
        LDR     R6, =1000
tempo_trocado
        MOV     R10, #1

fim_chaves
        MOV     R7, R0              ; guarda a leitura para comparar na proxima vez
        CMP     R10, #1
        BEQ     mostra_estado       ; apertou alguma chave: muda na hora

        CMP     R8, R6
        BLO     espera              ; ainda nao deu o tempo do estado

        ; --- deu o tempo: vai para o proximo passo
        ADD     R5, R5, #1
        CMP     R4, #0
        BNE     proximo_contagem
        CMP     R5, #6              ; cavaleiro tem 6 passos (0 a 5)
        BLO     mostra_estado
        MOV     R5, #0
        B       mostra_estado
proximo_contagem
        AND     R5, R5, #2_1111     ; contagem: depois do 15 volta para 0
        B       mostra_estado

; ========================
;  INICIALIZACAO DA GPIO
; ========================

inicia_GPIO
        ; 1. Ativa o clock dos ports N (bit 12), J (bit 8) e F (bit 5)
        LDR     R0, =SYSCTL_RCGCGPIO_R
        LDR     R1, [R0]
        LDR     R2, =0x00001120     ; N = bit 12, J = bit 8, F = bit 5
        ORR     R1, R1, R2
        STR     R1, [R0]

        ; 2. Espera os TRES ports ficarem prontos
        LDR     R0, =SYSCTL_PRGPIO_R
espera_ativar
        LDR     R1, [R0]
        AND     R1, R1, R2          ; isola os bits 12, 8 e 5
        CMP     R1, R2              ; os tres ja estao em 1?
        BNE     espera_ativar

        ; 3. Port N: PN1 e PN0 (bits 1 e 0) como saidas digitais
        LDR     R0, =GPIO_PORTN_AHB_DIR_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTN_AHB_AFSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTN_AHB_DEN_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTN_AHB_AMSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011
        STR     R1, [R0]

        ; 4. Port F: PF4 e PF0 (bits 4 e 0) como saidas digitais
        LDR     R0, =GPIO_PORTF_AHB_DIR_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00010001
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTF_AHB_AFSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00010001
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTF_AHB_DEN_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00010001
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTF_AHB_AMSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00010001
        STR     R1, [R0]

        ; 5. Port J: PJ1 e PJ0 (bits 1 e 0) como entradas digitais com pull-up
        LDR     R0, =GPIO_PORTJ_AHB_DIR_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011 ; 0 = entrada
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTJ_AHB_DEN_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011
        STR     R1, [R0]
        LDR     R0, =GPIO_PORTJ_AHB_PUR_R
        LDR     R1, [R0]
        ORR     R1, R1, #2_00000011 ; liga o pull-up (chave solta le 1)
        STR     R1, [R0]

        BX      LR

; ==============================================
;  DISPLAY_LEDS - mostra um padrao de 4 bits
; ==============================================
; Entrada: R0 = padrao, do led da esquerda para o da direita:
;          b3 = D1 (PN1), b2 = D2 (PN0), b1 = D3 (PF4), b0 = D4 (PF0)
; Nao altera nenhum registrador (salva e restaura R1, R2 e R3)

display_leds
        PUSH    {R1, R2, R3}

        ; --- port N: b3 vai para PN1 e b2 vai para PN0
        LSR     R1, R0, #2          ; desce b3 e b2 para os bits 1 e 0
        AND     R1, R1, #2_11
        LDR     R2, =GPIO_PORTN_AHB_DATA_R
        LDR     R3, [R2]            ; le
        BIC     R3, R3, #2_00000011 ; limpa PN1 e PN0
        ORR     R3, R3, R1          ; coloca os bits novos
        STR     R3, [R2]            ; escreve

        ; --- port F: b1 vai para PF4 e b0 vai para PF0
        AND     R1, R0, #2_01       ; b0 ja esta na posicao do PF0
        TST     R0, #2_10           ; b1 esta em 1?
        BEQ     sem_D3
        ORR     R1, R1, #2_00010000 ; sim: liga o PF4
sem_D3
        LDR     R2, =GPIO_PORTF_AHB_DATA_R
        LDR     R3, [R2]            ; le
        BIC     R3, R3, #2_00010001 ; limpa PF4 e PF0
        ORR     R3, R3, R1          ; coloca os bits novos
        STR     R3, [R2]            ; escreve

        POP     {R1, R2, R3}
        BX      LR

; ==============================================
;  LE_CHAVES - le as duas chaves do port J
; ==============================================
; Saida: R0 = b0 com SW1 (PJ0) e b1 com SW2 (PJ1); 1 = solta, 0 = apertada
; Altera so o R0

le_chaves
        LDR     R0, =GPIO_PORTJ_AHB_DATA_R
        LDR     R0, [R0]            ; le o port J inteiro
        AND     R0, R0, #2_11       ; fica so com PJ1 e PJ0
        BX      LR

; ==========================
;  INICIALIZACAO DO SYSTICK
; ==========================

inicia_systick
        PUSH    {R0, R1}
        LDR     R1, =NVIC_ST_CTRL_R
        MOV     R0, #0x05           ; Habilita temporizador + Clock do sistema
        STR     R0, [R1]
        POP     {R0, R1}
        BX      LR

; ============================
;   TEMPORIZACAO PARA ESPERA
; ============================

wait_ms
        PUSH    {R1, R2, R3}

        LDR     R1, =NVIC_ST_RELOAD_R
        LDR     R2, =15999          ; 16000 ciclos = 1 ms (a 16 MHz)
        STR     R2, [R1]

        ; Zera o registrador CURRENT para forcar recarga imediata
        LDR     R3, =NVIC_ST_CURRENT_R
        MOV     R2, #0
        STR     R2, [R3]

        LDR     R1, =NVIC_ST_CTRL_R

timer_1_ms
wait_loop
        LDR     R2, [R1]
        TST     R2, #0x00010000     ; Testa Bit 16 (COUNTFLAG)
        BEQ     wait_loop

        ADDS    R0, R0, #-1
        BNE     timer_1_ms

        POP     {R1, R2, R3}
        BX      LR

        END