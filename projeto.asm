;PROJETO ARQUITETURA DE COMPUTADORES
;DANIEL REIGADA Nº 82064
;TOMÁS MARIA 	Nº 81924



SCREEN 				EQU		8000H			;endereço do ecra
SCREEN_LAST_WORD	EQU 	807EH			;ultimo endereço do ecran
LINHA1				EQU		0001B			;primeira linha do teclado
LINHA4				EQU		1000B			;ultima linha do teclado
PIN_teclado			EQU		0E000H			;endereço de entrada proveniente do teclado
POUT_teclado 		EQU		0C000H			;endereço de saida para o teclado
POUT_balas_dips		EQU		06000H			;endereço de saida para o display das balas
POUT_pontuacao 		EQU 	0A000H			;endereço de saida para o display do pontuacao
SCREEN_SIZE 		EQU		32				;numero de bits por linha do ecran
MAX_SCREEN_IND		EQU		31				;indice maximo dos bits numa linha
NUM_MAX_AVIOES		EQU		3				;numero maximo de avioes ativos
NUM_MAX_BALAS  		EQU		10				;numero maximo de balas ativas
FREQUENCIA_AVIOES	EQU 	2				;frequencia dos avioes, quanto maior menos aparecem
DELAY_EXPL			EQU 	1				;delay para a explosao desaparecer
NUM_BALAS_INIT		EQU 	10				;numero inicial de balas
NUM_BALAS_CAIXA		EQU 	5				;numero de balas por caixa
FREQUENCIA_CAIXA	EQU 	50				;frequencia das caixas, quanto maior menos aparecem
YY_MIN_CANHAO 		EQU		23				;ate onde o canhao pode ir 
YY_MIN_AVIAO		EQU		4				;limite superior dos avioes
YY_MAX_AVIAO 		EQU 	16				;limite inferior dos avioes
DELAY_MIN_AVIAO		EQU  	5				;delay min entre avioes
XX_INIT_CANHAO		EQU 	15				;posicao inicial do canhao X
YY_INIT_CANHAO		EQU 	28				;posicao inicial do canhao Y

MASCARA_BITS_0_3	EQU 	0FH 			;mascara para isolar os 4 bits de menor peso



PLACE 1500H
;-----------------Tabela de excepcoes ------------------------------------------------------------------------
INTS:						
		WORD	intAVIOES  	;interrupçao dos avioes
		WORD 	intBALAS 	;interrupçao das balas


PLACE 2000H
;-----------------Stack pointer------------------------------------------------------------------------
pilha: TABLE 100H
fim_pilha:

;-----------------INTERRUPÇOES------------------------------------------------------------------------
estado_int_avioes:	WORD 0			;estado das interrupcoes
estado_int_balas:	WORD 0 


;-----------------Mascaras para bits------------------------------------------------------------------------
mascaras_bit:	STRING 80H, 40H, 20H, 10H, 08H, 04H, 02H, 01H



;Codificao das teclas (U- up, D- Down, L- Left, R- Right):
		;UL - 	0 	;R  -	4	;Dispara- 8
		;U 	-	1	;DL -   5	;Acaba jogo- F
		;UR - 	2	;D 	-	6	;reinicia jogo - E
		;L 	-	3	;DR - 	7 	
TECLAS: 
		WORD 0			;0
		WORD 1			;1
		WORD 2			;2
		WORD 00FFH		;3
		WORD 3			;4
		WORD 8			;5
		WORD 4			;6
		WORD 00FFH		;7
		WORD 5			;8
		WORD 6			;9
		WORD 7			;A
		WORD 00FFH		;B
		WORD 00FFH		;C
		WORD 00FFH		;D
		WORD 0EH		;E
		WORD 0FH		;F



;-----------------Movimentos do canhao------------------------------------------------------------------------
MOVS_CANHAO:
	WORD	-1		;UL
	WORD 	-1	
	
	WORD	0		;U
	WORD 	-1

	WORD	1		;UR
	WORD 	-1

	WORD	-1		;L
	WORD 	0

	WORD	1	 	;R
	WORD 	0

	WORD	-1 		;DL
	WORD	1 	

	WORD	0		;D
	WORD 	1

	WORD	1		;DR
	WORD 	1

		


;-----------------Estados------------------------------------------------------------------------

estado_tecla: 			WORD 0			;estado para saber se é a mesma tecla que esta a ser premida
tecla_pressionada: 		WORD 00FFH
estado_int_explosoes:	WORD 0
pixel_estava_on:		WORD 0

;-----------------Estado dos avioes---------------------------------------------------------------
estado_avioes:		TABLE NUM_MAX_AVIOES
			 		TABLE NUM_MAX_AVIOES		;posicao avioes X
					TABLE NUM_MAX_AVIOES		;posicao avioes X

;-----------------Estado das explosoes------------------------------------------------------------------------
estado_explosoes:	TABLE NUM_MAX_AVIOES
					TABLE NUM_MAX_AVIOES 		;posicao explosoes X
					TABLE NUM_MAX_AVIOES		;posicao explosoes Y

