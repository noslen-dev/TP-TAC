;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostracao da navegacao do Ecran com um avatar
;
;		arrow keys to move 
;		press ESC to exit
;   quando se le um carater, esse carater desaparece e o cursor fica no mesmo
;   sitio
;   quando se escreve um carater por cima de outro, o de baixo desaparece
;   por isso e necessario guarda-lo e repo-lo
;--------------------------------------------------------------


.8086
.model small
.stack 2048

dseg	segment para public 'data'
    trocas         byte   ?
    str_nivel  	   byte	  "                    "
    str_nivel_1    byte   "ISECISECISECIS$     "
		str_nivel_2    byte   "MASMMASMMASMMASMAS$ "
		str_nivel_3    byte   "ENGENHARIA$         "
		str_nivel_4    byte   "MICROSOFT$          "
		str_nivel_5    byte   "MACROASSEMBLER$     "
		str_ptr        word    ? ;ponteiro para as strings de nivel
    
		op             byte    ?             ; variavel que representara a opcao selecionada pelo utilizador
   	menu_str       byte    "MENU$"
		jogar_str      byte    "1 - Jogar$"
		top10_str      byte    "2 - Top 10$"
		sair_str       byte    "3 - Sair$"
		escolha_str    byte    "Escolha: $"
		Nome_STR		db 	       "          $"
    Nome_aux_str byte      "           $"
		ArrayTopInicial	byte 20 DUP (0)
		AjudaStr byte ' ',0
        array_inteiros  byte  10 dup(?)

		ControloEscritaNomes db 0
		ControloTr dw 0;
		PonteiroFicheiro word 0
		str_Pontos 	   db      "Pecas Apanhadas:00$"
		FichTop        db      'top.TXT',0

		controloPos db '1'
		pontos        	word     0
		pontosUnidades db 0
		pontosDezenas db 0
		ControloOrdArray word 0

		n_niveis       byte     2            ; variavel que representa o numero de niveis
		flag           sbyte    0           ;flag para condicoes logicas
    	timer          db    "            " ;string que ira mostrar o nosso tempo
		STR12	 		     DB 		"            "	; String para 12 digitos
		fim_jogo       byte   2               ;variavel que indica se o jogo ja acabou ou nao
    ;a 2 significa que e para passar ao proximo nivel

    	seg_timer      dw    0        ;contador de segundos

		Horas			     dw		 0				; Vai guardar a HORA actual
		Minutos			   dw		 0				; Vai guardar os minutos actuais
		Segundos		   dw		 0				; Vai guardar os segundos actuais
		Old_seg			   dw		 0				; Guarda os ultimos segundos que foram lidos


		Construir_nome db	    "                   $"	
		
		Fim_Perdeu		 db	    " Perdeu $"	

    Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    nome_fich       db      'labi1.TXT',0
    HandleFich      dw      0
    car_fich        db      ?
	CharNome 		db      '2'
	xxx 			word 'x'

		Car				      db	    32	; Guarda um caracter do Ecran 
		Cor				      db	    7	; Guarda os atributos de cor do caracter
		POSy			      db	    3	; a linha pode ir de [1 .. 25]
		POSx		      	db	    3	; POSx pode ir [1..80]	
		POSya			      db	    3	; Posicao anterior de y
		POSxa			      db	    3	; Posicao anterior de x
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da pagina-->tem que ser 0 para ele escrever no ecra
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM



; FIM DAS MACROS


;#########################################################
Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		MOV AH, 2CH             ; Buscar as horas
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		    ; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			      ; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 
;###########################################################

mostra_seg PROC ;mostra um timer que vai do zero ate 99
  ;;armazenar;;;
    PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
    ;;;segundos;;;;;
		mov 	ax, seg_timer	    ;carregar os segundos atuais
		cmp   ax, 100
    je    time_100

		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	timer[0],al   ; Construir string
		MOV 	timer[1],ah
		MOV 	timer[2],'/'
		MOV 	timer[3],'1'		
		MOV 	timer[4],'0'
		MOV 	timer[5],'0'
		MOV 	timer[6],'s'
		MOV 	timer[7],'$'
    jmp   mostra_time
