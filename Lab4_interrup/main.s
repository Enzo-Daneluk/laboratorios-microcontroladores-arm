		EXPORT main
        IMPORT config_perifs
        IMPORT config_interrups

        AREA |.text|, CODE, READONLY
        THUMB

GPIO_PORTJ_AHB_DATA_R   EQU 0x400603FC
GPIO_PORTK_AHB_DATA_R   EQU 0x400613FC
GPIO_PORTN_AHB_DATA_R   EQU 0x400643FC

main
        CPSID i                 ;desativa interrupcoes durante a configuracao
        BL config_perifs        ;configura perifericos 
        BL config_interrups     ;configura interrupcoes 

        ;acende o LED D1 no boot para indicar visualmente que o programa rodou
        LDR R0, =GPIO_PORTN_AHB_DATA_R
        LDR R1, [R0]
        ORR R1, R1, #2
        STR R1, [R0]

        CPSIE i                 ;ativa interrupcoes 

main_loop
        ;le o pino PJ1 e envia o estado para  PK7
        LDR R6, =GPIO_PORTJ_AHB_DATA_R
        LDR R7, [R6]
        AND R7, R7, #2          ;isola o bit 1 (PJ1)
        LSL R7, R7, #6          ;desloca o bit 1 para a posicao do bit 7

        LDR R6, =GPIO_PORTK_AHB_DATA_R
        LDR R8, [R6]
        BIC R8, R8, #0x80       ;limpa o bit 7 de PK7
        ORR R8, R8, R7          ;aplica o novo valor no bit 7
        STR R8, [R6]            ;escreve no pino PK7

        B main_loop

        END