		;LAB 2 - padroes de leds com as chaves -> está tudo neste arquivo aqui.
		;Leds:   D1 = PN1, D2 = PN0, D3 = PF4, D4 = PF0
		;Chaves: SW1 = PJ0, SW2 = PJ1 (apertada = 0)
		;SW1 troca o padrao (cavaleiro / contagem)
		;SW2 troca o tempo (1000 -> 500 -> 200 ms)
		;R4 = padrao (0 = cavaleiro, 1 = contagem)
		;R5 = passo do padrao
		;R6 = tempo de cada passo (ms)
		;R7 = chaves na leitura anterior
		;R8 = tempo que ja passou no passo (ms)

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

        AREA    dados, DATA, READONLY
		;passos do cavaleiro (bit 3 = D1 ... bit 0 = D4)
cavaleiro
        DCB     2_1000, 2_0100, 2_0010, 2_0001, 2_0010, 2_0100

        AREA    principal, CODE, READONLY
        EXPORT  main

main
        BL      inicia_GPIO
        BL      inicia_systick

        MOV     R4, #0              ;comeca no cavaleiro
        MOV     R5, #0              ;primeiro passo
        LDR     R6, =1000           ;1000 ms
        BL      le_chaves
        MOV     R7, R0              ;como as chaves estao no inicio

mostra
        CMP     R4, #0
        BNE     mostra_contagem
        LDR     R9, =cavaleiro
        LDRB    R0, [R9, R5]        ;pega o passo da tabela
        B       acende
mostra_contagem
        MOV     R0, R5              ;na contagem o padrao e o proprio numero
acende
        BL      display_leds
        MOV     R8, #0              ;zera o tempo do passo

espera
        MOV     R0, #10             ;espera de 10 em 10 ms
        BL      wait_ms             ;pra poder ver as chaves no meio
        ADD     R8, R8, #10

        BL      le_chaves           ;R0 = chaves agora
        BIC     R1, R7, R0          ;bit em 1 = estava solta e agora apertou
        MOV     R7, R0              ;guarda pra proxima vez

        TST     R1, #2_01           ;apertou SW1?
        BEQ     testa_sw2
        EOR     R4, R4, #1          ;troca o padrao
        MOV     R5, #0              ;e comeca do primeiro passo
        B       mostra

testa_sw2
        TST     R1, #2_10           ;apertou SW2?
        BEQ     ve_tempo
        CMP     R6, #1000
        BEQ     vai_500
        CMP     R6, #500
        BEQ     vai_200
        LDR     R6, =1000           ;estava em 200, volta pra 1000
        B       mostra
vai_500
        MOV     R6, #500
        B       mostra
vai_200
        MOV     R6, #200
        B       mostra

ve_tempo
        CMP     R8, R6
        BLO     espera              ;ainda nao deu o tempo

        ADD     R5, R5, #1          ;proximo passo
        CMP     R4, #0
        BNE     passo_contagem
        CMP     R5, #6              ;cavaleiro tem 6 passos
        BLO     mostra
        MOV     R5, #0
        B       mostra
passo_contagem
        CMP     R5, #16             ;contagem vai de 0 a 15
        BLO     mostra
        MOV     R5, #0
        B       mostra

		;configura os ports N, F e J 
inicia_GPIO
        ; liga o clock do N (bit 12), J (bit 8) e F (bit 5)
        LDR     R0, =SYSCTL_RCGCGPIO_R
        LDR     R1, [R0]
        LDR     R2, =0x00001120
        ORR     R1, R1, R2
        STR     R1, [R0]

        ; espera os 3 ports ficarem prontos
        LDR     R0, =SYSCTL_PRGPIO_R
espera_ativar
        LDR     R1, [R0]
        AND     R1, R1, R2
        CMP     R1, R2
        BNE     espera_ativar

        ; port N: PN1 e PN0 saidas
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

        ; port F: PF4 e PF0 saidas
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

        ; port J: PJ1 e PJ0 entradas com pull-up
        LDR     R0, =GPIO_PORTJ_AHB_DIR_R
        LDR     R1, [R0]
        BIC     R1, R1, #2_00000011
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
        ORR     R1, R1, #2_00000011
        STR     R1, [R0]

        BX      LR



		;display_leds: R0 = padrao de 4 bits 
		; bit 3 = D1 (PN1), bit 2 = D2 (PN0), bit 1 = D3 (PF4), bit 0 = D4 (PF0)
display_leds
        PUSH    {R1, R2, R3}

        ; leds do port N
        MOV     R1, #0
        TST     R0, #2_1000         ; D1?
        BEQ     sem_d1
        ORR     R1, R1, #2_10       ; PN1
sem_d1
        TST     R0, #2_0100         ; D2?
        BEQ     sem_d2
        ORR     R1, R1, #2_01       ; PN0
sem_d2
        LDR     R2, =GPIO_PORTN_AHB_DATA_R
        LDR     R3, [R2]
        BIC     R3, R3, #2_00000011
        ORR     R3, R3, R1
        STR     R3, [R2]

        ; leds do port F
        MOV     R1, #0
        TST     R0, #2_0010         ; D3?
        BEQ     sem_d3
        ORR     R1, R1, #2_00010000 ; PF4
sem_d3
        TST     R0, #2_0001         ; D4?
        BEQ     sem_d4
        ORR     R1, R1, #2_00000001 ; PF0
sem_d4
        LDR     R2, =GPIO_PORTF_AHB_DATA_R
        LDR     R3, [R2]
        BIC     R3, R3, #2_00010001
        ORR     R3, R3, R1
        STR     R3, [R2]

        POP     {R1, R2, R3}
        BX      LR

		
		
		;le_chaves: devolve em R0 o PJ1 e o PJ0
le_chaves
        LDR     R0, =GPIO_PORTJ_AHB_DATA_R
        LDR     R0, [R0]
        AND     R0, R0, #2_11
        BX      LR


		
		
		;INICIALIZAÇÃO DO SYSTICK
inicia_systick
        PUSH    {R0, R1}
        LDR     R1, =NVIC_ST_CTRL_R
        MOV     R0, #0x05           ;habilita temporizador + clock do sistema
        STR     R0, [R1]
        POP     {R0, R1}
        BX      LR

		
		
		
		;TEMPORIZAÇÃO PARA ESPERA
wait_ms
        PUSH    {R1, R2, R3}
        
        LDR     R1, =NVIC_ST_RELOAD_R
        LDR     R2, =15999          ;16000 ciclos = 1 ms (a 16 MHz)
        STR     R2, [R1]
        
        ;zera o registrador CURRENT para forçar recarga imediata
        LDR     R3, =NVIC_ST_CURRENT_R
        MOV     R2, #0
        STR     R2, [R3]

        LDR     R1, =NVIC_ST_CTRL_R

timer_1_ms
wait_loop
        LDR     R2, [R1]
        TST     R2, #0x00010000     ;testa Bit 16 (COUNTFLAG)
        BEQ     wait_loop

        ADDS    R0, R0, #-1
        BNE     timer_1_ms

        POP     {R1, R2, R3}
        BX      LR

        END
