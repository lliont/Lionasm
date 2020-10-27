;  Lion System Rom
;  (C) 2015-2018 Theodoulos Liontakis 

VBASE		EQU		32768
VBASE1	EQU		32768
COLTBL      EQU		61152 
VSBLOCK     EQU		64770
HSBLOCK     EQU		64780
SCRLBUF     EQU         64790
XDIM		EQU		640    ; XDIM Screen Horizontal Dim. 
XDIM22	EQU		160     ; mode xdim /2
YDIM		EQU		240    ; Screen Vertical Dimention
YDIM2		EQU		200
XCC		EQU	80   ; Horizontal Lines
YCC		EQU	30     ; Vertical Rows
XCC2		EQU	53
YCC2		EQU	25

	  	ORG 		0    ; Rom 
INT0_3      DA		RHINT0 ; hardware interrupts (ram)
		DA          RHINT1 ; (ram)
		DA		RHINT2 ; (ram)
		DA		HINT   ; (rom)
INT4        DA        	INTR4     ; interrupt vector 4 system calls
INT5 		DA		INTR5	    ; fixed point & fat routines
INT6        DA          RINT6     ; address in ram
INT7		DA		RINT7	    
INT8        DA          RINT8
INT9		DA		RINT9
INT10		DA          INTEXIT
INT11		DA          INTEXIT
INT12		DA          INTEXIT
INT13		DA          INTEXIT
INT14		DA          INTEXIT
INT15		DA		RINT15   ; trace interrupt in ram	

BOOTC:	SDP		0
		MOV		(SDFLAG),0
		MOV		(RHINT0),$8400
		MOV		(RHINT1),$8400
		MOV		(RHINT2),$8400
		MOV		(RINT15),$8400
		MOV.B		(SHIFT),0
		MOV.B		(CAPSL),0
		MOV.B		(PLOTM),1
		MOV		A1,65300
		SETSP		A1
		MOV.B		(VMODE),0
		MOV.B		(SCOL),$1F
		SETX		1589       ; Set default color 
		MOV		A1,COLTBL
		NTOI		A1,$1F1F
		MOV		A2,32767
		SETX		56*1024-2    ;  memory test
		MOV		A1,8192
MEMTST:     MOV.B		A2,(A1)
		MOV.B		(A1),$FF
		MOV.B		A0,(A1)
		CMP.B		A0,$FF
		MOV.B		(A1),A2
		JZ		MEMOK
		PUSH		A1
		MOVI		A0,5
		MOV		A1,MEMNOTOK
		MOVI		A2,4
		INT		4
		POP		A1
		JMP		MEMNOK
MEMOK:	;INC		A1
		JXAB		A1,MEMTST
MEMNOK:	SETX		80
SDRETR:	MOVI		A0,11        ; sd card init
		INT		4
		CMP		A0,256
		JZ		SDOKO
		JMPX		SDRETR
		JMP		SDNOT
SDOKO:	MOVI		A0,5        ; sd card ok
		MOV		A1,SDOK
		MOV		A2,$0103
		INT		4            ; print ok
		MOVI		A0,3
		INT		5            ; mount volume, get params
		CMP		(SDFLAG),256
		JNZ		SDNOT
		MOV		A4,BOOTBIN
		JSR		FINDFN        ; Find BOOT.BIN
		;CMPI		A0,0
		JAZ		A0,SDNOT
		PUSH		A0
		MOV		A0,A1
		JSR		PRNHEX
		MOVI		A0,5           
		MOV		A1,SDBOK
		MOV		A2,$0104
		INT		4	         ; print 
		POP		A0
		MOV		A3,START
		MOV		A4,A0
		JSR		FLOAD   ; Load boot file
		STI	
		JMP		START  ; address at RAM
SDNOT:
		MOVI		A0,5
		MOV		A1,SDNOTOK
		MOVI		A2,5
		INT		4
		JMP		MEMNOK


;   End of boot code
;--------------------------------------------------

;  INT4 FUNCTION TABLE  function in a0
INT4T0	DA		SERIN    ; Serial port in A1  A0(0)=1 
INT4T1	DA		SEROUT   ; Serial port out A1  
INT4T2	DA		PLOT     ; at X=A1,Y=A2 A4=1 set A4=0 clear
INT4T3	DA		CLRSCR   ; CLEAR SCREEN
INT4T4	DA		PUTC     ; Print char A1 at x A2.H  y A2.L
INT4T5	DA		PSTR     ; Print zero & cr terminated string
INT4T6	DA		SCROLL   ; Scrolls screen 1 char (8 points) up
INT4T7	DA		SKEYBIN  ; Serial Keyboard port in A1 A0(2)=1
INT4T8	DA		MULT     ; Multiplcation A1*A2 res in A2A1, a0<>0 overflow 
INT4T9	DA		DIV      ; 16bit  Div A2 by A1 res in A1,A0
INT4T10	DA		KEYB     ; converts to ascii the codes from serial keyboard
INT4T11	DA		SPI_INIT ; initialize spi sd card
INT4T12	DA		SPIS     ; spi send/rec byt in A1 mode A2 1=CS low 3=CS h res a0
INT4T13	DA		READSEC  ; read in buffer at A2, n in A1
INT4T14	DA		WRITESEC ; WRITE BUFFER at A2 TO A1 BLOCK
INT4T15	DA		VSCROLL  ; 

;  INT5 FUNCTION TABLE  function in a0
INT5T0	DA		INTEXIT   ; Ex fixed point multiply A1*A2
INT5T1	DA		INTEXIT   ; Ex fixed point divide A2.(FRAC2)/A1.(FRAC1)
INT5T2	DA		FILELD   ; Load file A4 points to filename, at A3
INT5T3	DA		VMOUNT   ; Load First Volume, return A0=fat root 1st cluster
INT5T4	DA		FILEDEL  ; Delete file A4 points to filename
INT5T5	DA		FILESAV  ; Save memory to file A4 filename, a6 address, a7 size
INT5T6	DA		UDIV     ; Unsigned 16bit  Div A2 by A1 res in A1,A0
INT5T7      DA		LDIV     ; 32bit div A1A2/A3A4 res A1A2 rem A3A4
INT5T8      DA		LMUL     ; 32bit mult A1A2*A3A4 res A1A2 
INT5T9      DA		FLMUL    ; float mult A1A2*A3A4 res A1A2 
INT5T10     DA		FLDIV    ; float div A1A2/A3A4 res A1A2
INT5T11     DA		FLADD    ; float add A1A2+A3A4 res A1A2 
INT5T12     DA		FCMP     ; float cmp  A1A2,A3A4 res A0 
INT5T13     DA		LDSCR    ; Load Screen A4 fname @A3 
INT5T14     DA          LINEXY   ; plot a line a1,a2 to a3,a4
INT5T15	DA		HSCROLL  ;
INT5T16	DA		FINDF    ;  A4 pointer to filename, A0 return cluster relative to (FSTCLST)
INT5T17	DA		CIRC     ; Circle A1,A2,A3                                   


;Hardware interrupt
HINT:		INC		(COUNTER)
INTEXIT:	RETI        ; trace interrupt
		
INTR4:	;SDP		0
		STI
		SRCLR		4
		SLL		A0,1
		ADD		A0,INT4T0
		JMP		(A0)

INTR5:	STI
		;SDP		0
		SRCLR		4
		SLL		A0,1
		ADD		A0,INT5T0
		JMP		(A0)
;---------------------------------------------------

; General Horizontal Scroll INT5 A0=15 for MODE 1
; Block at 64780 
;---------------------------------------------------

HSCROLL:	
		IN	A0,24
		CMPI	A0,1    
		JZ	HSCROLL1
		RETI

HSCROLL1:	PUSHX
		PUSH	A1
		PUSH	A2
		PUSH	A3	
		PUSH	A4
		PUSH	A5
		IN	A1,64788 ; pixels to scroll
		CMPI 	A1,0
		JZ	HS1EX
		JL    HS1NG
		IN  	A1,64780 ; l1
		MULU  A1,160
		IN	A2,64784  ;p1
		SRL   A2,1
		ADD	A1,A2
		IN	A3,64786  ; length pix/2
		ADD   A1,A3
		SUBI	A1,1
		ADD	A1,VBASE1
		PUSH	A1 
		MOV	A4,SCRLBUF
		IN	A2,64782  ; lines
		IN	A3,64788  ; pixels (*2) to scroll
		SUBI	A3,1
HSCRL1:	SETX 	A3
		MOV	A0,A1
HSCRL2:	IN.B	A5,A0
		OUT.B	A4,A5
		DEC	A0
		JXAB 	A4,HSCRL2
		INC	A4
		ADD	A1,160
		DEC   A2
		JNZ	HSCRL1
		POP	A1
		PUSH	A1 
		IN	A2,64782  ; lines
		IN	A3,64786  ; pixels
		IN	A0,64788  ; pixels*2 to scroll
		SUB	A3,A0
		SUBI	A3,1
		MOV	A4,A1
		SUB	A4,A0
HSCRL3:	SETX 	A3
		SRSET 4 
		ITOI.B A1,A4
		SRCLR 4 
		ADD	A1,160
		ADD	A4,160
		DEC   A2
		JNZ	HSCRL3
		POP	A1
		IN	A3,64786  ; pixels
		SUB	A1,A3
		IN	A3,64788  ; pixels*2 to scroll
		ADD	A1,A3
		MOV	A4,SCRLBUF
		IN	A2,64782  ; lines
		SUBI	A3,1
HSCRL5:	SETX 	A3
		MOV	A0,A1
HSCRL6:	IN.B	A5,A4
		OUT.B	A0,A5
		DEC	A0
		JXAB	A4,HSCRL6
		INC	A4
		ADD	A1,160
		DEC   A2
		JNZ	HSCRL5
		JMP	HS1EX

HS1NG:	IN	A1,64788 ; pixels to scroll
		NEG	A1
		OUT	64788,A1
		IN  	A1,64780 ; l1
		MULU  A1,160
		IN	A2,64784  ;p1
		SRL   A2,1
		ADD	A1,A2
		ADD	A1,VBASE1
		PUSH	A1  
		MOV	A4,SCRLBUF
		IN	A2,64782  ; lines
		IN	A3,64788  ; pixels*2 to scroll
		DEC	A3