time_100:
    MOV 	timer[0],'1'   ; Construir string
		MOV 	timer[1],'0'
		MOV 	timer[2],'0'
		MOV 	timer[3],'/'		
		MOV 	timer[4],'1'
		MOV 	timer[5],'0'
		MOV 	timer[6],'0'
		MOV 	timer[7],'s'
		MOV 	timer[8],'$'
		GOTO_XY	57,0 ;canto do ecra
		MOSTRA	timer

  

		;;tempo chegou ao fim == acabou o jogo
		mov fim_jogo, 1
    jmp fim_time
mostra_time:    
    GOTO_XY	57,0 ;canto do ecra
		MOSTRA	timer
		inc     seg_timer
fim_time:
	;;repor;;;;
		POP DX
		POP CX
		POP BX
		POP AX
    ret
mostra_seg ENDP

;;;######################
Reseta_String PROC
    
		PUSH si
		PUSH ax
		PUSHF

		lea si, Construir_nome
Continua:
    mov al, ' '
		cmp al, [si] ;fim da palavra
		jz Fim
		
	  mov [si], al ; construir nome fica com espacos em branco
	  inc si
	  jmp Continua
Fim:
		POPF
		POP ax
		POP si
		RET
Reseta_String ENDP
;#####
strcpy PROC ;coloca os conteudos de aux em nome
    push si
		push di
		push ax
		pushf
	  
		lea si, Nome_STR
		lea di, Nome_aux_str
copia:		
    mov al, [di]
		cmp al, '$'
		je  fim
		mov [si], al
		inc si
		inc di
		jmp copia
fim:
    popf
		pop ax
		pop di
		pop si
		ret
strcpy ENDP



;#################
init_string PROC ;coloca em str_nivel, a string que esta em str_ptr
    push si
    push ax
		push di
		pushf

		lea si, str_nivel
		mov di, str_ptr
inicio_init_str:
    mov al, [di]
		cmp al, '$'
		jz fim_init_string
		mov [si], al
		inc si
		inc di
		jmp inicio_init_str
fim_init_string:
    mov al, '$'
		mov [si], al ;terminar a string

    popf
		pop di
		pop ax
		pop si
    ret
init_string ENDP
;#################

IMP_TOP	PROC

		push ax
		push si

		xor si, si
		xor ax,ax
		mov ControloTr, 0
		;abre ficheiro
        mov     ah,3dh
        mov     al,2
        lea     dx,FichTop
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0; EOF?
		je		fecha_ficheiro
		cmp ControloTr, 1
		je Adiciona1
		cmp ControloTr, 2
		je Adiciona2
		cmp ControloTr, 3
		je FimControlo
		cmp car_fich, '-'
		je MudaControlo
		jne NaoIgual
MudaControlo:
		mov ControloTr, 1
		jmp NaoIgual
Adiciona1: 
	mov ah, car_fich
	mov ArrayTopInicial[si], ah
	inc si
	mov ControloTr, 2
	jmp NaoIgual

Adiciona2:
	mov ah, car_fich
	mov ArrayTopInicial[si], ah
	inc si
	mov ControloTr, 3
	jmp NaoIgual

FimControlo:
	mov ControloTr, 0
NaoIgual:
		mov     ah,02h
		mov	  	dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		pop ax	
		pop si
		RET
		
		
IMP_TOP	endp	

;##########################################################
Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; Verifica se os segundos mudaram desde a ultima leitura
		je		fim_horas		  	; Se a hora não mudou desde a última leitura sai.
		call  mostra_seg      ;vai o counter do jogo
		
		
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 

		mov 	ax,Horas
		MOV		bl, 10         ;horas a dividir por 10|| ex 17h/10
		div 	bl
		add 	al, 30h				; al fica com 1|| 1+'0'=='1'
		add		ah,	30h				; ah fica com 7|| 7+'0'=='7'
		MOV 	STR12[0],al		; Formar a string 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 2,0
		MOSTRA STR12 ;horas nossas
        
		mov 	ax,  Minutos ;mesma coisa que em cima
		MOV 	bl,  10     
		div 	bl
		add 	al,  30h				; Caracter Correspondente às dezenas
		add		ah,	 30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],  al			; 
		MOV 	STR12[1],  ah
		MOV 	STR12[2],  'm'		
		MOV 	STR12[3],  '$'
		GOTO_XY	6,0
		MOSTRA	STR12 		

		;;;segundos;;;;;
		mov 	ax,Segundos    ;mesma coisa que em cima
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
    GOTO_XY	10,0
		MOSTRA	STR12 				       
						
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP
;#########################################################









