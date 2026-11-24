		EXPORT config_interrups
        EXPORT GPIOPortJ_Handler
        EXPORT GPIOJ_IRQHandler
        EXPORT GPIOJ_Handler
        EXPORT GPIOPortM_Handler
        EXPORT GPIOM_IRQHandler
        EXPORT GPIOM_Handler

        AREA |.text|, CODE, READONLY
        THUMB

NVIC_ISER_EN1               EQU 0xE000E104 ;bit 19 = Port J
NVIC_ISER_EN2               EQU 0xE000E108 ;bit 8  = Port M

GPIO_PORTN_AHB_DATA_R       EQU 0x400643FC

GPIO_PORTJ_AHB_GPIOIM_R     EQU 0x40060410
GPIO_PORTJ_AHB_GPIORIS_R    EQU 0x40060414
GPIO_PORTJ_AHB_GPIOICR_R    EQU 0x4006041C
GPIO_PORTJ_AHB_GPIOIS_R     EQU 0x40060404
GPIO_PORTJ_AHB_GPIOIBE_R    EQU 0x40060408
GPIO_PORTJ_AHB_GPIOIEV_R    EQU 0x4006040C

GPIO_PORTM_AHB_GPIOIS_R     EQU 0x40063404
GPIO_PORTM_AHB_GPIOIBE_R    EQU 0x40063408
GPIO_PORTM_AHB_GPIOIEV_R    EQU 0x4006340C
GPIO_PORTM_AHB_GPIOIM_R     EQU 0x40063410
GPIO_PORTM_AHB_GPIOICR_R    EQU 0x4006341C

;configura interrupcoes
config_interrups
        PUSH {R0, R1}

        ;portJ
        LDR R0, =GPIO_PORTJ_AHB_GPIOIS_R    ;borda
        LDR R1, [R0]
        BIC R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_GPIOIBE_R   ;sem dupla borda
        LDR R1, [R0]
        BIC R1, R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_GPIOIEV_R   ;PJ0 = descida, PJ1 = subida
        LDR R1, [R0]
        BIC R1, R1, #1
        ORR R1, R1, #2
        STR R1, [R0]

        ; Limpa pendencias anteriores do Port J
        LDR R0, =GPIO_PORTJ_AHB_GPIOICR_R
        MOV R1, #3
        STR R1, [R0]

        LDR R0, =GPIO_PORTJ_AHB_GPIOIM_R    ;ativa interrupcao em PJ0 e PJ1
        MOV R1, #3
        STR R1, [R0]

        LDR R0, =NVIC_ISER_EN1              ;portj no nvic
        LDR R1, =2_10000000000000000000
        STR R1, [R0]

        ; Port M (PM0)
        LDR R0, =GPIO_PORTM_AHB_GPIOIS_R    ;borda
        LDR R1, [R0]
        BIC R1, R1, #1
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_GPIOIBE_R   ;sem borda dupla
        LDR R1, [R0]
        BIC R1, R1, #1
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_GPIOIEV_R   ;pm0 eh descida
        LDR R1, [R0]
        BIC R1, R1, #1
        STR R1, [R0]

        ; Limpa pendencias anteriores do Port M
        LDR R0, =GPIO_PORTM_AHB_GPIOICR_R
        MOV R1, #1
        STR R1, [R0]

        LDR R0, =GPIO_PORTM_AHB_GPIOIM_R    ;interrup pm0
        MOV R1, #1
        STR R1, [R0]

        LDR R0, =NVIC_ISER_EN2              ;portM no nvic
        MOV R1, #2_100000000
        STR R1, [R0]

        POP {R0, R1}
        BX LR

;Handler portJ 
GPIOPortJ_Handler
GPIOJ_IRQHandler
GPIOJ_Handler
        PUSH {R4, LR}

        LDR R0, =GPIO_PORTJ_AHB_GPIORIS_R   ; Le regs
        LDR R4, [R0]

        LDR R0, =GPIO_PORTJ_AHB_GPIOICR_R   
        MOV R1, #3
        STR R1, [R0]

        TST R4, #1                          ;test se foi PJ0
        BEQ ver_pj1
        BL pj0_press                        ;executa se PJ0 = 1

ver_pj1
        TST R4, #2                          ;testa se foi PJ1
        BEQ fim_j
        BL pj1_press                        ;executa se PJ1 = 1

fim_j
        POP {R4, LR}
        BX LR

pj0_press
        LDR R0, =GPIO_PORTN_AHB_DATA_R
        LDR R1, [R0]
        ORR R1, R1, #2                      ;acende D1
        BIC R1, R1, #1                      ;apaga D2
        STR R1, [R0]
        BX LR

pj1_press
        LDR R0, =GPIO_PORTN_AHB_DATA_R
        LDR R1, [R0]
        BIC R1, R1, #2                      ;apaga D1 PN1
        ORR R1, R1, #1                      ;acende D2 PN0
        STR R1, [R0]
        BX LR

;Handler PortM 
GPIOPortM_Handler
GPIOM_IRQHandler
GPIOM_Handler
        PUSH {LR}

        LDR R0, =GPIO_PORTM_AHB_GPIOICR_R   
        MOV R1, #1
        STR R1, [R0]

        BL inverte_d1                       ;inverte estado de D1

        POP {LR}
        BX LR

inverte_d1
        LDR R0, =GPIO_PORTN_AHB_DATA_R
        LDR R1, [R0]
        EOR R1, R1, #2                      ;inverte D1
        STR R1, [R0]
        BX LR

        ALIGN
        END