HSCRL7:	SETX 	A3
		;MOV	A0,A1
		ITOI.B A4,A1
		INC	A4
		ADD	A1,160
		DEC   A2
		JNZ	HSCRL7
		POP	A1
		PUSH	A1 
		IN	A2,64782  ; lines
		IN	A3,64786  ; pixels
		IN	A0,64788  ; pixels*2 to scroll
		SUB	A3,A0
		SUBI	A3,1
HSCRL9:	SETX 	A3
		IN	A0,64788  ; pixels*2 to scroll
		MOV	A4,A1
		ADD	A4,A0
		;MOV	A0,A1
		ITOI.B A1,A4
		ADD	A1,160
		DEC   A2
		JNZ	HSCRL9
		POP	A1
		IN	A3,64786  ; pixels
		ADD	A1,A3
		IN	A3,64788  ; pixels*2 to scroll
		;DEC	A1 ****
		SUB	A1,A3
		MOV	A4,SCRLBUF
		IN	A2,64782  ; lines
		DEC	A3
HSCRL11:	SETX 	A3
		;MOV	A0,A1
		ITOI.B A1,A4
		INC	A4
		ADD	A1,160
		DEC   A2
		JNZ	HSCRL11
		
HS1EX:	POP	A5
		POP	A4
		POP	A3
		POP	A2
		POP	A1
		POPX
		RETI

;----------------------------------------------

;General Vertical Scroll INT4 A0=15 MODE 1
; Block at 64770
;----------------------------------------------
VSCROLL:	
		IN		A0,24
		CMPI		A0,1 
		JZ		VSCROLL1
		RETI

VSCROLL1:	PUSHX
		PUSH	A1
		PUSH	A2
		PUSH	A3	
		PUSH	A4
		PUSH	A5
		IN	A1,64778
		CMPI 	A1,0
		JZ	VS1EX
		JL    VS1NG
		IN  	A1,VSBLOCK
		MULU  A1,160
		ADD	A1,VBASE1
		IN	A2,64774  ;p1
		SRL   A2,1
		ADD	A1,A2
		PUSH	A1  
		IN	A2,64778  ; lines to scroll
		IN	A3,64776  ; length pix/2
		SRL	A3,1 
		DEC	A3
		MOV	A4,SCRLBUF
		IN	A5,64776 ; length pix/2
VSCRL1:	SETX	A3
		ITOI  A4,A1
		ADD   A4,A5
		ADD	A1,160
		DEC	A2
		JNZ   VSCRL1
		POP	A1
		IN    A4,64778  ; lines to scroll
		MULU	A4,160
		ADD	A4,A1
		IN	A2,64772  ; length in lines
		IN	A5,64778  ; lines to scroll
		SUB	A2,A5
VSCRL2:	SETX	A3
		ITOI A1,A4
		ADD	A1,160
		ADD	A4,160
		DEC	A2
		JNZ	VSCRL2
		MOV	A4,SCRLBUF
		MOV	A2,A5
		IN	A5,64776
VSCRL3:	SETX  A3
		ITOI  A1,A4
		ADD	A1,160
		ADD   A4,A5
		DEC	A2
		JNZ	VSCRL3
		JMP	VS1EX

VS1NG:	NEG   A1
		OUT	64778,A1
		IN  	A1,VSBLOCK ; LINE
		IN	A2,64772  ; length in lines
		ADD	A1,A2
		DEC	A1
		MULU  A1,160
		ADD	A1,VBASE1
		IN	A2,64774  ;p1
		SRL   A2,1
		ADD	A1,A2
		PUSH	A1  
		IN	A2,64778  ; lines to scroll
		IN	A3,64776  ; length pix/2
		SRL	A3,1
		SUBI	A3,1
		MOV	A4,SCRLBUF
		IN	A5,64776
VSCRL4:	SETX	A3
		ITOI  A4,A1
		ADD   A4,A5
		SUB	A1,160
		DEC	A2
		JNZ   VSCRL4
		POP	A1
		IN    A4,64778  ; lines to scroll
		MULU	A4,160
		SUB	A4,A1
		NEG	A4
		IN	A2,64772  ; length in lines
		IN	A5,64778  ; lines to scroll
		SUB	A2,A5
VSCRL5:	SETX	A3
		ITOI A1,A4
		SUB	A1,160
		SUB	A4,160
		DEC	A2
		JNZ	VSCRL5
		MOV	A4,SCRLBUF
		MOV	A2,A5
		IN	A5,64776
VSCRL6:	SETX  A3
		ITOI  A1,A4
		SUB	A1,160
		ADD   A4,A5
		DEC	A2
		JNZ	VSCRL6
		
VS1EX:	POP	A5
		POP	A4
		POP	A3
		POP	A2
		POP	A1
		POPX
		RETI
;----------------------------------------

FCMP:
  PUSH A1
  PUSH A2
  PUSH A3
  PUSH A4
  PUSH A5
  PUSH A7
  BTST A1,15
  JZ CFLT_1
  BTST A3,15
  JZ CFLT_2
CFLP_4:  
  XCHG A1,A3  ;// both negative
  XCHG A2,A4
  JMP CFLT_3
CFLT_1:
  BTST A3,15
  JZ CFLT_3
  MOVI A0,1  ;// 1st  pos  2nd neg
  JMP CFLT_E
CFLT_2:
  BTST A3,15
  JNZ CFLP_4
  MOV A0,-1  ;// 1st neg  2nd pos
  JMP CFLT_E
CFLT_3:      ; // both pos
  BCLR A1,15
  BCLR A3,15
  MOV A5,A3
  SRL A5,7    ;// A5 has exponent 2
  AND A3,$007F  ;// A3 has hi part of fraction A4 the rest
  MOV A7,A1
  SRL A7,7
  AND A1,$007F
  ;SUB A5,127
  ;SUB A7,127  ;// A7 has exponent 1
  CMP A7,A5    ; // A1 has hi part of fraction A2 the rest
  JL CFLT_5
  JZ CFLT_6
CFLT_7:
  MOVI A0,1
  JMP CFLT_E
CFLT_5:
  MOV A0,-1  
  JMP CFLT_E
CFLT_6:      ;// equal exp compare mantisa
  SUB A2,A4
  ADC A3,0
  SUB A1,A3
  JL CFLT_5
  JNZ CFLT_7
  MOVI A0,0
CFLT_E:
  POP A7
  POP A5
  POP A4
  POP A3
  POP A2
  POP A1
  RETI


FLMUL:
  PUSH A5
  PUSH A6
  PUSH A7
  PUSHX
  MOV A6,A3
  XOR A6,A1
  AND A6,$8000
  MOV A5,A3
  AND A3,$007F  ;// A3 has hi part of fraction A4 the rest
  BCLR A5,15
  SRL A5,7   ;// A5 has exponent 2
  MOV A0,A3
  OR A0,A5
  OR A0,A4
  JRNZ 8     ;// if num2 = 0 exit result = num1
  MOVI A1,0
  MOVI A2,0
  JMP FMUL_E
  BSET A3,7
  SUB A5,127
  MOV A7,A1
  AND A1,$007F   ;// A1 has hi part of fraction A2 the rest
  BCLR A7,15
  SRL A7,7      ;// A7 has exponent 1
  MOV A0,A1
  OR A0,A7
  OR A0,A2
  JZ FMUL_E
  BSET A1,7
  SUB A7,127
FMUL_1:
  ADD A7,A5
  SETX 7
FMUL_2:
  SRLL A1,A2
  SRLL A3,A4
  JMPX FMUL_2
  MOVI A0,8
  INT 5
  SETX 7
FMUL_3:
  SRLL A1,A2
  JMPX FMUL_3
FMUL_4:
  BTST A1,7
  JNZ FMUL_5
  SLLL A1,A2
  DEC A7
  JMP FMUL_4
FMUL_5:
  INC A7
  ADD A7,127
  AND A1,$007F  ;// build float 
  SLL A7,7
  OR A1,A7
  OR A1,A6     ;// Set sign
FMUL_E:
  POPX
  POP A7
  POP A6
  POP A5
  RETI

FLDIV: 
  PUSH A5
  PUSH A6
  PUSH A7
  PUSHX
  MOV A6,A3
  XOR A6,A1
  AND A6,$8000
  MOV A5,A3
  AND A3,$007F  ;// A3 has hi part of fraction A4 the rest
  BCLR A5,15
  SRL A5,7     ;// A5 has exponent 2
  MOV A0,A3
  OR A0,A5
  OR A0,A4
  JRNZ 10       ;// if num2 = 0 exit
  MOV A1,$7F00
  MOVI A2,0
  JMP FDIV_E
  BSET A3,7
  MOV A7,A1
  AND A1,$007F    ;// A1 has hi part of fraction A2 the rest
  BCLR A7,15
  SRL A7,7       ;// A7 has exponent 1
  MOV A0,A1
  OR A0,A7
  OR A0,A2
  JZ FDIV_E
  BSET A1,7
FDIV_1:
  SUB A7,A5
  ADD A7,127
  SETX 6
FDIV_2:
  SLLL A1,A2
  SRLL A3,A4
  ;ADDI A7,1
  JXAB A7,FDIV_2
  INC	A7
  SRLL A3,A4
  MOVI A0,7
  INT 5
FDIV_4:
  BTST A1,7
  JNZ FDIV_5
  SLLL A1,A2
  DEC A7
  JMP FDIV_4
FDIV_5:
  ADDI A7,1     
  AND A1,$007F  ;// build float 
  SLL A7,7
  OR A1,A7
  OR A1,A6   ; // Set sign
FDIV_E:
  POPX
  POP A7
  POP A6
  POP A5
  RETI

FLADD: 
  PUSH A5
  PUSH A6
  PUSH A7
  PUSHX
  MOV A6,A3
  MOV A5,A3
  AND A3,$007F  ;// A3 has hi part of fraction A4 the rest
  BCLR A5,15
  SRL A5,7    ;// A5 has exponent 2
  MOV A0,A3
  OR A0,A5
  OR A0,A4
  JZ FADD_E      ;// if num2 = 0 exit result = num1
  BSET A3,7
  MOV A0,A1
  MOV A7,A1
  AND A1,$007F  ; // A1 has hi part of fraction A2 the rest
  BCLR A7,15
  SRL A7,7    ;// A7 has exponent 1
  PUSH A0
  MOV A0,A1
  OR A0,A7
  OR A0,A2
  POP A0
  JNZ FADD_9
  MOV A1,A6
  MOV A2,A4
  JMP FADD_E