;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,nome_fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		    jc		  erro_ler
		    cmp		  ax,0		;EOF?
		    je		  fecha_ficheiro
        mov     ah,02h
		    mov	  	dl,car_fich
		    int		  21h
		    jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
sem_tecla:
		call Trata_Horas
     
		cmp fim_jogo, 1 ;acabou o jogo?
		jz  SAI_TECLA   ;saimos

		MOV	AH,0BH
		INT 21h ;ve se há carater disponivel no stdin
		cmp AL,0 ;se al=0, nao ha carater
    

		je	sem_tecla ;continuamos
		
		MOV	AH,08H 
		INT	21H
		MOV	AH,0
		CMP	AL,0
		JNE	SAI_TECLA
		MOV	AH, 08H
		INT	21H
		MOV	AH,1
SAI_TECLA:	
		RET
LE_TECLA	ENDP



;################################
isalpha PROC ;flag=1 se o carater em al for uma letra, 0 caso contrario
    push AX
		pushf

		mov flag, 0 ;resetar sempre a flag
		cmp al, 'A'
		jb  falso
		cmp al, 'Z'
		ja  falso
    mov flag, 1 ;o carater e uma letra

		popf
		pop AX
    ret
falso:    
    popf
		pop AX
    ret
isalpha ENDP
;##########################################

strcmp PROC ;flag fica a 1 se as strings em di e si forem iguais
    push di
		push si
		push ax
		pushf
    mov flag, 0 ;resetar a flag
compara:
    mov al, [si]
		cmp al, '$'
		jz  iguais
		cmp al, [di]
		jnz diferentes
		inc si
		inc di
		jmp compara
    
iguais:
    mov flag, 1
diferentes: ;a flag ja esta a zero==diferente
    popf
		pop ax
		pop si
		pop di
    ret

strcmp ENDP
;############################




;####################
;;;mete 1 em flag se o jogador venceu
;;;mete 0 em flag se os carateres sao iguais mas ainda nao acabou
;;;mete -1 em flag se os carateres foram apanhados por ordem errada
;;;usa carater que esta em al
form_game PROC ;si para str_nivel || di para Construir_nome !!carater esta em al
    pushf
    push ax
    
    
    mov flag, 0 ;resetar a flag
    cmp al, [si] 
    jz  iguais ; o carater apanhado e igual ao correspondente na string final
    jmp diferentes

iguais:
    mov  [di], al ;metemos o carater na string
    
    call strcmp ;flag=1 se as strings forem iguais
    cmp  flag, 1
    jz   venceu
    ;os carateres sao iguais mas ainda nao acabou
    inc  di
    inc  si
    mov  flag, 0; ainda nao acabou
    jmp  fim
diferentes:
    mov flag, -1 ;o carater foi apanhado por ordem errada
    jmp fim
venceu: ;a flag ja e 1
fim:
    pop ax
    popf
    ret
form_game ENDP
;####################
menu PROC
     push ax
     call apaga_ecran
     goto_xy 37,10
		 MOSTRA  menu_str
		 goto_xy 35,12
		 MOSTRA  jogar_str
		 goto_xy 35,14
		 MOSTRA  top10_str
		 goto_xy 35,16
		 MOSTRA  sair_str
		 goto_xy 35,18
		 MOSTRA  escolha_str
		 mov ah, 1 
		 int 21h
		 mov op, al
		 pop ax
		 ret
menu ENDP

;########################################################################
inc_cont PROC
    push  ax
		push  bx

    inc   pontos
		mov 	ax, pontos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				
		add		ah,	30h			
    mov   str_Pontos[16],al
    mov   str_Pontos[17],ah

		pop bx
		pop ax
    ret
inc_cont ENDP