;-----------------Estado balas------------------------------------------------------------------------
estado_balas:		TABLE NUM_MAX_BALAS
	 				TABLE NUM_MAX_BALAS 		;posicao balas X
					TABLE NUM_MAX_BALAS			;posicao balas Y

;-----------------Estado das caixas------------------------------------------------------------------------
estado_caixa:		TABLE 2						;estado e posicao X da caixa


;-----------------Posicao do canhao------------------------------------------------------------------------
pos_canhao: 	WORD	XX_INIT_CANHAO
				WORD 	YY_INIT_CANHAO

;-----------------Outras variaveis------------------------------------------------------------------------
DELAY_SINCE_LAST_PLANE:			;tempo passado desde o ultimo aviao
		WORD 0

BALAS_DISP:						;numero de balas disponiveis
		WORD NUM_BALAS_INIT

PONTUACAO:						;pontuacao
		WORD 0


;NUM RANDOM
RANDOM_NUM:				WORD 0	;numero random

;DADOS OBJETOS
AVIAO: 	STRING 	5, 5				;tamanho - colunas/linhas
		STRING	4, 9, 1FH, 9, 4,0 	;forma			

CANHAO: STRING	3, 3				;tamanho - colunas/linhas
		STRING	2, 7, 7, 0			;forma

CANHAO_BALA:						;de onde a bala sai no canhao
		WORD 1
		WORD -1

EXPLOSAO: 	STRING 4, 4				;tamanho - colunas/linhas
			STRING 9, 6, 6, 9		;forma

CAIXA:		STRING 4, 2				;tamanho - colunas/linhas
			STRING 0FH, 0FH 		;forma


PLACE 3000H
GAME: 	STRING 0003H, 00cfH, 0045H, 00c0H, 0002H, 0049H, 006dH, 0000H
		STRING 0002H, 0009H, 0055H, 0000H, 0002H, 006fH, 0045H, 0080H
		STRING 0002H, 0029H, 0045H, 0000H, 0003H, 00e9H, 0045H, 00c0H

OVER:  	STRING 0001H, 0091H, 0073H, 0000H, 0002H, 0051H, 0044H, 0080H
		STRING 0002H, 0051H, 0044H, 0080H, 0002H, 004aH, 0067H, 0000H
		STRING 0002H, 004aH, 0044H, 0080H, 0001H, 0084H, 0074H, 0080H

PLACE 0

INIT:
	MOV SP, fim_pilha				;inicializacao do stack pointer
	MOV BTE, INTS 					;inicializacao da tabela das interrupcoes
	CALL limpa_ecran				;limpa o ecran
	CALL RESET_GAME	

CICLO:
	EI0								;ativa interrupçao 0
	EI1								;ativa interrupçao 1
	EI
	CALL teclas_press
	CALL controlo
	CALL move_canhao
	CALL balas
	CALL move_caixa
	CALL apaga_explosoes
	CALL move_avioes
	CALL gerador
	JMP CICLO







;----------------------------------------teclas_press------------------------------------------------
;Guarda no endereço de memoria "tecla_pressionada" a tecla (00FFH se nada foi premido), 
;guarda tambem no endereço "estado_tecla" 1 se a tecla a ser premida é a mesma que estava anteriormente.
;Nao altera registos.

teclas_press:		
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6

	MOV 	R4, LINHA4											;linha para comecar a testar
	MOV 	R1, POUT_teclado									
	MOV 	R3, PIN_teclado									
	MOV 	R5, estado_tecla									;endereço do estado da tecla
	MOV 	R7, tecla_pressionada						
	ciclo_press:
		MOVB	[R1], R4										;teste de linha
		MOVB	R2, [R3]										;procura se algo foi premido
		MOV 	R6, 0FH											;mascara para isolar as teclas
		AND 	R2, R6											;verifica se foi premida
		JNZ		press 											;caso tenha sido premida
		SHR 	R4, 1											;altera a linha a testar
		JNZ 	ciclo_press										;caso ainda nao tenha testado a primeira linha
	no_press:													;caso nenhuma tecla tenha sido premida
		MOV R6, 1												;valor a colocar no estado da tecla
		MOV [R5], R6
		MOV R3, 00FFH											;valor a colocar na memoria caso nada tenha sido premido
		MOV [R7], R3
		JMP fim_tecla											;acaba a rotina
	press:
		MOV R1, 0												;contador para a linha
		MOV R3, 0												;contador para a coluna
	convl:														;converter a linha
		SHR R4, 1												;"shiftar" o registo ate ser 0
		JZ convc
		ADD R1, 1												;adiciona 1 a linha
		JMP convl
	convc:														;converter a coluna
		SHR R2, 1												;"shiftar" o registo ate ser 0
		JZ end_conv 											;conversao acabou
		ADD R3, 1												;adiciona 1 a coluna
		JMP convc												
	end_conv:
		SHL R1, 2	  											;x4
		ADD R3, R1	  											;soma linha com coluna para devolver o valor da tecla premida
		MOV R4, [R7]  											;tecla pressionada anteriormente
		CMP R3, R4												;compara se sao iguais
		JNZ tecla_diferente										;se a tecla for diferente
		MOV R2, 1												;estado caso a tecla seja diferente
		MOV [R5], R2
		JMP fim_tecla
	tecla_diferente:
		MOV R2, 0												;estado caso a tecla seja igual
		MOV [R5], R2
		MOV [R7], R3
	fim_tecla:
		POP R6
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		RET