FADD_9:
  BSET A1,7
  CMP A7,A5   ;//  make A1A2 the bigger number
  JA FADD_3
  JZ FADD_4
  XCHG A1,A3
  XCHG A2,A4
  XCHG A7,A5
  XCHG A0,A6
FADD_3:      ;// make exps equal
  CMP A7,A5
  JZ FADD_4
  SRLL A3,A4
  INC A5
  JMP FADD_3
FADD_4:
  BTST A0,15
  JZ FADD_1
  BTST A6,15
  JZ FADD_2
  MOV A0,$8000   ;//both negative add
FADD_6:
  ADD A2,A4     ;// both positive add
  ADC A1,A3
  JMP FADD_5
FADD_1:
  BTST A6,15
  MOVI A0,0
  JZ FADD_6
FADD_7:
  MOV A0,$8000  ;// 1st positive 2nd negative subtract
  SUB A2,A4     ; // or the oposite
  ADC A3,0
  SUB A1,A3
  JC FADD_8
  MOVI A0,0
  JMP FADD_10
FADD_8:
  NOT A1
  NEG A2
  ADC A1,0
  JMP FADD_10
FADD_2:
  XCHG A1,A3
  XCHG A2,A4
  JMP FADD_7
FADD_5:
  BTST A1,8   ;//normalize 
  JRZ 4
  SRLL A1,A2
  INC A7
  JMP FADD_11
FADD_10:
  MOV A5,A1
  OR A5,A2
  JRNZ 2
  MOVI A7,0
  JZ FADD_E   ; // is subtraction result zero then exit
FADD_12:
  BTST A1,7     ;// matanormalize
  JNZ FADD_11
  SLLL A1,A2
  DEC A7
  JMP FADD_12
FADD_11:
  AND A1,$007F  ; // build float 
  SLL A7,7
  OR A1,A7
  OR A1,A0
FADD_E:
  POPX
  POP A7
  POP A6
  POP A5
  RETI

;------- save fat cluster A1 to fat copy cluster from sdcbuf2  
SFATC:
	PUSH A0
	PUSH A1
	JSR	DELAY
	ADD	A1,(SECPFAT)   ; add second fat offset
	MOVI	A0,14
	INT	4      ; Save FAT copy
	JSR	DELAY
	POP A1
	POP A0
	RET

;---------INT5 A0=5 Save -----------------------------
; A4 filename, a6 address, a7 size
;-------------------------------------------

FREEFAT:     ;find next free cluster in a0 and mark it with FFF8
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	MOVI	A4,0
	MOVI	A3,0
FRFT1:
	MOVI	A0,13
	MOV	A1,(FSTFAT)
	ADD	A1,A4
	MOV	A2,SDCBUF2
	INT	4              ; Load FAT
FRFT3:	
	CMP	(A2),0
	JZ	FRFT2
	ADDI	A2,2
	INC	A3
	CMPI.B A3,0
	JNZ	FRFT3
	INC	A4
	CMP	A4,238
	JA	FRFT4
	JMP	FRFT1
FRFT4: 
	MOVI	A3,0
	JMP	FRFT5	
FRFT2: 
	MOV	(A2),$FFF8
	MOVI	A0,14
	MOV	A1,(FSTFAT)
	ADD	A1,A4
	MOV	A2,SDCBUF2
	INT	4    ; Save FAT
	JSR   SFATC ; Save fat copy
FRFT5: 
	MOV	A0,A3
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	RET

;---------------------------

SVDATA: 
	MOV	A3,A0
SVD1:	JSR	DELAY
	MOV	A4,A3
	SRL	A4,8    ; divide 256
	MOV	A1,(FSTCLST)
	ADD	A1,A3   ; to cluster
	SUBI	A1,2
	MOVI	A0,14
	MOV	A2,A6   ; from pointer
	INT	4
	CMP	A7,512  ; size
	JBE	SVD2
	ADD	A6,512
	SUB	A7,512
	JSR	FREEFAT
	CMPI	A0,0     ; Is it full
	JZ	SVDE

	SWAP	A0
	CMP.B A0,A4    ; same fat offset
	SWAP	A0
	JZ	NORELD

	JSR	DELAY
	PUSH	A0
	MOV	A1,(FSTFAT)
	ADD	A1,A4
	MOVI	A0,13
	MOV	A2,SDCBUF2
	INT	4
	POP	A0
NORELD:
	JSR	DELAY
	AND	A3,$00FF
	SLL	A3,1
	ADD	A3,SDCBUF2   ;store next cluster
	SWAP	A0
	MOV	(A3),A0
	SWAP	A0
	PUSH	A0

	MOV	A2,SDCBUF2
	MOV	A1,(FSTFAT)
	ADD	A1,A4
	MOVI	A0,14
	INT	4
      JSR	DELAY
	JSR	SFATC    ; save to fat copy
	POP	A3
	JMP	SVD1
SVD2:	
	MOV	A1,(FSTFAT)
	ADD	A1,A4
	MOVI	A0,13
	MOV	A2,SDCBUF2
	INT	4

	AND	A3,$00FF
	SLL	A3,1
	ADD	A3,SDCBUF2   ;store last cluster
	MOV	(A3),$FFFF
	MOV	A2,SDCBUF2
	MOV	A1,(FSTFAT)
	JSR	DELAY
	ADD	A1,A4
	MOVI	A0,14
	INT	4         ;write $FFFF 
	JSR	SFATC    ; save to fat copy 
	MOV	A0,256    ; and exit ok
SVDE:
	RET
;----------------------------

FILESAV:
	PUSHX
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	PUSH	A5	
	PUSH	A6
	PUSH	A7
	SDP   0
	JSR	FINDFN
	CMPI	A0,0
	JZ	FSV7
	MOVI	A0,0
	JMP	FSVE
FSV7:	MOVI	A5,0

FSV4:	MOV	A1,(CURDIR)
	ADD	A1,A5
	MOVI	A0,13
	MOV	A2,SDCBUF1
	INT	4              ; Load Root Folder 1st sector
	MOVI	A0,0
	MOVI	A3,0
	JSR	DELAY
FSV1:	
	CMP.B (A2),0
	JZ	FSV2
	CMP.B	(A2),$E5
	JNZ	FSV3
FSV2:	                 ; Found free slot
	SETX	10
;FSV5:	MOV	(A2),(A4)
;	INC	A2
;	JXAB	A4,FSV5
	MTOM.B A2,A4
	ADDI  A2,11
	MOV.B	(A2),32    ;set archive bit
	ADDI  A2,3
	MOV   (A2),0   ; create time
	ADDI	A2,2
	MOV   (A2),$8750 ; create date
	ADDI  A2,6
	MOV   (A2),0   ; mod. time
	ADDI	A2,2
	MOV   (A2),$8750 ; mod. date
	ADDI	A2,4
	SWAP	A7	     ;store FILE SIZE
	MOV	(A2),A7
	SWAP	A7     
	ADDI	A2,2
	MOV	(A2),0  
	SUBI	A2,4
	JSR	FREEFAT     ; free
	CMPI	A0,0
	JZ	FSVE
	PUSH	A0
	SWAP	A0	
	MOV	(A2),A0
	MOVI	A0,14
	MOV	A1,(CURDIR)
	ADD	A1,A5
	MOV	A2,SDCBUF1
	INT	4         ; save header
	JSR	DELAY
	POP	A0        ; CLUSTER NUM
	JSR	SVDATA
	JMP	FSVE
FSV3:	
	ADD	A2,32
	ADD	A3,32
	CMP	A3,512
	JNZ	FSV1  ; search same sector
	INC	A5

	MOV	A1,(CURDIR)
	CMP	(FATROOT),A1 ;  *** to be implemented ***
	JNZ   FSVE

	CMP	A5,32  ;if not last root dir sector 
	JNZ	FSV4   ;load next sector and continue search
FSVE:	
	POP	A7
	POP	A6
	POP	A5
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	POPX
	RETI

;--------INT5 A0=4 DELETE FILE -----------------------

FILEDEL:
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	PUSH	A5	
	SDP   0
	JSR	FINDFN
	CMPI	A0,0
	JZ	FDELX
	MOV.B	(A2),$E5  ; Delete file entry
	MOV	A4,A0
	MOVI	A0,14
	MOV	A1,(CURDIR)
	ADD	A1,A5
	MOV	A2,SDCBUF1
	INT	4          ; save file header
	JSR	DELAY
FDL1:	
	MOV	A5,A4
	SRL	A5,8   ; DIVIDE BY 256
	MOV	A1,(FSTFAT)
	ADD	A1,A5
	MOVI	A0,13
	MOV	A2,SDCBUF2
	INT	4         ; Load FAT cluster
	AND	A4,$00FF  ; mod 256	
	SLL	A4,1  
	MOV	A5,SDCBUF2
	ADD	A5,A4
	MOV	A4,(A5)
	MOV	(A5),0  ; free cluster
	MOVI	A0,14
	INT	4        ; write fat back
	JSR	DELAY
	JSR	SFATC  ; write fat copy
	SWAP	A4
	CMP	A4,$FFF0 ; EOF
	JAE	FDELX
	CMPI	A4,0
	JNZ	FDL1
FDELX:
	POP	A5
	POP	A4
	POP	A3
	POP	A2
	POP	A1

	RETI


;-------- MOUNT VOUME ---------------------------

VMOUNT:
	PUSH	A1
	PUSH	A2
	SDP   0
	MOVI	A0,13
	MOVI	A1,0
	MOV	A2,SDCBUF1
	INT	4             ; read MBR
	JSR	DELAY
      CMP	A0,256
	JNZ	VMEX
	MOV	A2,SDCBUF1      
	ADD	A2,$1C6
	MOV	A0,(A2)        ; Get 1st partition boot sector 
	SWAP	A0		   ; little endian
	MOV	(FATBOOT),A0  
	MOV	A1,A0           ; A1 fatboot
	MOVI	A0,13
	MOV	A2,SDCBUF1
	INT	4              ; Load FAT boot sector
      CMP	A0,256
	JNZ	VMEX
	MOV	(SDFLAG),256
	ADDI	A2,14
	MOV	A0,(A2)   ; Reserved sectors
	SWAP	A0
	ADD	A1,A0
	MOV	(FSTFAT),A1  ; save first fat cluster num
	ADDI	A2,5
	MOV.B	A0,(A2)      ; Total num of sectors<65536
	ADDI	A2,1
	MOVHH A0,(A2)
	MOV	(SECNUM),A0
	ADDI	A2,2
	MOV	A0,(A2)   ; sectors per fat
	SWAP	A0
	MOV	(SECPFAT), A0
	SLL	A0,1        ; 2 fats
	ADD	A1,A0	    ; Root Folder
	MOV	(CURDIR),A1
	MOV	(FATROOT),A1
	ADD	A1,32     ; 32 bytes * 512 entries =32 sectors
	MOV	(FSTCLST),A1
	MOV	A0,(CURDIR)