;########################################################################
; Avatar
;Basicamente a estrategia e a seguinte: 
;Apanhamos o carater em que o cursor esta, escrevemo-lo no canto do ecra, escrevemos o avatar nessa posicao
;lemos uma seta, alteramos a posicao do cursor, repomos o carater sacado na posicao anterior do
;cursor e movemos o avatar para a proxima posicao(inserida pela seta)

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
Inicio:
      lea si, str_nivel      ;si ponteiro para string nivel
			lea di, Construir_nome ;di ponteiro para string que ira ser formada

      call reset_pos
			call Reseta_String
			;mostrar string dos pontos
			GOTO_XY 25,0
	    MOSTRA str_Pontos

			goto_xy	POSx,POSy ; vai para a posicao 3 3(default, inicio do labirinto)
			mov 	ah, 08h		  ; guarda o carater que esta na posicao do cursor
			mov		bh,0			  ; numero da pagina-->0 para ser ecra
			int		10h			
			mov		Car, al			; Guarda o Caracter que esta na posicao do Cursor
			mov		Cor, ah			; Guarda a cor que esta na posicaoo do Cursor	
	    ;int 10h / AH=08h guarda o carater que esta na posicao do cursor em AL e o atributo em ah. BH tem o numero da pagina

CICLO: goto_xy	POSxa,POSya
      
			;ler carater que esta em POSx e POSy e ver se ele e uma parede
			;se esse carater for uma parede, entao posx,y=anteriores
			;nao reponho o carater
			;jmp le tecla
      goto_xy	POSx,POSy
			mov ah, 08h
			mov bh,0			    
			int 10h	
			cmp al, 177 ;carater fica em al
			jz  PAREDE
      
      call isalpha    ;vemos se o carater na posicao atual e uma letra
			              
			cmp flag, 1    
			jz  letra      ;e letra
			; ver se esta na ordem certa, se o jogo acabou, etc...
      
      goto_xy POSxa, POSya

letra_cont: 
			mov		ah, 02h
			mov		dl, 32			      ;O carater reposto sera sempre um espco em branco 
			int		21H		            ;escreve carater que esta em dl
		
			goto_xy	POSx,POSy		
			mov 	ah, 08h
			mov		bh,0			    
			int		10h		      ; apanha o carater na posicao do cursor
			mov		Car, al			; Guarda o Caracter que esta na posicao do Cursor
			mov		Cor, ah			; Guarda a cor que esta na posicao do Cursor
	    


			
			goto_xy	78,0			
			mov		ah, 02h			
			mov		dl, Car	
			int		21H			
	    ;Mostra o caracter que estava na posicao do AVATAR no canto do ecra (78,0)
			
			goto_xy	POSx,POSy	;voltar com o cursor a posicao em que e para escrever o avatar




;;;escreve o avatar(na posicao atual) e guarda as coordenadas atuais
IMPRIME:  mov		ah, 02h
			    mov		dl, 190	  ; Coloca AVATAR
			    int		21H	      ;escreve o carater em dl(190)
			    goto_xy	POSx,POSy	
		
			    mov		al, POSx	; Guarda a posicao do cursor
			    mov		POSxa, al
			    mov		al, POSy	; Guarda a posisao do cursor
			    mov 	POSya, al
;;;;;Posxa=Posx && Posya=Posy --> guarda a posicao atual em variavies que representam a posicao anterior
;;;Atualizamos a posicao do cursor(anterior=atual)
LER_SETA:	call 	LE_TECLA 
      
      cmp   fim_jogo, 1; acabou o jogo?
			jz    acabou_tempo

			cmp		ah, 1 
			je		ESTEND
			CMP 	AL, 27	; vemos se al==escape
			JE		escape     ; se for saimos
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO: cmp		al, 50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

PAREDE:   mov   al, POSxa	 ;repoe as coordenadas anteriores como as atuais
			    mov		POSx, al
			    mov		al, POSya	
			    mov 	POSy, al
					goto_xy	POSx,POSy;voltar onde estavamos antes,para o cursor nao ficar na parede
					jmp   LER_SETA

letra:
    ;operacoes no contador de pecas
    call form_game
    cmp flag, 1 ;venceu?
    jz  vitoria
    cmp flag, -1 ;perdeu?
	  jz recomeca

    ; e porque continuamos no jogo
		call  inc_cont ;peca correta

		GOTO_XY 25,0
	  MOSTRA str_Pontos

    goto_xy 11, 14
    MOSTRA  Construir_nome ;escrevemos no sitio certo a nossa string
    goto_xy POSxa, POSya
    jmp letra_cont
