; LAB 2 - ETAPA 1: contagem binaria nos 4 leds (ainda sem os botoes)
; Placa: EK-TM4C1294XL
; Leds: D1 = PN1, D2 = PN0, D3 = PF4, D4 = PF0

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
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018

; =============================
;       PROGRAMA PRINCIPAL
; =============================

        AREA    principal, CODE, READONLY
        EXPORT  main

main
        BL      inicia_GPIO
        BL      inicia_systick
        MOV     R4, #0              ; R4 = valor da contagem (0 a 15)

conta
        MOV     R0, R4              ; padrao que vai para os leds
        BL      display_leds
        LDR     R0, =500            ; 500 ms (wait_ms estraga o R0, por isso
        BL      wait_ms             ;  a contagem fica guardada em R4)
        ADD     R4, R4, #1          ; proximo numero
        AND     R4, R4, #2_1111     ; depois do 15 volta para 0
        B       conta

; ========================
;  INICIALIZACAO DA GPIO
; ========================

inicia_GPIO
        ; 1. Ativa o clock dos ports N (bit 12) e F (bit 5)
        LDR     R0, =SYSCTL_RCGCGPIO_R
        LDR     R1, [R0]
        LDR     R2, =0x00001020     ; N = bit 12, F = bit 5
        ORR     R1, R1, R2
        STR     R1, [R0]

        ; 2. Espera os DOIS ports ficarem prontos
        LDR     R0, =SYSCTL_PRGPIO_R
espera_ativar
        LDR     R1, [R0]
        AND     R1, R1, R2          ; isola os bits 12 e 5
        CMP     R1, R2              ; os dois ja estao em 1?
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