VMEX:	POP	A2
	POP	A1
	RETI

;-------------------------------------------------
; INT 5,A0=13 Load screen
LDSCR:	SDP   0
		JSR	FINDFN    
		MOV	A4,A0
		CMPI	A0,0
		JZ	INTEXIT
		JSR	SCLOAD
		RETI

;-------------------------------------------------
SCLOAD:	; A4 cluster, A3 Dest address
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	PUSH	A5
	PUSH	A6
	SDP   0
SLD1:	MOV	A6,A4
	SRL	A6,8   ; DIVIDE BY 256
	MOV	A1,(FSTFAT)
	ADD	A1,A6
	MOVI	A0,13
	MOV	A2,SDCBUF2
	INT	4              ; Load FAT
	MOVI	A0,13          ;
	MOV	A1,(FSTCLST)
	ADD	A1,A4
	SUBI	A1,2
	MOV	A2,SDCBUF1     ; Dest
	INT 	4              ; Load sector
	SETX  255
	MOV	A2,SDCBUF1
	MTOI	A3,A2
	CMP	A3,64768
	JA	SLDE
	ADD	A3,512
	AND	A4,$00FF  ; mod 256
	SLL	A4,1  
	MOV	A5,SDCBUF2
	ADD	A5,A4
	MOV	A4,(A5)
	SWAP	A4
	CMPI	A4,0
	JZ	SLDE
	CMP	A4,$FFF0
	JBE	SLD1
SLDE:	POP	A6
	POP	A5
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	RET 



;---------------------------------------------------
; INT 5,A0=3 Load file
FILELD:	PUSH	A5
		JSR	FINDFN    
		MOV	A4,A0
		CMPI	A0,0
		JZ	FLEXIT
		JSR	FLOAD
FLEXIT:	POP	A5
		RETI
;-------------------------------------------------

DELAY: PUSHX
	SETX	64000
LDDL: JMPX	LDDL    ;delay
	POPX
	RET

FLOAD:	; A4 #cluster, A3 Dest address
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	PUSH	A5
	PUSH	A6
	SDP   0
FLD1:	MOV	A6,A4
	SRL	A6,8   ; DIVIDE BY 256
	MOV	A1,(FSTFAT)
	ADD	A1,A6
	MOVI	A0,13
	MOV	A2,SDCBUF2
	INT	4              ; Load specific cluster FAT
	MOVI	A0,13          ;
	MOV	A1,(FSTCLST)
	ADD	A1,A4
	SUBI	A1,2   ; because cluster start with cluster #2 
	MOV	A2,A3          ; Dest
	INT 	4              ; Load sector 
	ADD	A3,512
	AND	A4,$00FF  ; mod 256
	SLL	A4,1  
	MOV	A5,SDCBUF2
	ADD	A5,A4
	MOV	A4,(A5)
	SWAP	A4
	CMPI	A4,0
	JZ	FLXT
	CMP	A4,$FFF0
	JBE	FLD1
FLXT: POP	A6
	POP	A5
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	RET 

FINDF:
	PUSH	A1
	PUSH	A2
	PUSH	A5
	JSR	FINDFN
	POP	A5
	POP	A2
	POP	A1
	RETI

;Find filename in root directory
; A4 pointer to filename, A0 return cluster(FSTCLST=2nd cluster),  A1 SIZE
; file name in header at A2, directory #cluster at A5 relative to CURDIR 
; changes A1,A2,A5! 
FINDFN:     PUSHX
		PUSH	A3
		PUSH	A4
		MOVI	A5,0
TFF4:		MOV	A1,(CURDIR)
		ADD	A1,A5
		MOVI	A0,13
		MOV	A2,SDCBUF1
		INT	4              ; Load Root Folder 1st (next) sector
		MOVI	A0,0
		MOVI	A3,0
TFF1:		CMP.B (A2),0
		JZ	TFF6
		SETX	10
		PUSH	A2
		PUSH	A4
TFF2:		CMP.B	(A2),(A4)
		JNZ	TFF3
		INC	A2
		JXAB	A4,TFF2
		POP	A4
		POP	A2
		ADD	A2,26
		MOV	A0,(A2)
		SWAP	A0
		ADDI	A2,2
		MOV	A1,(A2)
		SWAP	A1	;FILE SIZE       
		SUB	A2,28
		JMP	TFF5
TFF3:		POP	A4
		POP	A2
		ADD	A2,32
		ADD	A3,32
		CMP	A3,512
		JNZ	TFF1  ; search same sector
		INC	A5

		MOV	A1,(CURDIR) ; if not root search only first 
		CMP	(FATROOT),A1 ;  *** to be implemented ***
		JNZ   TFF6

		CMP	A5,32  ;if not last root dir sector 
		JNZ	TFF4   ;load next sector and continue search
TFF6:		MOVI	A0,0
TFF5:		POP	A4
		POP	A3
		POPX
		RET


PRNHEX:	; print num in A0 in hex for debugging 
		PUSHX
		PUSH	A0
		PUSH	A1
		PUSH	A2
		PUSH	A3
		MOV	A3,A0
		MOV	A2,$2804
		SETX	3
PHX1:		MOV	A1,A3
		AND	A1,$000F
		ADD	A1,48
		CMP	A1,57
		JBE	PHX2
		ADDI	A1,7
PHX2:		MOVI	A0,4
		SUB	A2,$0100
		INT	4
		SRL	A3,4
		JMPX	PHX1
		POP	A3
		POP	A2
		POP	A1
		POP	A0
		POPX
		RET 

;--------------------------------------
WRITESEC:
	PUSHX
	SETX	5
WRSCR:
	MOVI	A0,14
	JSR	WSEC
	JSR 	DELAY
	CMP	A0,256
	JRZ	4
	JMPX	WRSCR
	POPX	
	RETI

WSEC:
	PUSHX
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	SDP   0
	PUSH  A2   ; save buffer address
	OUT	19,0
	MOVI	A3,0
	MOV	A4,A1
	MOV.B	A2,(SDHC)
	CMPI.B A2,1
	JZ	WSHC ; is sdhc skip multiply
	SETX 8
WSLP:	SLLL	A3,A4 ; multiply 512 to convert block to byte
	JMPX	WSLP
WSHC:
	MOVI	A2,1
	MOV 	A1,$FF  ; send clocks 
	JSR	SPIS

	MOV 	A1,$58  ; write block
	JSR	SPIS
	MOVLH	A1,A3
	JSR	SPIS
	MOV.B	A1,A3
	JSR	SPIS
	MOVLH	A1,A4
	JSR	SPIS
	MOV.B	A1,A4
	JSR	SPIS
	MOVI 	A1,$01 
	JSR	SPIS 

	SETX 10
WRS0:
	MOV	A1,$FF  
	JSR	SPIS
	CMPI.B A0,0
	JRZ	4
	JMPX	WRS0
	CMPI.B A0,0
	JNZ	WSHC

	MOV	A1,$FF  
	JSR	SPIS

	MOV	A1,$FE    ; SEND START OF DATA
	JSR	SPIS	

	POP 	A3         ;	MOV	A3,SDCBUF1    ; buffer
	SETX	511        ; WRITE DATA 512 BYTES + 2 CRC bytes
WRI6:	MOV.B	A1,(A3)
	JSR	SPIS
	JXAB	A3,WRI6
	JSR	SPIS  ; CRC
	MOVI	A1,1
	JSR	SPIS  ; CRC

	SETX	9999          ; READ ANSWER until $05 is found
WRS8:	MOV	A1,$FF
	JSR	SPIS
	AND	A0,$001F
	CMPI.B A0,$5
	JRZ	4
	JMPX	WRS8

	CMPI.B A0,$5
	MOVI	A0,7
	JNZ	WRIF

	SETX	19999          ; READ ANSWER until no $00 is found
WRS9: MOV	A1,$FF
	JSR	SPIS
	CMPI.B A0,0
	JRNZ	4
	JMPX	WRS9
	
	CMPI.B A0,0
	JZ	WRIF

	MOV	A0,$0100  ; ALL OK

WRIF:	MOV 	A1,$FF  ; send clocks 
	JSR	SPIS
	OUT	19,2
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	POPX
	RET

;-----------------------------------------

READSEC:
	PUSHX
	SETX	4
	SDP   0
RDSCR:
	MOVI	A0,13
	JSR	READSC
	JSR	DELAY
	CMP	A0,256
	JRZ	4
	JMPX	RDSCR
	POPX
	RETI
READSC:
	PUSHX
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4

	PUSH	A2
	MOVI	A3,0
	MOV	A4,A1
	MOV.B	A2,(SDHC)
	CMPI.B  A2,1 ; is sdhc skip multiply
	JZ	RSHC
	SETX 8
RSLP:	SLLL	A3,A4 ; multiply 512 to convert block to byte
	JMPX	RSLP
RSHC:
	OUT	19,0
	MOVI	A2,1
	MOV 	A1,$FF  ; send 8 clocks 
	JSR	SPIS

	MOV 	A1,$51  ; READ block
	JSR	SPIS
	MOVLH	A1,A3
	JSR	SPIS
	MOV.B	A1,A3
	JSR	SPIS
	MOVLH	A1,A4
	JSR	SPIS
	MOV.B	A1,A4
	JSR	SPIS
	MOVI 	A1,$01 
	JSR	SPIS 

	SETX	9999          ; READ ANSWER until $FE is found
RDS5:	MOV	A1,$FF
	JSR	SPIS
	CMP.B	A0,$FE
	JZ	SDRD2
	JMPX	RDS5

SDRD2:
	POP	A3   		; read to buffer
	MOV.B (SDERROR),1
	CMP.B	A0,$FE  
	MOVI	A0,7
	JNZ	RDIF       ; data ready ?
	SETX	513        ; READ DATA 512 BYTES + 2 CRC bytes