vitoria:
    call  inc_cont ;peca tambem conta

    goto_xy POSxa, POSya ;onde estamos agora
		mov		ah, 02h
	  mov		dl, 32	  ; Coloca espaco em branco
		int		21H	   
		;;escrevemos um espaco em branco onde o avatar esta

    goto_xy POSx, POSy ;posicao onde o carater da vitoria esta
		mov		ah, 02h
	  mov		dl, 190	  
		int		21H	
    ;colocamos o avatar nessa posicao
     
		;mostrar string dos pontos
		GOTO_XY 25,0
	  MOSTRA str_Pontos

		;mostrar palavra completa
    goto_xy 11, 14
		MOSTRA Construir_nome
		;;;;
		mov  fim_jogo, 2 ;passar ao proximo nivel
		jmp fim
recomeca:
   mov pontos, 0 ;resetar as letras apanhadas
   mov str_Pontos[16],48
   mov str_Pontos[17],48
  ;resetar o construir nome
	call Reseta_String
	;repor as variaveis
	call reset_pos
	call apaga_ecran
	goto_xy 0,0
	call IMP_FICH
	jmp Inicio
acabou_tempo:
    goto_xy 15, 20
    MOSTRA Fim_Perdeu
escape:
    mov fim_jogo, 1; escape==acabar jogo
fim:			
			RET
AVATAR		endp

;coloca as variaveis que representam as posicoes no seu estado inicial
reset_pos PROC
    mov POSx, 3
		mov POSy, 3
		mov POSxa,3
		mov POSya,3
		ret
reset_pos ENDP

;########################################################################
GuardaNome PROC

		
		PUSH SI
		PUSH AX
		;Nome_STR
		xor si,si
		
ContinuaGuardaNome:
		xor ax,ax
		mov ah, 1 
		int 21h
		cmp al, 30h
		je FimGuardaNome
		jne GuardaCHAR
GuardaCHAR:
		mov Nome_STR[SI], al
		INC SI
		jmp ContinuaGuardaNome

FimGuardaNome:
		POP SI
		POP AX
		ret
GuardaNome ENDP
;########################################################################
MArray PROC

		push si
		pushf
		xor si,si	
Cont:
		mov     ah,02h
		mov	  	dl, ArrayTopInicial[si]
		int		21h
		inc     si
		cmp     si, 20
		jne     Cont

		popf
		pop si
		ret
MArray ENDP

		

;#################
sort PROC
    push si
		push ax
		push dx
		xor si, si
    inc si
		
		mov dh, ArrayTopInicial[2]
		mov dl, ArrayTopInicial[3]
		mov ah, ArrayTopInicial[4]
		mov al, ArrayTopInicial[5]
		mov ArrayTopInicial[2],ah
		mov ArrayTopInicial[3],al
		mov ArrayTopInicial[4], dh
		mov ArrayTopInicial[5], dl


		mov dh, ArrayTopInicial[4]
		mov dl, ArrayTopInicial[5]
		mov ah, ArrayTopInicial[8]
		mov al, ArrayTopInicial[9]
		mov ArrayTopInicial[4],ah
		mov ArrayTopInicial[5],al
		mov ArrayTopInicial[8], dh
		mov ArrayTopInicial[9], dl

		mov dh, ArrayTopInicial[6]
		mov dl, ArrayTopInicial[7]
		mov ah, ArrayTopInicial[12]
		mov al, ArrayTopInicial[13]
		mov ArrayTopInicial[6],ah
		mov ArrayTopInicial[7],al
		mov ArrayTopInicial[12], dh
		mov ArrayTopInicial[13], dl

		mov dh, ArrayTopInicial[8]
		mov dl, ArrayTopInicial[9]
		mov ah, ArrayTopInicial[16]
		mov al, ArrayTopInicial[17]
		mov ArrayTopInicial[8],ah
		mov ArrayTopInicial[9],al
		mov ArrayTopInicial[16], dh
		mov ArrayTopInicial[17], dl

		mov dh, ArrayTopInicial[10]
		mov dl, ArrayTopInicial[11]
		mov ah, ArrayTopInicial[16]
		mov al, ArrayTopInicial[17]
		mov ArrayTopInicial[10],ah
		mov ArrayTopInicial[11],al
		mov ArrayTopInicial[16], dh
		mov ArrayTopInicial[17], dl


		mov dh, ArrayTopInicial[14]
		mov dl, ArrayTopInicial[15]
		mov ah, ArrayTopInicial[16]
		mov al, ArrayTopInicial[17]
		mov ArrayTopInicial[14],ah
		mov ArrayTopInicial[15],al
		mov ArrayTopInicial[16], dh
		mov ArrayTopInicial[17], dl


		pop dx
		pop si
		pop ax
    ret
