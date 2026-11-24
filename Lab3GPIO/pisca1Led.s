; Pisca o LED D1 (PN1) a 1 Hz
; Placa: EK-TM4C1294XL (Tiva C Series)

; =============================
;  DEFINIÇÕES DE REGISTROS I/O
; =============================

SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_PRGPIO_R         EQU 0x400FEA08
GPIO_PORTN_AHB_DIR_R    EQU 0x40064400
GPIO_PORTN_AHB_AFSEL_R  EQU 0x40064420
GPIO_PORTN_AHB_DEN_R    EQU 0x4006451C
GPIO_PORTN_AHB_AMSEL_R  EQU 0x40064528
GPIO_PORTN_AHB_DATA_R   EQU 0x400643FC
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
        LDR     R1, =GPIO_PORTN_AHB_DATA_R

loop_infinito
        LDR     R2, [R1]
        ORR     R2, R2, #2_00000010 ; Bit 1 = PN1 (LED D1)
        STR     R2, [R1]            ; Acende LED D1
        LDR     R0, =500            ; 500 ms
        BL      wait_ms
        
        LDR     R2, [R1]
        BIC     R2, R2, #2_00000010
        STR     R2, [R1]            ; Apaga LED D1
        LDR     R0, =500            ; 500 ms
        BL      wait_ms
        
        B       loop_infinito

; ========================
;  INICIALIZAÇÃO DA GPIO
; ========================

inicia_GPIO
        ; 1. Ativa o clock do Port N (Bit 12 = 0x1000)
        LDR     R0, =SYSCTL_RCGCGPIO_R
        LDR     R1, [R0]
        ORR     R1, R1, #0x1000     
        STR     R1, [R0]

        ; 2. Espera APENAS o Port N ficar pronto (Bit 12)
        LDR     R0, =SYSCTL_PRGPIO_R
        LDR     R1, =0x00001000     ; Máscara isolada do Port N
espera_ativar
        LDR     R2, [R0]
        AND     R2, R2, R1         ; Isola apenas o Bit 12
        CMP     R2, R1             ; Testa se o Port N ativou
        BNE     espera_ativar

        ; 3. Configura direção PN1 como saída
        LDR     R0, =GPIO_PORTN_AHB_DIR_R
        LDR     R1, [R0]
        ORR     R1, R1, #0x02       ; Seta pino PN1
        STR     R1, [R0]

        ; 4. Desabilita função alternativa no PN1
        LDR     R0, =GPIO_PORTN_AHB_AFSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #0x02       
        STR     R1, [R0]

        ; 5. Habilita função digital no PN1
        LDR     R0, =GPIO_PORTN_AHB_DEN_R
        LDR     R1, [R0]
        ORR     R1, R1, #0x02       
        STR     R1, [R0]

        ; 6. Desabilita função analógica no PN1
        LDR     R0, =GPIO_PORTN_AHB_AMSEL_R
        LDR     R1, [R0]
        BIC     R1, R1, #0x02       
        STR     R1, [R0]

        BX      LR

; ==========================
;  INICIALIZAÇÃO DO SYSTICK
; ==========================

inicia_systick
        PUSH    {R0, R1}
        LDR     R1, =NVIC_ST_CTRL_R
        MOV     R0, #0x05           ; Habilita temporizador + Clock do sistema
        STR     R0, [R1]
        POP     {R0, R1}
        BX      LR

; ============================
;   TEMPORIZAÇÃO PARA ESPERA
; ============================

wait_ms
        PUSH    {R1, R2, R3}
        
        LDR     R1, =NVIC_ST_RELOAD_R
        LDR     R2, =15999          ; 16000 ciclos = 1 ms (a 16 MHz)
        STR     R2, [R1]
        
        ; Zera o registrador CURRENT para forçar recarga imediata
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