;--------------------------------------------Controlo---------------------------------
;Processo que controla se as balas ja acabaram ou utilizador premiu a tecla e reiniciar ou acabar o jogo.
;Acaba o jogo se tal sucedeu.
controlo:
	PUSH R0
	PUSH R1
	PUSH R10


	test_balas_acabaram:					;teste balas
	MOV R0, BALAS_DISP
	MOV R0, [R0]
	AND R0, R0								;se ja nao ha balas disponiveis perdeu o jogo
	JNZ ciclo_controlo
	MOV R0, estado_balas
	SUB R0, 2
	MOV R1, NUM_MAX_BALAS
	SHL R1, 1
	
	ciclo_teste_balas:
	AND R1 , R1
	JZ perdeu_jogo
	MOV R10, [R0 + R1]
	AND R10, R10
	JNZ prox_test
	SUB R1, 2
	JMP ciclo_teste_balas

	prox_test:
	MOV R10, 0								;registo de estado para saber se esta a espera de reiniciar


	ciclo_controlo:							;ciclo caso tenha acabado o jogo ou perdido
	MOV R0, estado_tecla					;teste para saber se a tecla premida e diferente
	MOV R0, [R0]
	AND R0, R0
	JNZ test_controlo

	MOV R0, tecla_pressionada				
	MOV R0, [R0]
	SHL R0, 1
	MOV R1, TECLAS
	MOV R0, [R1 + R0]						;tecla pressionada

	
	MOV R1, 0FH 								
	CMP R0, R1								;caso a tecla seja para acabar o jogo
	JZ acaba_jogo

	MOV R1, 0EH
	CMP R0, R1
	JZ reinicia_jogo						;caso a tecla seja para reiniciar o jogo

	test_controlo:
	AND R10, R10							;saber se tem de esperar pelo reinicia 
	JZ fim_controlo							;se o jogo nao esta terminado continua
	CALL teclas_press						

	JMP ciclo_controlo


	acaba_jogo:
		CALL limpa_ecran				
		MOV R10, 1							;jogo esta acabado
		CALL teclas_press
		JMP ciclo_controlo


	reinicia_jogo:
		CALL limpa_ecran
		CALL RESET_GAME
		JMP fim_controlo

	perdeu_jogo:
		CALL limpa_ecran
		CALL GAME_OVER
		MOV R10, 1							;jogo esta acabado
		JMP ciclo_controlo


	fim_controlo:
	POP R10
	POP R1
	POP R0
	RET

;-----------------move_canhao--------------------------------
;Processa que move o canhao na direcao da tecla que foi premida.
;Nao altera registos.
move_canhao:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R7

	MOV R0, estado_tecla
	MOV R0, [R0]
	AND R0, R0				;se a foi premida outra tecla continua
	JNZ fim_move_canhao

	MOV R0, tecla_pressionada
	MOV R0, [R0]
	SHL R0, 1			;numero de bytes a avaçar
	MOV R1, TECLAS
	MOV R1, [R1 + R0]

	MOV R0, 7			;para comparar se esta dentro dos limites da codificao
	CMP R1, R0			;comparar se e um valor para mover
	JGT fim_move_canhao	;se for maior nao move

	MOV R0, MOVS_CANHAO
	SHL R1, 2 			;MUL 2 para aceder ao byte correto
	ADD R1, R0			;endereço do movimento
	MOV R6, [R1]		;STEP XX
	ADD R1, 2
	MOV R7, [R1]		;STEP YY
	
	MOV R0, CANHAO 		;IMAGEM  do canhao
	MOV R3, pos_canhao
	MOV R1, [R3]		;XX atual
	AND R6, R6			;se o step for zero nao precisa de testar se ultrapassa os limites
	JZ yy_canhao

	MOV R4, R1 			;para poder alterar
	ADD R4, R6			;nova posicao
	JN n_muda_xx_c		;se tentar mover para fora nao altera os XX
	MOVB R8, [R0]		;numero de colunas do canhao
	ADD R4, R8			;lado direito do canhao
	MOV R8, SCREEN_SIZE
	SUB R4, R8
	JNP yy_canhao		;se tentar mover para fora nao altera os XX
	n_muda_xx_c:
	MOV R6, 0

	yy_canhao:
	ADD R3, 2
	MOV R2, [R3]			;YY atual
	AND R7, R7
	JZ 	canhao_mov 				;se o step for zero nao precisa de testar se ultrapassa os limites
	
	MOV R4, R2				;para poder alterar
	ADD R4, R7				;nova posicao
	MOV R8, YY_MIN_CANHAO
	SUB R8, R4
	JP n_muda_yy_c			;se tentar mover para fora nao altera os XX
	MOV R8, R0			
	ADD R8 ,1
	MOVB R8, [R8]			;numero de linhas do canhao
	ADD R4, R8				
	MOV R8, SCREEN_SIZE
	SUB R4, R8
	JNP canhao_mov			;se tentar mover para fora nao altera os XX
	n_muda_yy_c:
	MOV R7, 0

	canhao_mov:
	CALL move_objeto
	
	ADD R1, R6				;atualizar XX
	ADD R2, R7				;atualizar YY
	MOV R3, pos_canhao
	MOV [R3], R1
	ADD R3, 2
	MOV [R3], R2
	fim_move_canhao:
	POP	R7
	POP R6
	POP R3
	POP R2
	POP R1
	POP R0
	RET