sort ENDP

reordenaArray PROC
    push si
		push ax
		push dx
		xor si, si
    	inc si
		mov dh, ArrayTopInicial[10]
		mov dl, ArrayTopInicial[11]
		mov ah, ArrayTopInicial[2]
		mov al, ArrayTopInicial[3]
		mov ArrayTopInicial[10],ah
		mov ArrayTopInicial[11],al
		mov ArrayTopInicial[2], dh
		mov ArrayTopInicial[3], dl

		mov dh, ArrayTopInicial[10]
		mov dl, ArrayTopInicial[11]
		mov ah, ArrayTopInicial[4]
		mov al, ArrayTopInicial[5]
		mov ArrayTopInicial[10],ah
		mov ArrayTopInicial[11],al
		mov ArrayTopInicial[4], dh
		mov ArrayTopInicial[5], dl

		mov dh, ArrayTopInicial[10]
		mov dl, ArrayTopInicial[11]
		mov ah, ArrayTopInicial[6]
		mov al, ArrayTopInicial[7]
		mov ArrayTopInicial[10],ah
		mov ArrayTopInicial[11],al
		mov ArrayTopInicial[6], dh
		mov ArrayTopInicial[7], dl

		mov dh, ArrayTopInicial[12]
		mov dl, ArrayTopInicial[13]
		mov ah, ArrayTopInicial[6]
		mov al, ArrayTopInicial[7]
		mov ArrayTopInicial[12],ah
		mov ArrayTopInicial[13],al
		mov ArrayTopInicial[6], dh
		mov ArrayTopInicial[7], dl

		mov dh, ArrayTopInicial[12]
		mov dl, ArrayTopInicial[13]
		mov ah, ArrayTopInicial[8]
		mov al, ArrayTopInicial[9]
		mov ArrayTopInicial[12],ah
		mov ArrayTopInicial[13],al
		mov ArrayTopInicial[8], dh
		mov ArrayTopInicial[9], dl

		mov dh, ArrayTopInicial[12]
		mov dl, ArrayTopInicial[13]
		mov ah, ArrayTopInicial[10]
		mov al, ArrayTopInicial[11]
		mov ArrayTopInicial[12],ah
		mov ArrayTopInicial[13],al
		mov ArrayTopInicial[10], dh
		mov ArrayTopInicial[11], dl


		mov dh, ArrayTopInicial[16]
		mov dl, ArrayTopInicial[17]
		mov ah, ArrayTopInicial[10]
		mov al, ArrayTopInicial[11]
		mov ArrayTopInicial[16],ah
		mov ArrayTopInicial[17],al
		mov ArrayTopInicial[10], dh
		mov ArrayTopInicial[11], dl

		mov dh, ArrayTopInicial[14]
		mov dl, ArrayTopInicial[15]
		mov ah, ArrayTopInicial[10]
		mov al, ArrayTopInicial[11]
		mov ArrayTopInicial[14],ah
		mov ArrayTopInicial[15],al
		mov ArrayTopInicial[10], dh
		mov ArrayTopInicial[11], dl

		

		pop dx
		pop si
		pop ax
    ret
reordenaArray ENDP

;#################
constroi_array_int  PROC
    push si
		push di
		push ax
		push bx
    
		lea di, array_inteiros
    lea si, ArrayTopInicial
    mov bl, 10 
    mov cx, 10
ciclo:	
    xor   ax, ax
    mov al, [si]
		sub al, 30h
    mul bl; ax=al*10
		mov ah, [si+1]
		sub ah, 30h
		add al, ah

		mov [di], al

		add di, 1
		add si, 2
    loop ciclo
    
		pop bx
		pop ax
		pop di
		pop si
    ret
constroi_array_int ENDP
;####################

deconstroi_array_int PROC
    push si
		push di
		push ax
		push bx
    
		lea di, array_inteiros
    lea si, ArrayTopInicial
    mov bl, 10 
    mov cx, 10
ciclo:
    xor   ax, ax
		mov 	al, [di]	         
		div 	bl ;ax/10--->quociente em al e resto em ah
		add 	al, 30h	;dezenas			
		add		ah,	30h	;unidades
		mov  	[si], al
		mov   [si+1], ah	

		add   si, 2
		add   di, 1
		loop ciclo	
    
		pop bx
		pop ax
		pop di
		pop si
		ret
