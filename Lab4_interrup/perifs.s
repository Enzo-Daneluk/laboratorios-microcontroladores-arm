	EXPORT config_perifs

        AREA |.text|, CODE, READONLY
        THUMB

SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_PRGPIO_R         EQU 0x400FEA08

GPIO_PORTN_AHB_DIR_R    EQU 0x40064400
GPIO_PORTN_AHB_AFSEL_R  EQU 0x40064420
GPIO_PORTN_AHB_DEN_R    EQU 0x4006451C
GPIO_PORTN_AHB_AMSEL_R  EQU 0x40064528

GPIO_PORTJ_AHB_DIR_R    EQU 0x40060400
GPIO_PORTJ_AHB_AFSEL_R  EQU 0x40060420
GPIO_PORTJ_AHB_PUR_R    EQU 0x40060510
GPIO_PORTJ_AHB_DEN_R    EQU 0x4006051C
GPIO_PORTJ_AHB_AMSEL_R  EQU 0x40060528

GPIO_PORTK_AHB_DIR_R    EQU 0x40061400
GPIO_PORTK_AHB_AFSEL_R  EQU 0x40061420
GPIO_PORTK_AHB_DEN_R    EQU 0x4006151C
GPIO_PORTK_AHB_AMSEL_R  EQU 0x40061528

GPIO_PORTM_AHB_DIR_R    EQU 0x40063400
GPIO_PORTM_AHB_AFSEL_R  EQU 0x40063420
GPIO_PORTM_AHB_PUR_R    EQU 0x40063510
GPIO_PORTM_AHB_DEN_R    EQU 0x4006351C
GPIO_PORTM_AHB_AMSEL_R  EQU 0x40063528

config_perifs
        ;ativa o clock dos ports N, M, K e J
        LDR R0, =SYSCTL_RCGCGPIO_R
        LDR R1, [R0]
        LDR R2, =2_1101100000000
        ORR R1, R1, R2
        STR R1, [R0]

        ; Aguarda gpio estar pronta
        LDR R0, =SYSCTL_PRGPIO_R
espera
        LDR R1, [R0]
        AND R1, R1, R2
        CMP R1, R2
        BNE espera

        ;port N pn0 e pn1 sao saidas
        LDR R0, =GPIO_PORTN_AHB_DIR_R
        LDR R1, [R0]
        ORR R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTN_AHB_AFSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTN_AHB_DEN_R
        LDR R1, [R0]
        ORR R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTN_AHB_AMSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        ;port J pj0 e pj1 sao entradas pull-up
        LDR R0, =GPIO_PORTJ_AHB_DIR_R
        LDR R1, [R0]
        BIC R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_AFSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_DEN_R
        LDR R1, [R0]
        ORR R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_AMSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_PUR_R
        LDR R1, [R0]
        ORR R1, R1, #3
        STR R1, [R0]

        ;port K pk7  saida
        LDR R0, =GPIO_PORTK_AHB_DIR_R
        LDR R1, [R0]
        ORR R1, R1, #0x80
        STR R1, [R0]

        LDR R0, =GPIO_PORTK_AHB_AFSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTK_AHB_DEN_R
        LDR R1, [R0]
        ORR R1, R1, #0x80
        STR R1, [R0]

        LDR R0, =GPIO_PORTK_AHB_AMSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        ;port M pm0 como entrada com pull-up
        LDR R0, =GPIO_PORTM_AHB_DIR_R
        LDR R1, [R0]
        BIC R1, R1, #1
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_AFSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_DEN_R
        LDR R1, [R0]
        ORR R1, R1, #1
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_AMSEL_R
        LDR R1, [R0]
        BIC R1, R1, #0xFF
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_PUR_R
        LDR R1, [R0]
        ORR R1, R1, #1
        STR R1, [R0]

        BX LR

        END