RDI6:	MOV	A1,$FF
	JSR	SPIS
	MOV.B	(A3),A0
	JXAB	A3,RDI6

	MOV 	A1,$FF  ; send clocks 
	JSR	SPIS

	MOV.B (SDERROR),0
	MOV	A0,$0100  ; ALL OK
	OUT	19,2

RDIF: OUT	19,2
	POP	A4
	POP	A3
	POP	A2
	POP	A1
	POPX
	RET


;----------------------------------------------
SPIS:
	OUT	18,A1
	PUSH	A2
	BSET  A2,0
	OUT	19,A2
	BCLR	A2,0
	OUT	19,A2
SPIC: IN	A0,17
	BTST  A0,0
	JNZ	SPIC
	IN	A0,16
	POP	A2
	RET

;--------------- * SD CARD INIT * ----------------
SPI_INIT:
	PUSHX
	PUSH 	A1
	PUSH	A2
	PUSH	A3
	SDP   0
	MOV   (SDHC),0
	MOVI	A3,0

SPIN:	MOV	A0,40
	CMP	A3,20
	JA	SPIF  ; 40 RETRIES FAIL
	OUT	19,2
	SETX	7
	MOVI	A2,3
SPI0: MOV	A1,255	
	JSR	SPIS
	JMPX	SPI0    ; SEND 80 CLK PULSES WITH CS HIGH
	
	OUT   19,0
	JSR 	DELAY
	MOVI	A2,1
	;MOV	A1,$FF	
	;JSR	SPIS
	
	MOV 	A1,$40  ; RESET IN SPI MODE   
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	MOV 	A1,$95
	JSR	SPIS	

	SETX	7	         ;READ RESPONCES 8 
SPI3:	MOV	A1,$FF
	JSR	SPIS
	CMPI.B A0,1
	JZ	SPNF
	JSR	DELAY
	JMPX	SPI3
	
	INC 	A3	
	JMP	SPIN
SPNF:
	;MOV	A1,$FF
	;JSR	SPIS
; ----- CMD 8 --------------

	OUT	19,2
	JSR	DELAY
	OUT	19,0	

	MOV 	A1,$48  ; spi cmd 8
	JSR	SPIS
	MOV 	A1,$00
	JSR	SPIS
	JSR	SPIS
	MOVI 	A1,$01
	JSR	SPIS
	MOV 	A1,$AA
	JSR	SPIS
	MOV 	A1,$87 ; $86
	JSR	SPIS 

	SETX  7         ; READ 8 ANSWERS
SP8:  MOV	 A1,$FF
	JSR	 SPIS
	CMPI.B A0,1
	JBE	 SP8X
	JMPX  SP8
	JMP	SP8END

SP8X:	SETX	3         ; read 4 more
SP82: MOV	 A1,$FF
	JSR	 SPIS
	JMPX	 SP82
SP8END:
;------------- CMD 55 + ACMD 41 ------------
	MOV	A1,$FF
	JSR	SPIS
	MOV	A3,0
SPN55:
	OUT	19,2
	JSR	DELAY
	OUT	19,0
	;MOV	A1,$FF
	;JSR	SPIS

	CMP	A3,50
	MOV	A0,41
	JA	TRYCMD1
	INC	A3

	MOV 	A1,$77  ; spi cmd 55
	JSR	SPIS
	MOVI 	A1,$00
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	MOV 	A1,$01 
	JSR	SPIS 

	SETX   7         ; READ 8 ANSWERS
SP55: MOV	 A1,$FF
	JSR	 SPIS
	CMPI.B A0,1
	JBE	 SP55X
      JMPX   SP55
	JMP    SPN55	
SP55X:

	MOV 	A1,$69  ; INITIALIZE spi cmd 41
	JSR	SPIS
	MOV	A1,$40  ; $00 or $40 for SDHC support
	JSR	SPIS
	MOVI 	A1,$00
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	MOV 	A1,$01
	JSR	SPIS 

	 SETX	7         ; READ 8 ANSWERS
SP413: MOV	A1,$FF
	 JSR	SPIS
	 CMPI.B A0,0
	 JZ	SKIPCMD1
       JMPX SP413

	SETX	19
BIGD: JSR	DELAY
	JMPX	BIGD

	JMP	SPN55

;---------------------------
; Command 1 init

TRYCMD1:
	;MOV	A1,$FF
	;JSR	SPIS
	MOV	A3,0
SPNT:	MOVI	A0,1
	OUT	19,2
	JSR	DELAY
	OUT	19,0
	CMP	A3,50
	MOVI	A0,11
	JA	SPIF
	MOV 	A1,$41  ; INITIALIZE spi
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	MOV 	A1,01 
	JSR	SPIS 

	SETX	7         ; READ 8 ANSWERS
SPI2:	MOV	A1,$FF
	JSR	SPIS
	CMPI.B A0,0
	JZ	SPNX
	JMPX	SPI2
	INC	A3
	JMP	SPNT
SPNX:
;-------------------------------------------------------
;---- CMD 58 ---------------------
SKIPCMD1:
	OUT	19,2
	JSR	DELAY
	OUT	19,0
	MOV	A1,$FF
	JSR	SPIS

	JSR DELAY
	MOV 	A1,$7A  ; GET 
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	MOV 	A1,$01
	JSR	SPIS 

	SETX	7          ; READ ANSWER
SPI7:	MOV	A1,$FF
	JSR	SPIS
	CMPI.B A0,0
	JZ	SP58NX
	JMPX	SPI7
	JMP	SP58SK
SP58NX:
	MOV	A1,$FF
	JSR	SPIS
	PUSH	A0
	JSR	SPIS
	JSR	SPIS
	JSR	SPIS
	POP	A0
	BTST	A0,6    ; Is it SDHC
	JZ	SP58SK
	MOV.B	(SDHC),1
	JMP	SPSNX
SP58SK:
;--------------------------------------------------------
	;MOV	A1,$FF
	;JSR	SPIS

	OUT	19,2
	JSR	DELAY
	OUT	19,0
	MOV 	A1,$50  ; SET TRANSFER SIZE
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	JSR	SPIS
	MOVI 	A1,$02
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOV 	A1,$01
	JSR	SPIS 

	SETX	7          ; READ ANSWER
SPI4:	MOV	A1,$FF
	JSR	SPIS
	CMPI.B A0,0
	JZ	SPSNX
	JMPX	SPI4
	MOVI	A0,8
	JMP	SPIF

SPSNX:
	OUT	19,2
      ; read master boot 
	MOVI	A1,0
	MOV	A2,SDCBUF1
	JSR	READSC
	
	

SPIF: OUT	19,2
	POP	A3
	POP	A2
	POP	A1
	POPX
	RETI

;---------------------------------------- 
SERIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,1  ;Result in A1, A0(1)=0 if not avail
		JZ		INTEXIT
		IN		A1,4 
		OUT		2,2
		OUT		2,0
		RETI
;----------------------------------------
SEROUT:	IN		A0,6  ;Wite serial byte if ready
		BTST		A0,0  ; A0(0)=0 if not ready
		JZ		SEROUT
		OUT		0,A1
		OUT		2,1
		OUT		2,0
		RETI

;----------------------------------------
 ; VMODE0 PRINT Character in A1 at A2 (XY)
PUTC:		
		PUSHX   
		PUSH		A4
		PUSH		A1
		SDP   0
		IN		A0,24
		CMPI		A0,1 ;(VMODE),1
		JZ		PUTC1             
		AND		A1,$00FF  
		SUB.B		A1,32    
		MULU		A1,8
		ADD		A1,CTABLE2
		MOV		A4,A1       ; character table address
		MOVI		A0,0
		MOV.B		A0,A2
		MULU		A0,XDIM
		MOVI		A1,0
          	MOVLH 	A1,A2
		MULU.B	A1,8
		ADD		A0,A1
		ADD		A0,VBASE   ; video base
		SETX		3          ; 8 bytes
		MTOI		A0,A4
		POP		A1
		POP		A4
		POPX	
		RETI

PUTC1:       ; VMODE1 PRINT Character in A1 at A2 (XY)
	
		PUSH		A7
		PUSH		A6
		PUSH		A5
		PUSH 		A3
		PUSH		A2
		SDP   0
		AND		A1,$00FF
		SUB.B		A1,32    
		MULU		A1,6
		ADD		A1,CTABLE
		MOV		A4,A1       ; character table address
		MOVI		A0,0
		MOV.B		A0,A2
		MULU		A0,1280  ;XDIM/2 * 8
		MOVI		A1,0
          	MOVLH 	A1,A2
		MULU		A1,3   ; 6/2
		ADD		A0,A1
		ADD		A0,VBASE1   ; video base
		MOV.B		A1,(SCOL)
		MOV.B		A2,A1
		AND		A1,$000F
		AND		A2,$00F0
		SRL		A2,4
		SETX		2 ; 3 font words
P2C:		PUSH		A0
		MOVI		A6,0
		MOV		A7,(A4) ; get font word
		ADDI		A4,2
P1C:		MOVI		A5,0
		MOVI		A3,15
            SUB		A3,A6
		BTST		A7,A3
		JZ		P4C
		MOV.B		A5,A1
		JMP		P5C
P4C:		MOV.B		A5,A2
P5C:		SLL		A5,4
		SUBI		A3,8
		BTST		A7,A3
		JZ		P6C
		OR.B		A5,A1
		JMP		P3C
P6C:		OR.B		A5,A2
P3C:		OUT.B		A0,A5
		ADD		A0,160
		INC		A6
		CMPI		A6,7
		JBE		P1C
		POP		A0
		JXAB		A0,P2C
		POP		A2
		POP		A3
		POP		A5
		POP		A6
		POP		A7
		POP		A1
		POP		A4
		POPX
		RETI

;----------------------------------------
PSTR:		PUSH	A3
		PUSH	A4
		;SDP   0
		MOV.B	A3,XCC
		MOV.B	A4,YCC
		IN	A0,24
		;CMPI	A0,0 ;(VMODE),1
      	JAZ	A0,PSTR0
		MOV.B	A3,XCC2
		MOV.B	A4,YCC2
PSTR0:	MOVI	A0,0     ; PRINT 0 OR 13 TERM.STR POINTED BY A1 AT A2
		MOV.B	A0,(A1)
		;CMPI.B A0,0
		JAZ.B	A0,STREXIT
		CMPI.B A0,13
		JZ  	STREXIT