deconstroi_array_int ENDP
;#######################
insert_points  PROC
    	push si
		push di
		push ax
		push cx
    
		lea si, array_inteiros
		lea di, array_inteiros 
		add di, 9 ; ultima posicao

		mov cx, 10
		mov ax, pontos ; vai para al
ciclo:
    	cmp al, [si]
		jae insert_pos
		inc si
		inc controloPos
		loop ciclo
		jmp fim
insert_pos:
		cmp di, si
		jb  insert_pontos
		mov ah, [di-1]
		mov [di], ah
		dec di
    jmp insert_pos
insert_pontos:
    mov [si], al
fim:
    pop cx
		pop ax
		pop di
		pop si 
    ret
insert_points  ENDP


;#######################



AltArrTop	PROC

		    push ax
		    push si
    
		    xor si, si
		    xor ax,ax
		    mov ControloTr, 0
		    ;abre ficheiro
        mov     ah,3dh
        mov     al,2
        lea     dx,FichTop
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		    jc		  erro_ler
		    cmp		  ax,0; EOF?
		    je		  fecha_ficheiro
		    cmp     ControloTr, 1
		    je      Adiciona1
				cmp     ControloTr, 2
				je      Adiciona2
				cmp     ControloTr, 3
				je      FimControlo
				cmp     car_fich, '-'
				je      MudaControlo
				jne     NaoIgual
MudaControlo:
		mov ControloTr, 1
		jmp NaoIgual
Adiciona1: 
	mov ah, car_fich
	mov ArrayTopInicial[si], ah
	inc si
	mov ControloTr, 2
	jmp NaoIgual

Adiciona2:
	mov ah, car_fich
	mov ArrayTopInicial[si], ah
	inc si
	mov ControloTr, 3
	jmp NaoIgual

FimControlo:
	mov ControloTr, 0
NaoIgual:
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		pop ax	
		pop si
		RET
		
		
AltArrTop	endp
;########################################################################

AlteraTop	PROC

		push ax
		push si


		xor si,si
		xor ax,ax
		;abre ficheiro
    mov     ah,3dh
    mov     al,2
    lea     dx,FichTop
    int     21h
    jc      erro_abrir
    mov     HandleFich,ax
    jmp     ler_ciclo
		

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f
		
ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		
		    jc		 erro_ler
		    cmp		 ax,0; EOF?
		    je		 fecha_ficheiro

		    cmp     car_fich, '-' ; o que apanhamos e um '-' ?
		    je      Escreve1
		    cmp     si, 19
		    je fecha_ficheiro
		    jne ler_ciclo
Escreve1:

		mov  ah, 40h ;escrever
  	mov  bx, HandleFich
 		mov  cx, 1
  	lea  dx, ArrayTopInicial[si]
 		int  21h 
		inc si

		mov  ah, 40h
  	mov  bx, HandleFich
 		mov  cx, 1
  	lea  dx, ArrayTopInicial[si]
 		int  21h
		inc si
;;escrevemos "um numero" == dois carateres
		jmp ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		pop ax	
		pop si
		ret
AlteraTop	endp

MControloPos PROC
		push ax

		mov ah, 2
		mov dl, controloPos
		int 21h  

		pop ax
		ret 
MControloPos ENDP

;PosicaoReal PROC
;		push cx
;		push ax

;		mov ah, controloPos
;		mov cl, 2
;		div cl
;		mov controloPos, 2

;		pop cx
;		pop ax
;		ret
;PosicaoReal ENDP
;########################################################################
AlteraNomesTop	PROC

		push ax
		push si
		push bx
		push cx
    
		xor si,si
		xor ax,ax
		;abre ficheiro
    mov     ah,3dh
    mov     al,2 ;read and write
    lea     dx,FichTop ;nome do ficheiro
    int     21h
    jc      erro_abrir
    mov     HandleFich,ax ;file handle==endereco do ficheiro
    jmp     ler_ciclo
		

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f
		
