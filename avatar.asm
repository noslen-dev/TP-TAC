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
    
		flag           db    0 ;flag para condicoes logicas
		index          byte  0
    timer          db    "            "
		STR12	 		     DB 		"            "	; String para 12 digitos
		
		
    seg_timer      dw    0

		Horas			     dw		 0				; Vai guardar a HORA actual
		Minutos			   dw		 0				; Vai guardar os minutos actuais
		Segundos		   dw		 0				; Vai guardar os segundos actuais
		Old_seg			   dw		 0				; Guarda os ultimos segundos que foram lidos
		Tempo_init	   dw		 0				; Guarda O Tempo de inicio do jogo
		Tempo_j			   dw		 0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	 dw		 100			; tempo maximo de Jogo
		String_TJ		   db		 "    /100$"

		String_num 		 db 		"  0 $"
    str_nivel_1  	 db	    "ISEC$"	
		Construir_nome db	    "            $"	
		Dim_nome		   dw		  5	; Comprimento do Nome
		indice_nome		 dw		  0	; indice que aponta para Construir_nome
		
		Fim_Ganhou		 db	    " Ganhou $"	
		Fim_Perdeu		 db	    " Perdeu $"	

    Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich         	  db      'labi1.TXT',0
    HandleFich      dw      0
    car_fich        db      ?

		string	  db	"Teste pratico de T.I",0
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posicao anterior de y
		POSxa			db	3	; Posicao anterior de x
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
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
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
		MOV 	timer[7],'$'
		GOTO_XY	57,0 ;canto do ecra
		MOSTRA	timer
    ;;resetar o nosso timer;;;;
		mov seg_timer, 0
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
        lea     dx,Fich
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
		MOV	AH,0BH
		INT 21h ;ve se há carater disponivel no stdin
		cmp AL,0 ;se al=0, nao ha carater
		je	sem_tecla
		
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
isalpha PROC
    push AX
		pushf

		mov flag, 0 ;resetar sempre a flag
    mov al, Car
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




;########################################################################
; Avatar
;Basicamente a estrategia e a seguinte: 
;Apanhamos o carater em que o cursor esta, escrevemo-lo no canto do ecra, escrevemos o avatar nessa posicao
;lemos uma seta, alteramos a posicao do cursor, repomos o carater sacado na posicao anterior do
;cursor e movemos o avatar para a proxima posicao(inserida pela seta)

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax

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
			cmp al, 177
			jz  PAREDE
      
			goto_xy	POSxa,POSya ;como andamos para uma nova posicao, temos de voltar atras
    
      call isalpha    ;vemos se o carater anterior e uma letra(Car)
			                
			mov ah, flag
			cmp flag, 0 
			jnz letra               ;o carater e uma letra vamos para um label que 
			                        ;apenas nos muda o Car


letra_cont: ; 
			mov		ah, 02h
			mov		dl, Car			      ;Repoe Caracter guardado 
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
LER_SETA:	call 	LE_TECLA ;apanhamos uma tecla e fica em al
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	; vemos se al==escape
			JE		FIM     ; se for saimos
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
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
    mov Car, 32
		jmp letra_cont
fim:				
			RET
AVATAR		endp


;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
		call		apaga_ecran 
		goto_xy		0,0
		call		IMP_FICH ;escrevemos o ficheiro
		call 		AVATAR   ;chamamos o boneco e tudo o k tem a ver com mexe-lo
		goto_xy		0,22   ;final do ecra?
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main


		