PSTR2:	PUSH 	A1
		MOV	A1,A0
		MOVI	A0,4
		INT	4
		POP	A1
		ADD	A2,$0100
		SWAP	A2
		CMP.B	A2,A3
		SWAP	A2
		JB	PSTR3
		INC	A2
		AND	A2,$00FF
		CMP.B	A2,A4
		JAE	STREXIT
PSTR3:	INC	A1
		JMP	PSTR0
STREXIT:	POP	A4
		POP	A3
		RETI

;----------------------------------------

SCROLL:	
		IN		A0,24
		CMPI		A0,1 ;(VMODE),1
		JZ		SCROLL1
		PUSHX
		PUSH		A1
		SETX		9279     ;4639 ;5759	
		MOV		A0,VBASE
		MOV		A1,33408   ; 49152+384
		ITOI		A0,A1
		MOV 		A0,51328
		SETX		319
		NTOI		A0,0		
		POP		A1
		POPX
		RETI

SCROLL1:	PUSHX
		PUSH		A1
		SDP   0
		SETX		15359          ;5759	
		MOV		A0,VBASE1
		MOV		A1,34048   ; 49152+384
		ITOI		A0,A1
		MOV		A0,63488
		MOV.B		A1,(SCOL)
		SLL		A1,4
		MOV.B		A1,(SCOL)
		SRL		A1,4
		MOVHL		A1,A1
		SETX		639
		NTOI		A0,A1	
		POP		A1
		POPX
		RETI
;----------------------------------------

CLRSCR:	
		IN	A0,24
		CMPI	A0,1 ;(VMODE),1
		JZ	CLRSCR1
		PUSHX
		SETX	9599      ;5952	
		MOV	A0,VBASE
		NTOI  A0,0
		POPX
		RETI

CLRSCR1:	PUSHX
		PUSH	A1
		SDP   0
		MOV.B		A1,(SCOL)
		SLL		A1,4
		MOV.B		A1,(SCOL)
		SRL		A1,4
		MOVHL		A1,A1
		SETX	15999    ;5952	
		MOV	A0,VBASE1
		NTOI	A0,A1
		POP	A1
		POPX
		RETI

;----------------------------------------
PLOT:		IN	A0,24
		SDP   0
		CMPI	A0,1  ;(VMODE),1
		JZ	PLOT1
		PUSH		A1
		PUSH		A2        ; PLOT at A1,A2 mode in (PLOTM)
		PUSH		A4
		MOVI		A4,0
		MOV.B		A4,(PLOTM)
		MOV		A0,A2
		NOT		A0
		AND		A0,7
		SRL		A2,3
		MULU		A2,XDIM
		ADD		A2,A1
		ADD		A2,VBASE 
		IN		A1,A2
		BTST		A2,0
		JNZ		PL6
		ADDI		A0,8
PL6:		OR		A4,A4
		JNZ		PL3
		BCLR		A1,A0   ; mode 0  clear
		JMP		PL4
PL3:		CMPI		A4,2
		JNZ		PL5
		BTST		A1,A0  ; mode 2  not
		JZ		PL5
		BCLR		A1,A0
		JMP		PL4
PL5:		BSET		A1,A0    ; mode 1  set
PL4:		OUT		A2,A1
		POP		A4
		POP		A2
		POP		A1
		RETI

PLOT1:	PUSH		A1
		PUSH		A2        ; PLOT at A1,A2 mode in A4
		PUSH		A3
		PUSH		A4
		MOVI		A4,0
		MOV.B		A4,(PLOTM)
		MULU		A2,XDIM22
		MOV		A0,A1		
		SRL		A1,1
		ADD		A2,A1
		ADD		A2,VBASE1
		IN.B		A1,A2
		MOV.B		A3,(SCOL)
		OR.B		A4,A4
		JNZ		P1L7
		SRL		A3,4	; mode 0  clear		   
P1L7:		AND	 	A3,$000F
		BTST		A0,0
		JNZ		P1L6
		SLL		A3,4
		AND.B		A1,$0F
		JMP		P1L3
P1L6:		AND.B		A1,$F0
P1L3:		CMPI		A4,2   ; mode 2
		JNZ		P1L5
		; what to do here ?
P1L5:		OR.B		A1,A3    ; mode 1  set
		OUT.B		A2,A1
		POP		A4
		POP		A3
		POP		A2
		POP		A1
		RETI

;-------------------------------------- 
; plot a line a1,a2 to a3,a4

LINEXY:
	STI
	PUSHX
	PUSH 	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4
	PUSH	A5
	PUSH	A6
	PUSH	A7
	MOVI  A5,1
	SUB   A3,A1 ; A3=dx
	JNZ   LXY11
	MOVI	A5,0
	JMP   LXY1
LXY11: JNC	LXY1 
	MOV	A5,-1
	NEG	A3
LXY1: MOVI	A6,1 
	SUB	A4,A2 ; A4=dy
	JNZ	LXY22	
	MOVI	A6,0	
	JMP	LXY2
LXY22: JNC	LXY2
	NEG	A4
	MOV	A6,-1
LXY2: CMP	A3,A4
	JC	LXY33
	SETX  A3 
	MOV	A7,A4
	SLA	A7,1
	SUB	A7,A3  ; E=2*dy-dx 
	JMP	LXY3
LXY33: 
	MOV	A7,A3
	SLA	A7,1
	SUB	A7,A4  ; E=2*dx-dy 
	SETX	A4
LXY3: SLL	A4,1  ;2*dy
	SLL	A3,1  ;2*dx
LXY4: MOVI	A0,2
	INT	4     ; plot a point
	MOV	A0,A3
	OR	A0,A4
	JZ    LXY0   ; if both 0 skip interation
LXY7:	CMP	A7,0
	JL	LXY0
	CMP	A3,A4  ; 2dx,2dy	
	JNC   LXY5   ;
	SUB	A7,A4  ; dy>dx
	ADD   A1,A5
	JMP	LXY6
LXY5: SUB   A7,A3  ; dx>=dy
	ADD	A2,A6
LXY6: JMP	LXY7
LXY0: CMP	A3,A4
	JNC   LXY8
	ADD	A7,A3
	ADD   A2,A6
	JMP	LXY9
LXY8: ADD   A7,A4
	ADD	A1,A5
LXY9:	JMPX  LXY4	
	POP	A7
	POP	A6
	POP	A5
	POP	A4	
	POP	A3
	POP	A2
	POP	A1
	POPX
	RETI

;------- CIRCLE ---------------------------

CIRPLT:
	MOV	A1,A5
	ADD	A1,(CIRCX)
	MOV	A2,A6
	ADD	A2,(CIRCY)	
	MOVI	A0,2
	INT	4         ; 1 octant
 	MOV	A1,A5
	NEG	A1
	ADD	A1,(CIRCX)	
	MOVI	A0,2
	INT	4         ; 2 octant
	MOV	A2,A6
	NEG	A2
	ADD	A2,(CIRCY)	
	MOVI	A0,2
	INT	4         ; 3 octant
	MOV	A1,A5
	ADD	A1,(CIRCX)	
	MOVI	A0,2
	INT	4         ; 4 octant
	RET

CIRC:	STI
	PUSH 	A1
	PUSH	A2
	PUSH	A3
	PUSH	A5
	PUSH	A6
	PUSH	A7
	MOV	(CIRCX),A1  
	MOV	(CIRCY),A2  
	MOV	A5,A3  ; A3=r A5=x
	MOVI	A6,0	 ; A6=y
	JSR	CIRPLT
	XCHG	A5,A6
	JSR	CIRPLT
	XCHG	A5,A6
	MOVI	A7,1   ; A7=P
	SUB	A7,A3  ; P=1-r
CIR1:	CMP	A5,A6
	JLE	CIRX   ; while x>y
	INC	A6
	MOV	A0,A6
	SLA	A0,1 ; A0=2*y
	INC	A0
	CMPI	A7,0
	JL	CIR2
	DEC	A5
	SUB	A7,A5
	SUB	A7,A5
CIR2:	ADD	A7,A0
	JSR	CIRPLT
	XCHG	A5,A6
	JSR	CIRPLT
	XCHG	A5,A6
	JMP	CIR1
CIRX:	POP	A7
	POP	A6
	POP	A5	
	POP	A3
	POP	A2
	POP	A1
	RETI

;--------------------------------------------------------------
; Multiplcation A1*A2 res in A2A1,

MULT:		
		PUSH		A3
		MOV		A0,A2
		XOR		A0,A1
		PUSH		A0
		BTST		A1,15    ; check if neg and convert 
		JZ		MUL2
		NEG		A1
MUL2:		BTST		A2,15   ; check if neg and convert 
		JZ		MUL3
		NEG		A2
MUL3:		MULU		A1,A2
		POP		A0
		BTST		A0, 15
		MOV		A0,A2
		JZ		MULEND     ; Check result sign
		NOT		A2
		NEG		A1
		ADC		A2,0
MULEND:	POP		A3
		RETI

;-------------------------------------------------------------
; Div A2 by A1 res in A1,A0

DIV:		
		PUSH		A3
		MOV		A3,A1
		MOV		A1,32767
		;CMPI		A3,0
		JAZ		A3,DIVE
		MOVI		A1,0
		MOV		A0,A1
		XOR		A0,A2
		JP		DIV1     ; Check result sign
		MOVI		A1,1
DIV1:		PUSH		A1 
		BTST		A2,15    ; check if neg and convert 
		JZ		DIV2
		NEG		A2
DIV2:		BTST		A3,15   ; check if neg and convert 
		JZ		DIV3
		NEG		A3
DIV3:		CMP		A3,A2
		MOV		A0,A2  ; id divider > divident res=0 rem=divident
		JBE		DIV4		
		MOVI		A1,0
		JMP		DIV14
DIV4:		MOVI		A1,0   ; main algorithm
DIV5:		BTST		A0,14  ; left align
		JNZ		DIV6
		INC		A1
		SLL		A0,1
		JMP		DIV5
DIV6:		PUSH 		A1     ; store no of shifts
		MOVI		A2,0
		MOV		A1,A3
DIV7:		BTST		A1,14  ; left align 
		JNZ		DIV12
		SLL		A1,1
		INC		A2
		JMP		DIV7
DIV12:	MOV		A3,A1  
		MOV		A1,A2
		POP		A2  ; Get no of shifts
		SUB		A1,A2