ler_ciclo:
    xor     si, si
    mov     ah,3fh          ; read from file
    mov     bx,HandleFich
    mov     cx,1            ;bytes para ler
    lea     dx,car_fich     ;buffer para dados==onde vao ficar os dados
    int     21h
    jc		  erro_ler
    cmp		  ax,0
    je		  fecha_ficheiro
    mov     bl, controloPos
    cmp     car_fich, bl ; estamos no numero em que e para inserir o novo nome
    je      ProcuraPonto ;vemos se tem um ponto a frente
    je      fecha_ficheiro
    jne     ler_ciclo
ProcuraPonto:
    mov     ah,3fh ;ler do ficheiro
    mov     bx,HandleFich
    mov     cx,1
    lea     dx,car_fich
    int     21h
    cmp     car_fich, '.' ; lemos um ponto, logo guardamos e escrevemos o nome
    je      EscreveNome
    jne     ler_ciclo
EscreveNome:
    ;guardar o nome que la esta
		mov     ah,3fh 
    mov     bx,HandleFich
    mov     cx,10 ;tamanho de um nome
    lea     dx,Nome_aux_str ; local onde o nome vai ficar armazenado
    int     21h
		
		; voltar atras 10 bytes
    mov ah, 42h
		mov al, 1
		mov bx, HandleFich
		mov cx, -1 ;necessarioooo
		mov dx, -10
		int 21h
    ;####

    mov ah, 40h ;escrever o nome
    mov bx, HandleFich
    mov cx, 10 ;escrever 10 bytes==um nome
    lea dx, Nome_STR   ;informacao a escrever
    int 21h
    
		cmp  controloPos, '0' ; '0' do "10"
		je   fecha_ficheiro
		;##################
		call strcpy ; coloca em Nome_STR os conteudos de Nome_aux_str
		inc  controloPos
		cmp  controloPos, 58 ; numero 10, supostamente
		je   number_10
		;##############
		cmp  controloPos, 6 ;rewind para o principio do ficheiro
		mov ah, 42h
		mov al, 0
		mov bx, HandleFich
		mov cx, 0 
		mov dx, 0
		int 21h 
		;#############
    jmp  ler_ciclo
number_10:
    mov controloPos, '0'
		jmp ler_ciclo
erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		pop cx
		pop bx
		pop ax	
		pop si
		ret
AlteraNomesTop	endp
;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		;#####################
    call menu 
		cmp  op, '3' ;sair? 
		jz   fim_main
		cmp  op, '2'; top 10?
		jz   top10
		; opcao 1==jogar
    lea bx, str_nivel_1 
		mov str_ptr, bx ; str_ptr vai ser ponteiro para as strings nivel
		mov n_niveis, 2 ;numero de niveis
inicio_jogo:
    cmp fim_jogo, 2; passar para o proximo nivel? 
		jnz fim_loop
		cmp n_niveis, 0
		jz  fim_loop
    ;corpo

		mov  seg_timer, 0 ;resetar o timer
		call init_string
		call apaga_ecran
    goto_xy 0,0
		call IMP_FICH
		call AVATAR
		;pos intrucoes
		dec  n_niveis
		add  str_ptr, 20 ;passar para a proxima string
		add nome_fich[4], 1 ;passar para o proximo ficheiro

		jmp inicio_jogo
fim_loop:		
    cmp fim_jogo, 2; se ficamos sempre a subir de nivel
    jnz derrota
		goto_xy 15,20
    call GuardaNome
	  call apaga_ecran
	  call AltArrTop             ;constroi o array de pontuacoes 
	  call sort                  ;ordena-o
	  call constroi_array_int    ;controi um array com os numeros das pontuacoes
	  call insert_points         ;insere os nossos pontos no array
	  call deconstroi_array_int  ;volta a meter esse array em carateres para ser escrito
	  call reordenaArray         ;coloca o array na forma correta para ser escrito no ficheiro
		call apaga_ecran
	  call MControloPos          ;escreve a posicao em que o nome deve ser inserido
	  call AlteraTop             ;escreve o array de pontuacoes no ficheiro
	  call AlteraNomesTop        ;escreve o nome por cima da posicao em que a nova pontuacao foi inserida

	  jmp fim_main
derrota:
    goto_xy 15, 20
		MOSTRA  Fim_Perdeu
		jmp     fim_main
		
top10:
    call apaga_ecran
    goto_xy 0,0
	call IMP_TOP	
		
fim_main:
  
		;#######################################
		goto_xy		0,22   ;final do ecra?
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main