;-------------------------------------------balas--------------------------------------------------
;Processo que move as balas ativas e cria uma nova bala caso a tecla de disparar tenha sido premida.
;Nao altera registos.
balas:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10


	MOV R0, 0					;nao pode mover
	MOV R10, estado_int_balas
	MOV R9, [R10]				;estado da interrupçao das balas
	AND R9, R9
	JZ cria_n_move				;se estiver a 0 nao move as balas, mas pode criar uma
	MOV R9, 0
	MOV [R10], R9				;poe a interrupçao o estado a 0
	MOV R0, 1					;pode mover balas

	cria_n_move:
	MOV R9, 1					;nao deixa criar balas
	MOV R10, estado_tecla
	MOV R10, [R10]
	AND R10, R10				;caso a tecla a que foi pressionada seja diferente (R10 = 0)
	JNZ init_balas
	MOV R10, tecla_pressionada
	MOV R10, [R10]				;tecla pressionada
	MOV R8, TECLAS
	SHL R10, 1
	MOV R8, [R8 + R10]			;codificao da tecla pressionada
	ADD R8, -8					;codificao do Dispara
	JNZ init_balas				;nao cria balas
	MOV R9, 0					;deixa criar uma bala



	init_balas:
	MOV R10, NUM_MAX_BALAS
	MOV R8, estado_balas
	MOV R4, 1 					;contador da bala

	ciclo_balas:
		MOV R1, [R8]			;estado da bala
		AND R1, R1
		JZ cria_bala			;se a bala nao estiver ja disparada
		move_bala:
			AND R0, R0
			JZ prox_bala		
			MOV R5, R10			;TEMP- para alterar
			SHL R5, 1			;MUL 2 para aceder aos XX
			MOV R1, [R8 + R5]	;posicao XX

			SHL R5, 1			;MUL 2 para aceder aos YY
			MOV R2, [R8 + R5]	;posicao YY
			MOV R3, 0			;para desligar
			CALL pixel_on_off	;desligar o bit aceso

			SUB R2, 1			;nova posicao YY
			JN	bala_acabou ;continua dentro do ecran?

			MOV R3, 1
			CALL pixel_on_off
			MOV R3, pixel_estava_on
			MOV R3, [R3]
			AND R3, R3
			JZ atualiza_posicao_bala

			MOV R6, YY_MAX_AVIAO			
			CMP R2, R6					;testar se esta abaixo do limite inferior dos avioes
			JGE atualiza_posicao_bala	;se estiver continua a mover

			MOV R6, YY_MIN_AVIAO		;testar se esta abaixo do limite superior dos avioes
			CMP R2, R6					;se estiver significa que bateu num aviao
			JGE bateu_aviao

			MOV R6, 1					;testar se esta acima do limite das caixas
			CMP R6, R2					;se estiver significa que bateu numa caixa
			JGE bateu_caixa
			JMP atualiza_posicao_bala



			bateu_aviao:
				CALL cria_explosao
				JMP bala_acabou
			bateu_caixa:
				CALL adiciona_balas
				JMP bala_acabou
			atualiza_posicao_bala:
				MOV [R8 + R5], R2	;atualiza posicao

		prox_bala:
			CMP R4, R10
			JZ fim_balas
			ADD R4, 1
			ADD R8, 2 					;proxima bala
			JMP ciclo_balas
		cria_bala:

			AND R9, R9
			JNZ prox_bala
			MOV R9, 1				;ja nao deixa criar mais balas

			MOV R5, BALAS_DISP
			MOV R9, [R5]			;se já nao há balas nao dispara
			AND R9, R9
			JZ prox_bala
			SUB R9, 1
			MOV [R5], R9			;subtrai 1 ao numero de balas disponiveis
			CALL update_balas

			MOV R1, 1
			MOV [R8], R1			;altera o estado da bala para 1
			MOV R5, pos_canhao
			MOV R1, [R5]			;XX
			MOV R2, [R5 + 2]		;YY
			
			MOV R5, CANHAO_BALA		;de onde sai a bala relativamente ao canhao
			MOV R6, [R5]			;XX
			ADD R5, 2
			MOV R7, [R5]			;YY

			ADD R1, R6				;posicao de onde sai a bala XX
			ADD R2, R7				;posicao de onde sai a bala YY
			MOV R3, 1
			CALL pixel_on_off		;escreve a bala

			MOV R5, R10
			SHL R5, 1				;indice da posicao XX
			MOV [R8 + R5], R1		;posicao da bala XX
			SHL R5, 1				;indice da posiçao YY
			MOV [R8 + R5], R2 		;posiçao da bala YY
			JMP prox_bala
		bala_acabou:
			MOV R6, 0
			MOV [R8], R6
			JMP ciclo_balas

	fim_balas:
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET



;----------------------------------------adiciona_balas----------------------------------------
;Rotina que aumenta o numero de balas disponiveis.
adiciona_balas:
	PUSH R1
	PUSH R2
	PUSH R3

	MOV R1, BALAS_DISP
	MOV R2, [R1]
	MOV R3, NUM_BALAS_CAIXA
	ADD R2, R3
	MOV [R1], R2
	CALL update_balas

	MOV R1, estado_caixa
	MOV R2, 0
	MOV [R1], R2
	MOV R0, CAIXA
	ADD R1, 2
	MOV R1, [R1]
	MOV R2, 0
	MOV R3, 0
	CALL escreve_forma

	POP R3
	POP R2
	POP R1
	RET

;------------------------------------update_balas---------------------------------------------
;Rotina que atualiza o display das balas
update_balas:
	PUSH R0
	PUSH R1

	MOV R0, POUT_balas_dips
	MOV R1, BALAS_DISP
	MOV R1, [R1]
	CALL escreve_display

	POP R1
	POP R0
	RET






;--------------------------------------move_caixa----------------------------------------
;Processo que move a caixa se esta estiver ativa ou cria uma caso nao esteja
move_caixa:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R8

	MOV R8, estado_caixa
	MOV R1, [R8]
	AND R1, R1
	JNZ movimenta_caixa

	cria_caixa:
		MOV R1, FREQUENCIA_CAIXA
		MOV R2, RANDOM_NUM
		MOV R2, [R2]
		MOD R2, R1
		JNZ fim_move_caixa

		MOV R1, 1
		MOV [R8], R1	;ativa a caixa
		ADD R8, 2
		MOV R1, SCREEN_SIZE
		MOV [R8], R1
		JMP fim_move_caixa

	movimenta_caixa:
		MOV R1, estado_int_avioes
		MOV R1, [R1]
		AND R1, R1
		JZ fim_move_caixa
		ADD R8, 2
		MOV R1, [R8]
		MOV R2, 0
		MOV R3, 0
		MOV R0, CAIXA
		CALL escreve_forma

		SUB R1, 1
		MOVB R4, [R0]		;numero de colunas da caixa
		ADD R4, R1
		JN acaba_caixa
		MOV R3, 1
		CALL escreve_forma
		MOV [R8], R1
		JMP fim_move_caixa
	acaba_caixa:
		MOV R8, estado_caixa
		MOV R1, 0
		MOV [R8], R1
	fim_move_caixa:
	POP R4
	POP R8
	POP R3
	POP R2
	POP R1
	POP R0
	RET



;-----------------------------------cria_explosao--------------------------------------
;rotina que cria uma explosao no aviao em que a bala bateu
;R1- POSICAO DA BALA XX R2- POSICAO DA BALA YY
cria_explosao:	
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10



	MOV R10, NUM_MAX_AVIOES
	MOV R8, estado_avioes	;endereço estado do aviao 1
	MOV R4, 1				;contador do aviao

	ciclo_cria_explosao:	;para saber em que aviao bateu
		MOV R0, AVIAO 			;forma do aviao
		MOV R5, R10
		MOV R3, [R8]
		AND R3, R3
		JZ prox_aviao_expl
		SHL R5, 1
		MOV R6, [R8 + R5]
		CMP R6, R1
		JGT prox_aviao_expl		;caso esteja para o lado esquerdo

		SHL R5, 1
		MOV R7, [R8 + R5]
		CMP R7, R2
		JGT prox_aviao_expl				;caso esteja acima do aviao

		MOVB R5, [R0]			;numero de colunas do aviao
		ADD R6, R5
		CMP R1, R6
		JGE prox_aviao_expl			;caso esteja do lado direito

		ADD R0, 1
		MOVB R5, [R0]
		ADD R7, R5
		CMP R1, R6
		JGE prox_aviao_expl

		MOV R0, AVIAO 			;forma do aviao
		MOV R3, 0
		MOV [R8], R3

		MOV R5, R10
		SHL R5, 1
		MOV R1, [R8 + R5]
		SHL R5, 1
		MOV R2, [R8 + R5]
		CALL escreve_forma				;apaga aviao

		CALL aumenta_pontuacao

		guarda_exp_mem:
			MOV R7, 1
			MOV R8, estado_explosoes
			MOV R4, 1
			ciclo_cria_explosao_mem:			;guarda a explosao na memoria
			MOV R5, [R8]
			AND R5, R5
			JNZ prox_cria_expl
			MOV R5, 1
			MOV [R8], R5
			MOV R5, R10
			SHL R5, 1
			MOV [R8 + R5], R1
			SHL R5, 1
			MOV [R8 + R5], R2
			JMP desenha_expl
			
			prox_cria_expl:
			CMP R4, R10
			JGE fim_cria_explosao			;nao ha espaco na mem para esplosoes
			ADD R4, 1
			ADD R8, 2
			JMP ciclo_cria_explosao_mem


			desenha_expl:
			MOV R3, 1
			MOV R0, EXPLOSAO
			CALL escreve_forma

			MOV R1, estado_int_explosoes
			MOV R2, 0
			MOV [R1], R2

			JMP fim_cria_explosao

		prox_aviao_expl:
			CMP R4, R10
			JZ 	fim_cria_explosao
			ADD R4, 1		;indice prox aviao
			ADD R8, 2		;passa proximo aviao
			JMP ciclo_cria_explosao

	fim_cria_explosao:	
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET

;----------------------------------------aumenta_pontuacao--------------------------------
;rotina que aumenta a pontuacao e atualiza os displays
aumenta_pontuacao:
	PUSH R0
	PUSH R1
	PUSH R2

	MOV R0, POUT_pontuacao
	MOV R2, PONTUACAO
	MOV R1, [R2]
	ADD R1, 1
	MOV [R2], R1 
	CALL escreve_display

	POP R2
	POP R1
	POP R0
	RET

;------------------------------------------------apaga_explosoes----------------------------------------
;Processo que apaga as explosoes ativas.
apaga_explosoes:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R8
	PUSH R10

	MOV R1, estado_int_explosoes
	MOV R1, [R1]
	SUB R1, DELAY_EXPL						;caso ja tenho acontecido mais de duas vezes
	JNP fim_apaga_explosoes

	MOV R8, estado_explosoes
	MOV R10, NUM_MAX_AVIOES
	MOV R0, EXPLOSAO
	MOV R4, 1					;contador 
	MOV R3, 0

	ciclo_apaga_explosoes:
	MOV R5, [R8]
	AND R5, R5
	JZ prox_apaga_expl
	MOV R1, 0
	MOV [R8], R1				;desativa a explosao
	MOV R5, R10
	SHL R5, 1
	MOV R1, [R8 + R5]
	SHL R5, 1
	MOV R2, [R8 + R5]
	CALL escreve_forma

	prox_apaga_expl:
	CMP R4, R10
	JGE fim_apaga_explosoes
	ADD R4, 1
	ADD R8, 2
	JMP ciclo_apaga_explosoes

	fim_apaga_explosoes:

	POP R10
	POP R8
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET





;---------------------------------------------move_avioes------------------------------------------------------
;Processo que move e cria os avioes.
move_avioes:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10


	MOV R10, estado_int_avioes
	MOV R8, [R10]				;estado da interrupçao dos avioes
	AND R8, R8
	JZ fim_move_avioes			;se estiver a 0 nao move os avioes
	MOV R8, 0
	MOV [R10], R8				;poe a interrupçao a 0

	MOV R10, NUM_MAX_AVIOES
	MOV R8, estado_avioes	;endereço estado do aviao 1
	MOV R4, 1				;contador do aviao
	MOV R0, AVIAO 			;forma do aviao
	MOV R3, 0 				;ja criou aviao

	ciclo_move_avioes:
		MOV R1, [R8]		;estado do aviao
		AND R1, R1
		JZ cria_aviao		;se estiver no estado 0 cria o aviao
		move_aviao:
			MOV R5, R10			;TEMP- para alterar
			SHL R5, 1			;MUL 2 para aceder aos XX
			MOV R1, [R8 + R5]	;XX atual do aviao
			MOV R9, R1			;copia para poder alterar
			MOVB R2, [R0] 		;colunas do aviao
			ADD R9, R2			;caso o aviao já esteja totalmente fora do ecran
			JNP aviao_acabou
			SHL R5, 1			;MUL 2 para aceder aos YY
			MOV R2, [R8 + R5]	;posicao YY
			MOV R6, -1			;STEP XX
			MOV R7, 0			;STEP YY
			CALL move_objeto
			ADD R1, R6			;novo XX
			MOV R5, R10
			SHL R5, 1			;ACEDER AOS XX
			MOV [R8 + R5], R1 	;escrever o novo XX
		prox_aviao:
			CMP R4, R10
			JZ fim_move_avioes
			ADD R4, 1		;indice prox aviao
			ADD R8, 2		;passa proximo aviao
			JMP ciclo_move_avioes
		cria_aviao:
			AND R3, R3
			JNZ prox_aviao
			MOV R3, 1					;ja nao vai criar mais avioes
			
			MOV R9, DELAY_MIN_AVIAO
			MOV R5, DELAY_SINCE_LAST_PLANE
			MOV R1, [R5]
			CMP R1, R9
			JGE step_cria_aviao
			MOV R3, 1
			ADD R1, 1
			MOV [R5], R1
			JMP prox_aviao

		step_cria_aviao:
			MOV R1, 0
			MOV [R5], R1
			MOV R9, RANDOM_NUM			
			MOV R9, [R9]
			MOV R5, FREQUENCIA_AVIOES
			MOD R9, R5					;gerador de avioes random
			JNZ prox_aviao

			MOV R9, 1
			MOV [R8], R9				;muda o estado do aviao
			MOV R7, SCREEN_SIZE			;posicao a comecar 
			MOV R5, R10
			SHL R5, 1	
			MOV [R8 + R5], R7			;XX inicial 

			MOV R7, RANDOM_NUM
			MOV R7, [R7]
			MOV R1, R0
			ADD R1, 1					
			MOVB R1, [R1]				;aceder ao numero de linhas do aviao
			MOV R2, YY_MAX_AVIAO		;posicao mais baixa que a parte inferior pode estar
			SUB R2, R1					;posicao mais baixa que a parte superior pode estar
			MOV R1, YY_MIN_AVIAO
			SUB R2, R1					;valores entre os quais pode variar a posiçao
			MOD R7, R2
			ADD R7, R1					;posicao aleatoria onde o aviao vai começar

			SHL R5, 1					;step YY
			MOV [R8 + R5], R7
			JMP prox_aviao
		aviao_acabou:
			MOV R9, 0
			MOV [R8], R9
			JMP prox_aviao
	
	fim_move_avioes:
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET


;-----------------------------------------move_objeto------------------------------------------
;Rotina que move um objeto no ecran.
;R0- endereço da forma, R1-XX atual R2-YY atual , R6- STEP XX R7- STEP YY
move_objeto:				
	PUSH R1
	PUSH R2
	PUSH R3

	MOV R3,	0
	CALL escreve_forma					;apagar o objeto atual
	ADD R1, R6							;nova posicao XX
	ADD R2, R7							;nova posicao YY
	MOV R3, 1							;para escrever
	CALL escreve_forma					;escreve o aviao na nova posicao

	POP R3
	POP R2
	POP R1	
	RET



;-----------------------------------------------escreve_forma------------------------------------
;Rotina que escreve uma forma no ecran na posicao dada
; R0- endereço da forma , R1-XX , R2-YY, R3-ON/OFF
escreve_forma:				
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7

	MOVB R7, [R0]			;numero de colunas
	ADD R0, 1
	MOVB R5, [R0]			;numero de linhas
	ADD R5, 1				;"indice" na forma da ultima linha
	MOV R6, 2				;"indice" na forma da primeira linha
	ciclo_forma:
		CMP R6, R5			;compara se a linha em que esta e maior que o total de linhas
		JGT fim_forma		;nesse caso acaba
		ADD R0, 1
		MOVB R4, [R0]		;vai buscar o que escrever na linha
		CALL escreve_linha	;escreve a linha
		ADD R2, 1			;incrementa o YY
		ADD R6, 1			;incrementa a linha
		JMP ciclo_forma
	fim_forma:
	POP R7
	POP R6
	POP R5
	POP R4
	POP R2
	POP R1
	POP R0
	RET


;--------------------------------------------------escreve_linha--------------------------------
;rotina que escreve uma linha dada no ecran
;R1-XX   R2-YY  R3- ON/OFF R4- valor a escrever R7- NUMERO DE PIXEIS
escreve_linha:				
	PUSH R0
	PUSH R1
	PUSH R5
	PUSH R6
	PUSH R7

	MOV R0, 80H 				;mascara inicial para o bit 8
	MOV R6, 0
	ADD R7, -8 					;SUB 8 para saber quantos SHL tem de fazer
	NEG	R7
	mascara_linha:
		SHR R0, 1
		ADD R6, 1
		CMP R7, R6
		JGT mascara_linha		
		MOV R6, SCREEN_SIZE
	ciclo_linha:			
		AND R1, R1
		JN nao_escreve			;
		MOV R5, R0				;move a mascara atual para ser alterada
		AND R5, R4				;verifica se vai ligar o bit ou nao
		JZ	nao_escreve			;se nao for para ligar passa a frente
		CALL pixel_on_off		;escreve o bit
	nao_escreve:
		ADD R1, 1				;salta para o proximo bit
		CMP R1, R6				;confirma se ja chegou aos limites do ecran
		JGE fim_linha			;se sim acaba
		SHR R0, 1				;altera a mascara para o proximo bit
		JNZ ciclo_linha
	fim_linha:

	POP R7
	POP R6
	POP R5
	POP R1
	POP R0
	RET




;--------------------------------------------------------pixel_on_off---------------------------
;Rotina que liga ou desliga um pixel no ecran
;R1- XX R2-YY R3-on/off
pixel_on_off:
	PUSH R1 			
	PUSH R2 			
	PUSH R3 			
	PUSH R4
	PUSH R0
	MOV R0, R1
	SHR R0, 3				;converter XX para coluna de bytes (DIV por 8)
	MOV R4, SCREEN_SIZE
	SHR R4, 3				;DIV 8
	MUL R2, R4				;converter YY para linha
	ADD R2, R0 				;R2 guarda o byte a ser alterado (linha + coluna)
	MOV R0, SCREEN			;vai buscar endereço do ecran
	ADD R2, R0				;endereço do byte a ser alterado 

	MOV R4, 8
	MOD R1, R4			;calcula o bit a acender/desligar
	MOV R4, mascaras_bit	;endereço da primeira mascara
	ADD R1, R4			;endereço da mascara a utilizar
	MOVB R1, [R1]		;R1 guarda a mascara
	MOVB R0, [R2] 		;move o que esta no ecran para R0
	AND R3, R3			;verfica se desliga ou liga bit
	JZ bit_off
	bit_on_test:
		MOV R4, R0
		AND R4, R1					;verifica se o bit estava ligado
		MOV R4, pixel_estava_on		;se estava ligado escreve na memoria
		JZ estava_off
		MOV R3, 1
		JMP bit_on
	estava_off:
		MOV R3, 0
	bit_on:
		MOV [R4], R3
		OR R0, R1
		JMP print
	bit_off:
		NOT R1
		AND R0, R1
	print:
		MOVB [R2], R0		;escreve no ecra
	POP R0
	POP R4
	POP R3
	POP R2
	POP R1
	RET