DIV10:	;CMPI		A2,0
		JAZ		A2,DIV9
		SRL		A3,1  ; align back
		SRL		A0,1
		DEC		A2
		JMP		DIV10
DIV9:		MOV         A2,A1
		MOVI		A1,0     ; quotient
DIV11:	CMP		A0,A3  ; compare remainder with divisor
		JC		DIV8		
		BSET		A1,A2
		SUB		A0,A3
DIV8:		SRL		A3,1
		DEC		A2
		JP		DIV11 
DIV14:	POP		A3
		OR		A3,A3
		JZ		DIVE
		NEG		A1
DIVE:		POP		A3
		RETI

;-------------------------------------------------------------
; unsigned Div A2 by A1 res in A1,A0

UDIV:		
		PUSH		A3
		MOV		A3,A1
		MOV		A1,65535
		;CMPI		A3,0
		JAZ		A3,UDIVE
UDIV3:	MOV		A1,A2
		CMP		A3,A1
		JBE		UDIV4
		MOV		A0,A1  ; id divider > divident res=0 rem=divident
		MOVI		A1,0
		JMP		UDIVE
UDIV4:	MOV		A0,A2 ; main algorithm
		MOVI		A1,0
UDIV5:	BTST		A0,15  ; left align
		JNZ		UDIV6
		INC		A1
		SLL		A0,1
		JMP		UDIV5
UDIV6:	PUSH 		A1     ; store no of shifts
		MOVI		A2,0
		MOV		A1,A3
UDIV7:	BTST		A1,15  ; left align 
		JNZ		UDIV12
		SLL		A1,1
		INC		A2
		JMP		UDIV7
UDIV12:	MOV		A3,A1  
		MOV		A1,A2
		POP		A2  ; Get no of shifts
		SUB		A1,A2
UDIV10:	;CMPI		A2,0
		JAZ         A2,UDIV9
		SRL		A3,1
		SRL		A0,1
		DEC		A2
		JMP		UDIV10
UDIV9:	MOV		A2,A1  
		MOVI		A1,0       ; quotient
UDIV11:	CMP		A0,A3  ; compare remainder with divisor
		JC		UDIV8		
		BSET		A1,A2
		SUB		A0,A3
UDIV8:	SRL		A3,1
		DEC		A2
		JP		UDIV11
UDIVE:	POP		A3
		RETI

;------------------------------
; A1A2 / A3A4 res A1A2, rem A3A4
; long divide
LDIV:
 
  PUSH A5
  PUSH A7
  PUSHX
  MOV A0,A1
  XOR A0,A3
  PUSH A0   ;save result sign
  BTST A1,15
  JZ _DL1
  NOT A1
  NEG A2
  ADC A1,0
_DL1:
  BTST A3,15
  JZ _DL2
  NOT A3
  NEG A4
  ADC A3,0
_DL2:
  MOVI A0,0
  MOVI A7,0
  CMP A1,A3   ;   // compare if A1A2 <= A3A4 
  JC _DL4
  JA _DL8
  CMP A2,A4
  JBE _DL4
_DL8: 
  BTST A3,14  ;  // left align divisor
  JNZ _DL3
  SLLL A3,A4
  INC A0
  JMP _DL8
_DL3:          ;   left align dividend
  BTST A1,14
  JNZ _DL6
  SLLL A1,A2
  INC A7
  JMP _DL3
_DL6:
  JAZ A7,_DL12
  SUB A0,A7       ;  // shift difference   
  ;CMPI A7,0
_DL11:           ;       // shift right
  SRLL A1,A2
  SRLL A3,A4
  DEC A7
  JNZ _DL11
_DL12:
  MOVI A5,0    ;  // main
  MOVI A7,0
  SETX A0    ;    //steps = length difference+1
_DL7:
  SLLL A5,A7
  CMP A1,A3
  JC _DL5
  JA _DL9
  CMP A2,A4
  JC _DL5
_DL9:
  SUB A2,A4    ;  //A1A2 >= A3A4 then sub A3A4 and set 1
  JC  _DL20
  ADDI A1,1
_DL20:
  SUBI A1,1
  SUB A1,A3
  BSET A7,0
_DL5: 
  SRLL A3,A4  ;   // shift right
  JMPX _DL7
  MOV A3,A1        ;  // store remainder
  MOV A4,A2
  MOV A1,A5    ;  // store result
  MOV A2,A7
  JMP _DLEXIT
_DL4:          ; //beq
  MOV A3,A1
  MOV A4,A2
  MOVI A1,0
  MOVI A2,0
  JNZ _DLEXIT   ;  // if eq
  MOVI A2,1
  MOVI A3,0
  MOVI A4,0
_DLEXIT:
  POP A0
  BTST A0,15
  JZ _DL14
  NOT A1
  NEG A2
  ADC A1,0
_DL14:
  POPX
  POP A7
  POP A5
  RETI

;------------------------------
; A1A2 * A3A4 res A1A2
; long multiply

LMUL:
 
  PUSH A5
  PUSH A7
  PUSH A6
  MOV A0,A1
  XOR A0,A3
  PUSH A0        ;   // save result sign
  BTST A1,15
  JZ _ML1
  NOT A1
  NEG A2
  ADC A1,0
_ML1:
  BTST A3,15
  JZ _ML2
  NOT A3
  NEG A4
  ADC A3,0
_ML2:
  MOV A6,A2
  MOV A0,A4
  MULU A6,A0
  MOV A5,A0   ;   // 4 of 4
  MOV A0,A2
  MOV A7,A3
  MULU A0,A7
  ADD A5,A0   ;  // 3 of 4
  MOV A0,A1
  MOV A7,A4
  MULU A0,A7
  ADD A5,A0   ;// 2 of 4
  MOV A1,A5
  MOV A2,A6
  POP A0       ;  // restore sign
  BTST A0,15
  JZ _MLEXIT
  NOT A1
  NEG A2
  ADC A1,0
_MLEXIT:
  POP A6
  POP A7
  POP A5
  RETI

; -------------------------------------
SKEYBIN:	SDP   0
		IN	A0,6  ;Read serial byte if availiable
		BTST	A0,2  ;Result in A1, A0(2)=0 if not avail
		JZ	SKEXT
		IN	A1,14
		OUT	15,2
		OUT	15,0
		CMP.B	A1,$12
		JNZ	SKB1
		MOV.B (SHIFT),1
		JMP	SKEXT
SKB1:		CMP.B	A1,$59
		JNZ   SKB2
		MOV.B (SHIFT),1
		JMP	SKEXT		
SKB2:		CMP.B   A1,$58
		JNZ   INTEXIT
		MOV.B	(SHIFT),0
		MOV.B	A1,(CAPSL)
		XOR.B	A1,1
		MOV.B	(CAPSL),A1
SKEXT:	MOVI	A0,0
		RETI
;---------------------------------------
KEYB:		
		SDP   0
		PUSHX
		CMP.B	A1,$5A 
		JNZ	NOTCR
		MOVI	A1,13
		JMP	KB10
NOTCR:	CMP.B	A1,$66
		JNZ	NOTBS
		MOVI	A1,8
		JMP	KB10
NOTBS:	CMP.B	A1,$76
		JNZ	KB1
		MOV	A1,27
		JMP	KB10		
KB1:		SETX 	55           ; Convert Keyboard scan codes to ASCII
		MOV	A0,KEYBCD
KB3:		CMP.B	A1,(A0)
		JZ	KB4
		JXAB	A0,KB3
		MOVI	A1,0
		JMP	KB10
KB4:		SUB   A0,KEYBCD
		CMP.B   (CAPSL),1
		JNZ   KB2
		CMP.B (SHIFT),1
		JZ	KB2
		ADD   A0,KEYASCC
		JMP	KB6
KB2:		CMP.B (SHIFT),1
		JNZ   KB5
		ADD   A0,KEYASCS
		JMP   KB6
KB5:		ADD	A0,KEYASC
KB6:        MOV.B A1,(A0)
KB10:		MOV.B (SHIFT),0
		POPX
		RETI

