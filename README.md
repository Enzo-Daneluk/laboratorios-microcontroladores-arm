# Laboratórios de microcontroladores em Assembly ARM

Laboratórios de microcontroladores (UTFPR), escritos em Assembly ARM Thumb-2 para o kit EK-TM4C1294XL (Tiva C, TM4C1294NCPDT, Cortex-M4F).

## Conteúdo

| Pasta | Assunto |
|---|---|
| `Lab0/` | exercícios dos capítulos 1 e 5: aritmética, desvios, laços e acesso à memória |
| `Lab1/` | primeiro programa com acesso à RAM (tabelas em 0x20000400 e 0x20000500) e uma versão simplificada |
| `Lab3GPIO/` | configuração de GPIO, piscar um e quatro LEDs, leitura de botões |
| `Lab4_interrup/` | interrupções de GPIO com rotinas de tratamento (`interrupts.s`, `perifs.s`, `main.s`) |

Os arquivos `.uvprojx` e `.uvoptx` são os projetos do Keil para os laboratórios 3 e 4.

## Tecnologias

Assembly ARM (Thumb-2), Keil µVision 5 (MDK-ARM), Cortex-M4F TM4C1294 e depurador Stellaris ICDI.

## Como compilar e gravar

1. Instale o Keil MDK e o pacote de dispositivo TM4C129.
2. Abra o `.uvprojx` do laboratório (por exemplo `Lab4_interrup/lab4_project.uvprojx`).
3. Compile com F7 e grave na placa com F8 (Stellaris ICDI).

Os exercícios do `Lab0` podem ser executados no simulador do Keil, sem a placa, criando um projeto para o TM4C1294NCPDT e adicionando o `.s` desejado.