;------------------------------------escreve_display----------------------------
;rotina que escreve no display dado um valor
;R0- endereço do display , R1- valor a escrever
escreve_display:		
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV R2, R1		;copia do valor
	MOV R3, 10		;valor para fazer as contas
	MOD R2, R3		;unidades
	DIV R1, R3		;dezenas
	SHL R1, 4
	ADD R1, R2
	MOVB [R0], R1

	POP R3
	POP R2
	POP R1
	POP R0
	RET







;--------------------------gerador-------------------------------
;Processo que adiciona 1 a um valor na memoria de forma a criar um numero pseudo-aleatorio
gerador:
	PUSH R1
	PUSH R2

	MOV R0, RANDOM_NUM
	MOV R1, [R0]
	ADD R1, 1
	MOV [R0], R1

	POP R1
	POP R2
	RET






;-------------------------------limpa_ecran-----------------------------------------
;Rotina que limpa o ecran
limpa_ecran:
	PUSH R0
	PUSH R1
	PUSH R2

	MOV R0, SCREEN
	MOV R1, 0
	MOV R2, SCREEN_LAST_WORD
	ciclo_limpa:
	MOV [R0], R1
	ADD R0, 2
	CMP R0, R2
	JNZ ciclo_limpa

	POP R2
	POP R1
	POP R0
	RET




;-------------------------------------------RESET_GAME--------------------------------
;rotina que faz reset ao jogo
RESET_GAME:

	PUSH R0
	PUSH R1
	PUSH R2

	MOV R0, 0
	
	reset_avioes_balas:
	MOV R1, estado_avioes
	MOV R3, estado_balas
	MOV R2, NUM_MAX_AVIOES
	SHL R2, 1
	ciclo_reset_avioes:
	SUB R2, 2
	MOV [R1 + R2], R0
	MOV [R3 + R2], R0
	JNZ ciclo_reset_avioes

	MOV R1, estado_caixa
	MOV [R1], R0

	MOV R1, pos_canhao
	MOV R2, XX_INIT_CANHAO
	MOV [R1], R2
	ADD R1, 2
	MOV R2, YY_INIT_CANHAO
	MOV [R1], R2

	MOV R1, BALAS_DISP
	MOV R2, NUM_BALAS_INIT
	MOV [R1], R2
	CALL update_balas

	MOV R1, estado_balas
	MOV R2, NUM_MAX_BALAS
	SHL R2, 1
	ciclo_reset_balas:
	SUB R2, 2
	MOV [R1+ R2], R0
	JNZ ciclo_reset_balas

	MOV R0, -1
	MOV R1, PONTUACAO
	MOV [R1], R0
	CALL aumenta_pontuacao

	POP R2
	POP R1
	POP R0
	RET


;INTERRUPÇOES
intAVIOES:
	PUSH R1
	PUSH R2

	MOV R1, estado_int_avioes
	MOV R2, 1
	MOV [R1], R2

	MOV R1, estado_int_explosoes
	MOV R2, [R1]
	ADD R2, 1
	MOV [R1], R2

	POP R2
	POP R1
	RFE



intBALAS:
	PUSH R1
	PUSH R2

	MOV R1, estado_int_balas
	MOV R2, 1
	MOV [R1], R2

	POP R2
	POP R1
	RFE


GAME_OVER:
	PUSH R0
	PUSH R1
	PUSH R4

	MOV R0, GAME
	MOV R4, 5
	MOV R1, 6
	CALL escreve_imagens


	MOV R0, OVER
	MOV R4, 16
	MOV R1, 6
	CALL escreve_imagens

	POP R4
	POP R1
	POP R0

escreve_imagens:		;R0 endereço da imagem, R4 linha a começar R1 linhas a escrever
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R5
	MOV R2, SCREEN			;endereço do byte inicial do ecran
	SHL R4, 2
	ADD R2, R4		
	SHL R1, 2
	ADD R1, R2

	ciclo_so:
		CMP R2, R1
		JGE so_done
		MOV R4, [R0]		
		MOV [R2], R4		
		ADD R0, 2
		ADD R2, 2
		JMP ciclo_so
	so_done:
	POP R5
	POP R4
	POP R2
	POP R1
	POP R0
	RET