KEYBCD	DB    $29,$45,$16,$1E,$26,$25,$2E,$36,$3D,$3E,$46,$1C,$32,$21,$23,$24,$2B,$34,$33,$43,$3B,$42,$4B
            DB    $3A,$31,$44,$4D,$15,$2D,$1B,$2C,$3C,$2A,$1D,$22,$35,$1A
		DB    $0E,$4E,$55,$5D,$54,$58,$4C,$52,$41,$49,$4A,$72,$6B,$74,$75     ; `-=\[];',./
		DB	$A5,$AB,$A2,$A4

KEYASC	DB    32,48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76
            DB    77,78,79,80,81,82,83,84,85,86,87,88,89,90
  		DB	96,45,61,92,91,93,59,39,44,46,47,50,52,54,56
            DB    65,68,66,67

KEYASCS	DB    32,41,33,64,35,36,37,94,38,42,40,65,66,67,68,69,70,71,72,73,74,75,76
            DB    77,78,79,80,81,82,83,84,85,86,87,88,89,90
  		DB	126,95,43,124,123,125,58,34,60,62,63,50,52,54,56
		DB    65,68,66,67

KEYASCC	DB    32,48,49,50,51,52,53,54,55,56,57,97,98,99,100,101,102,103,104,105,106,107,108
            DB    109,110,111,112,113,114,115,116,117,118,119,120,121,122
  		DB	96,45,61,92,91,93,59,39,44,46,47,50,52,54,56
		DB    65,68,66,67

ROMEND:
; Charcter table Font
CTABLE2	DB	0,0,0,0,0,0,0,0, 0,96,250,250,96,0,0,0;!
CC34_35	DB	0,224,224,0,224,224,0,0, 40,254,254,40,254,254,40,0; # "
CC36_37	DB	36,116,214,214,92,72,0,0, 98,102,12,24,48,102,70,0  ; $ %
CC38_39     DB    12,94,242,186,236,94,18,0, 32,224,192,0,0,0,0,0 ; & '
CC40_41	DB	0,56,124,198,130,0,0,0, 0,130,198,124,56,0,0,0  ; ( )
CC42_43	DB	16,84,124,56,56,124,84,16, 16,16,124,124,16,16,0,0 ; * +
CC44_45	DB	0,1,7,6,0,0,0,0, 16,16,16,16,16,16,0,0; , -
CC46_47	DB	0,0,0,6,6,0,0,0, 6,12,24,48,96,192,128,0 ; . /
CC48_49	DB	124,254,142,154,178,254,124,0, 2,66,254,254,2,2,0,0 ; 0 1
CC50_51	DB	70,206,154,146,246,102,0,0, 68,198,146,146,254,108,0,0 ; 2 3
CC52_53	DB	24,56,104,202,254,254,10,0, 228,230,162,162,190,156,0,0 ; 4 5
CC54_55	DB	60,126,210,146,158,12,0,0, 192,192,142,158,240,224,0,0; 6 7
CC56_57	DB	108,254,146,146,254,108,0,0, 96,242,146,150,252,120,0,0; 8 9
CC58_59	DB	0,0,102,102,0,0,0,0, 0,1,103,102,0,0,0,0 ; : ;
CC60_61	DB	16,56,108,198,130,0,0,0, 36,36,36,36,36,36,0,0; < =
CC62_63	DB	0,130,198,108,56,16,0,0, 64,192,138,154,240,96,0,0 ; > ?
CC64_65	DB	124,254,130,186,186,248,120,0, 62,126,200,200,126,62,0,0  ;@  A
CC66_67	DB	130,254,254,146,146,254,108,0, 56,124,198,130,130,198,68,0;B C
CC68_69	DB	130,254,254,130,198,124,56,0, 130,254,254,146,186,130,198,0 ;D E
CC70_71	DB	130,254,254,146,184,128,192,0, 56,124,198,130,138,206,78,0 ;F G
CC72_73	DB	254,254,16,16,254,254,0,0, 0,130,254,254,130,0,0,0 ; H I
CC74_75	DB	12,14,2,130,254,252,128,0, 130,254,254,16,56,238,198,0 ; J K
CC76_77	DB	130,254,254,130,2,6,14,0, 254,254,112,56,112,254,254,0 ;  L M
CC78_79	DB	254,254,96,48,24,254,254,0, 56,124,198,130,198,124,56,0 ; N O
CC80_81	DB	130,254,254,146,144,240,96,0, 120,252,132,142,254,122,0,0 ; P Q
CC82_83	DB	130,254,254,144,152,254,102,0, 100,246,178,154,206,76,0,0 ; R S
CC84_85	DB	192,130,254,254,130,192,0,0, 254,254,2,2,254,254,0,0; T U
CC86_87	DB	248,252,6,6,252,248,0,0, 254,254,12,24,12,254,254,0  ;V W
CC88_89	DB	194,230,60,24,60,230,194,0, 224,242,30,30,242,224,0,0 ;X Y
CC90_91	DB	226,198,142,154,178,230,206,0, 0,254,254,130,130,0,0,0 ; Z [
CC92_93	DB	128,192,96,48,24,12,6,0, 0,130,130,254,254,0,0,0 ;  \ ]
CC94_95	DB	16,48,96,192,96,48,16,0, 1,1,1,1,1,1,1,1 ;  ^ _
CC96_97	DB	0,0,192,224,32,0,0,0, 4,46,42,42,60,30,2,0 ; ` a
CC98_99	DB	130,254,252,18,18,30,12,0, 28,62,34,34,54,20,0,0 ;b c
CC100_101	DB	12,30,18,146,252,254,2,0, 28,62,42,42,58,24,0,0 ;d e
CC102_103	DB	18,126,254,146,192,64,0,0, 25,61,37,37,31,62,32,0 ;f g 
CC104_105	DB	130,254,254,16,32,62,30,0, 0,34,190,190,2,0,0,0 ; h  i
CC106_107	DB	6,7,1,1,191,190,0,0, 130,254,254,8,28,54,34,0 ; j k
CC108_109	DB	0,130,254,254,2,0,0,0, 62,62,24,28,56,62,30,0 ; l m
CC110_111	DB	62,62,32,32,62,30,0,0, 28,62,34,34,62,28,0,0 ; n o
CC112_113	DB	33,63,31,37,36,60,24,0, 24,60,36,37,31,63,33,0 ; p q
CC114_115	DB	34,62,30,50,32,56,24,0, 18,58,42,42,46,36,0,0 ;r s
CC116_117	DB	0,32,124,254,34,36,0,0, 60,62,2,2,60,62,2,0 ;t u
CC118_119	DB	56,60,6,6,60,56,0,0, 60,62,14,28,14,62,60,0 ;v w
CC120_121	DB    34,54,28,8,28,54,34,0, 57,61,5,5,63,62,0,0 ;x y
CC122_123   DB    50,38,46,58,50,38,0,0, 16,16,124,238,130,130,0,0 ; z {
CC124_125	DB	0,0,0,238,238,0,0,0,  130,130,238,124,16,16,0,0 ; | }
CC126_127	DB	64,192,128,192,64,192,128,0, 14,30,50,98,50,30,14,0 ; ~ triangle


CTABLE	DB	0,0,0,0,0,0,58,0,0,0,0,0
C34_35	DB	96,0,96,0,0,0,20,62,20,62,20,0
C36_37	DB	58,42,127,42,46,0,34,4,8,16,34,0
C38_39      DB    20,62,20,62,20,0,96,0,0,0,0,0
C40_41	DB	0,28,34,0,0,0,0,34,28,0,0,0
C42_43	DB	168,112,32,112,168,0,8,8,62,8,8,0
C44_45	DB	3,0,0,0,0,0,8,8,8,8,8,0
C46_47	DB	2,0,0,0,0,0,0,6,8,48,0,0
C48_49	DB	28,38,42,50,28,0,0,18,62,2,0,0
C50_51	DB	38,42,42,42,18,0,34,42,42,42,54,0
C52_53	DB	60,4,14,4,4,0,58,42,42,42,36,0
C54_55	DB	62,42,42,42,46,0,32,32,38,40,48,0
C56_57	DB	62,42,42,42,62,0,58,42,42,42,62,0
C58_59	DB	34,0,0,0,0,0,35,0,0,0,0,0
C60_61	DB	8,20,34,0,0,0,20,20,20,20,20,0
C62_63	DB	34,20,8,0,0,0,16,32,42,16,0,0
C64_65	DB	62,34,42,42,58,0,62,36,36,36,62,0
C66_67	DB	62,42,42,42,54,0,62,34,34,34,34,0
C68_69	DB	62,34,34,34,28,0,62,42,42,42,34,0
C70_71	DB	62,40,40,40,32,0,62,34,34,42,46,0
C72_73	DB	62,8,8,8,62,0,34,34,62,34,34,0
C74_75	DB	6,2,2,34,62,0,62,8,8,20,34,0
C76_77	DB	62,2,2,2,2,0,62,16,8,16,62,0
C78_79	DB	62,16,8,4,62,0,28,34,34,34,28,0
C80_81	DB	62,40,40,40,16,0,60,36,38,36,60,0
C82_83	DB	62,40,40,40,22,0,58,42,42,42,46,0
C84_85	DB	32,32,62,32,32,0,62,2,2,2,62,0
C86_87	DB	48,12,2,12,48,0,60,2,12,2,60,0
C88_89	DB	34,20,8,20,34,0,48,8,6,8,48,0
C90_91	DB	34,38,42,50,34,0,62,34,0,0,0,0
C92_93	DB	48,8,6,0,0,0,34,62,0,0,0,0
C94_95	DB	0,64,128,64,0,0,2,2,2,2,2,2
C96_97	DB	0,128,0,0,0,0,0,4,42,42,42,30       ; ` a
C98_99	DB	0,254,34,34,34,28,0,28,34,34,34,20  ;b c
C100_101	DB	0,28,34,34,34,254,0,28,42,42,42,16  ;d e
C102_103	DB	0,16,126,144,144,0,0,24,37,37,37,62 ;f g 
C104_105	DB	0,254,32,32,30,0,0,0,0,190,2,0       ; h  i
C106_107	DB	0,2,1,33,190,0,0,254,8,20,34,0    ; j k
C108_109	DB	0,0,0,254,2,0,0,62,32,24,32,30    ; l m
C110_111	DB	0,62,32,32,30,0,0,28,34,34,34,28  ; n o
C112_113	DB	0,63,34,34,34,28,0,28,34,34,34,63 ; p q
C114_115	DB	0,34,30,34,32,16,0,16,42,42,42,4  ;r s
C116_117	DB	0,32,124,34,36,0,0,60,2,4,62,0    ;t u
C118_119	DB	0,56,4,2,4,56,0,60,6,12,6,60      ;v w
C120_121	DB    0,54,8,8,54,0,0,57,5,6,60,0     ;x y
C122_123    DB    0,38,42,42,50,0,0,0,8,62,34,0,0 ; z {
C124_125 	DB	54,0,0,0,0,0,0,34,62,8,0,0
C126  	DB	64,128,64,128,0,0


BOOTBIN     TEXT		"BOOT    BIN"
		DB 	0
SDOK		TEXT		"SD Card OK"
		DB	0
SDBOK		TEXT        "Loading BOOT.BIN"
		DB	0
SDNOTOK	TEXT		"No SDCard Boot"
		DB	0
MEMNOTOK	TEXT		"Memory Error"
		DB	0


		ORG     	8192   ;Ram

SDCBUF1	DS	514
SDCBUF2	DS	514
FATBOOT	DS	2 ; boot sector 
CURDIR	DS	2 ; current root dir
FSTCLST	DS	2 ; first data cluster
FSTFAT	DS	2 ; first fat cluster
SDFLAG	DS	2 ; 256 if sd mounted ok
COUNTER     DS	2 ; Counter for general use increased by VSYNC INT 3 
FRAC1		DS	2 ; was for fixed point multiplication - division
FRAC2		DS	2 ; was 
RHINT0	DS	4 ; RAM redirection of interrupts
RHINT1	DS	4 ; to be filled with jmp to service routine instructions
RHINT2	DS	4		
RINT6		DS	4
RINT7		DS	4
RINT8		DS	4
RINT9		DS	4
RINT15	DS	4 ; TRACE INT service routine
VMODE		DS	1
SCOL		DS    1
SHIFT       DS    1
CAPSL       DS    1
CIRCX		DS	2
CIRCY		DS	2
PLOTM		DS	2  ; Plot mode 1=normal 0=clear
SECNUM	DS	2 ; Total num of sectors in sd
SECPFAT	DS	2 ; Sectors per Fat
FATROOT	DS	2 ; fat root dir
SDHC        DS    1 ; is the sd hc ?
SDERROR     DS    1 ; sd card #error
RESRVB      DS    2 ; reserved
START:	

