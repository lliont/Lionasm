;  2015 Theodoulos Liontakis  - system rom

	  	ORG 		0    ; Rom 
INT0_3      DA		HINT   ; hardware interrupts
		DA          HINT
		DA		HINT
		DA		HINT   
INT4        DA        	INTR4     ;interrupt vector 4
INT5_14     DW          0,0,0,0,0,0,0,0,0,0
INT15		DA		INTR15   ; trace interrupt

		SETI		25       ; Set default color table
		MOV		A1,65144
COLINIT:	MOV.B		(A1),68
		INC		A1
		JMPI		COLINIT	
		STI	
		JMP		START  ; address at RAM

;  INT4 FUNCTION TABLE  function in a0
INT4T0	DA		SERIN    ; Serial port in    
INT4T1	DA		SEROUT   ; Serial port out
INT4T2	DA		PLOT     ; at X=A1,Y=A2 A4=1 set A4=0 clear
INT4T3	DA		CLRSCR   ; CLEAR SCREEN
INT4T4	DA		PUTC     ; Print char A2 at A1.H A1.L
INT4T5	DA		PSTR     ; Print zero & cr terminated string
INT4T6	DA		SCROLL   ; Scrolls screen 1 char (8 points) up
INT4T7	DA		SKEYBIN  ; Serial Keyboard port in
INT4T8	DA		MULT     ; Multiplcation A1*A2 res in A1, a0<>0 overflow 
INT4T9	DA		DIV      ; Div A2 by A1 res in A1,A0
INT4T10	DA		KEYB     ; converts to ascii the codes from serial keyboard
INT4T11	DA		SPI_INIT ; initialize spi sd card
INT4T12	DA		SPISEND  ; spi send/receive byte in A1 mode A2 1=CS low 3=CS high
					   ; result in A0
INT4T13	DA		READSEC  ; read n sector in buffer, n in A1
INT4T14	DA		WRITESEC ; WRITE SEC FROM BUFFER TO A1 BLOCK

VBASE		EQU		57344
XDIM2		EQU		150    ; XDIM/2 Screen Horizontal Dim. / 2
YDIM		EQU		208    ; Screen Vertical Dimention
XCC		EQU		50     ; Horizontal Lines
YCC		EQU		26     ; Vertical Rows

HINT:		PUSH		A0      ;  internal interupt 0 
		MOV		A0,(COUNTER)
		INC		A0
		MOV		(COUNTER),A0
		POP		A0
INTR15:	RETI        ; trace interrupt
		
INTR4:	SLL		A0,1
		ADD		A0,INT4T0
		JMP		(A0)
INTEXIT:	RETI

;---------------------------------------
WRITESEC:
	PUSHI
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4

	MOV	A4,A1
	MOV	A3,A1
	SRL	A3,7
	SLL	A4,9    ; multiply 512 to convert block to byte

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS
	MOVI	A2,1
	OUT	19,1

	MOV 	A1,$58  ; write SECTOR
	JSR	SPIS
	MOVLH	A1,A3
	JSR	SPIS
	MOV.B	A1,A3
	JSR	SPIS
	MOVLH	A1,A4
	JSR	SPIS
	MOV.B	A1,A4
	JSR	SPIS
	MOV 	A1,$FF 
	JSR	SPIS 

	MOV	A1,$FF   ; delay
	JSR	SPIS
	 
	MOV	A1,$FE    ; SEND START OF DATA
	JSR	SPIS	

	MOV	A3,SDCBUF  ; buffer
	SETI	511        ; WRITE DATA 512 BYTES + 2 CRC bytes
WRI6:	MOV.B	A1,(A3)
	JSR	SPIS
	INC	A3
	JMPI	WRI6
	MOVI	A1,0
	JSR	SPIS
	MOVI	A1,0
	JSR	SPIS

	SETI	100          ; READ ANSWER until $05 is found
WRS8:	MOV	A1,$FF
	JSR	SPIS
	AND.B	A0,$0F
	CMP.B	A0,5
	JRZ	4
	JMPI	WRS8

	CMP.B	A0,5
	JNZ	WRIF

	SETI	5000          ; READ ANSWER until $00 is found
WRS9: MOV	A1,$FF
	JSR	SPIS
	OR.B	A0,A0
	JRZ	4
	JMPI	WRS9
	
	OR.B	A0,A0
	JNZ	WRIF

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS

	MOV	A0,$0100  ; ALL OK

WRIF: POP	A4
	POP	A3
	POP	A2
	POP	A1
	POPI
	RETI

;-----------------------------------------

READSEC:
	PUSHI
	PUSH	A1
	PUSH	A2
	PUSH	A3
	PUSH	A4

	MOV	A4,A1
	MOV	A3,A1
	SRL	A3,7
	SLL	A4,9    ; multiply 512 to convert block to byte

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS
	MOVI	A2,1
	OUT	19,1

	MOV 	A1,$51  ; READ SECTOR
	JSR	SPIS
	MOVLH	A1,A3
	JSR	SPIS
	MOV.B	A1,A3
	JSR	SPIS
	MOVLH	A1,A4
	JSR	SPIS
	MOV.B	A1,A4
	JSR	SPIS
	MOV 	A1,$FF 
	JSR	SPIS 

	SETI	299          ; READ ANSWER until $FE is found
RDS5:	MOV	A1,$FF
	JSR	SPIS
	CMP.B	A0,$FE
	JZ	SDRD2
	JMPI	RDS5

SDRD2:
	CMP.B	A0,$FE  
	JNZ	RDIF       ; data ready ?
	MOV	A3,SDCBUF  ; read to buffer
	SETI	513        ; READ DATA 512 BYTES + 2 CRC bytes
RDI6:	MOV	A1,$FF
	JSR	SPIS
	MOV.B	(A3),A0
	INC	A3
	JMPI	RDI6

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS

	MOV	A0,$0100  ; ALL OK

RDIF: POP	A4
	POP	A3
	POP	A2
	POP	A1
	POPI
	RETI

;-----------------------------------------
SPISEND:
	PUSH	A1
	PUSH	A2
	JSR	SPIS
	POP	A2
	POP	A1
	RETI
;------------------------------------------------
SPIS:
	OUT	18,A1
	OUT	19,A2
	BCLR	A2,0
	OUT	19,A2
	BSET	A2,0
SPIC: IN	A1,17
	OR.B	A1,A1
	JNZ	SPIC
	IN	A0,16
	RET
	
;--------------- * INIT * ----------------
SPI_INIT:
	PUSHI
	PUSH 	A1
	PUSH	A2
	PUSH	A3

	MOVI	A3,0

SPIN:	CMP	A3,100   
	JA	SPIF  ; MANY RETRIES FAIL
	SETI	9
	MOVI	A2,3
SPI0: MOV	A1,255	
	JSR	SPIS
	JMPI	SPI0    ; SEND 80 CLK PULSES WITH CS HIGH
	
	MOVI	A2,1
	OUT	19,0    ; cs=0


	MOV 	A1,$40  ; INIT SPI MODE WITH CS LOW
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOV 	A1,$95
	JSR	SPIS	

	SETI	7	         ;READ 8 RESPONCES
SPI3:	MOV	A1,$FF
	JSR	SPIS
	CMP.B A0,1
	JNZ	SPNF
	MOV	A2,5
SPNF:	JMPI	SPI3
	
	INC 	A3	
	CMP	A2,5
	JNZ	SPIN

	MOV	A3,0

SPNT:	CMP	A3,50
	JA	SPIF

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS
	MOVI	A2,1

	MOV 	A1,$41  ; INITIALIZE spi
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOV 	A1,$FF 
	JSR	SPIS 

	SETI	7         ; READ 8 ANSWERS
SPI2:	MOV	A1,$FF
	JSR	SPIS
	OR.B	A0,A0
	JNZ	SPNX
	MOV	A2,5
SPNX:	JMPI	SPI2

	INC	A3
	CMP	A2,5
	JNZ	SPNT

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS
	MOVI	A2,1

	MOV 	A1,$50  ; SET TRANSFER SIZE
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$02
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOV 	A1,$FF 
	JSR	SPIS 

	SETI	7          ; READ ANSWER
SPI4:	MOV	A1,$FF
	JSR	SPIS
	JMPI	SPI4

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS
	MOVI	A2,1

	MOV 	A1,$51  ; READ FIRST SECTOR
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOVI 	A1,$0
	JSR	SPIS
	MOV 	A1,$FF 
	JSR	SPIS 

	SETI	51          ; READ ANSWER until $FE is found
SPI5:	MOV	A1,$FF
	JSR	SPIS
	CMP.B	A0,$FE
	JZ	SDRD
	JMPI	SPI5

SDRD:	CMP.B	A0,$FE  
	JNZ	SPIF       ; data ready ?
	MOV	A3,SDCBUF  ; read to buffer
	SETI	513        ; READ DATA 512 BYTES + 2 CRC bytes
SPI6:	MOV	A1,$FF
	JSR	SPIS
	MOV.B	(A3),A0
	INC	A3
	JMPI	SPI6

	MOVI	A2,3
	MOV 	A1,$FF  ; send dummy with cs high
	JSR	SPIS

	MOV	A0,$0100  ; ALL OK

SPIF:	POP	A3
	POP	A2
	POP	A1
	POPI
	RETI

;---------------------------------------- 
SERIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,1  ;Result in A1, A0(1)=0 if not avail
		JZ		INTEXIT
		IN		A1,4
		MOVI		A0,2
		OUT		2,A0
		MOVI		A0,0
		OUT		2,A0
		MOVI		A0,2
		RETI
;----------------------------------------
SEROUT:	IN		A0,6  ;Wite serial byte if ready
		BTST		A0,0  ; A0(0)=0 if not ready
		JZ		INTEXIT
            PUSH        A1
		OUT		0,A1
		MOVI		A1,0
		MOVI		A0,1
		OUT		2,A0
		OUT		2,A1
		POP		A1
		RETI
; -------------------------------------
SKEYBIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,2  ;Result in A1, A0(2)=0 if not avail
		JZ		INTEXIT
		IN		A1,14
		MOVI		A0,2
		OUT		15,A0
		MOVI		A0,0
		OUT		15,A0
		MOVI		A0,4
		RETI

;----------------------------------------
PUTC:		PUSHI        ;  PRINT Character in A1 at A2 (XY)
		PUSH		A4
		PUSH		A3
		CMP.B		A1,96  
		JBE		LAB1
		SUB		A1,32
		CMP.B		A1,90
		JLE		LAB1
		ADD		A1,6
LAB1:		SUB		A1,32    
		MULU.B	A1,6
		ADD		A1,CTABLE
		MOV		A4,A1       ; character table address
		MOV.B		A0,A2
		MULU.B	A0,XDIM2
		SLL		A0,1
		MOVI		A1,0
          	MOVLH 	A1,A2
		MULU.B	A1,6
		ADD		A0,A1
		ADD		A0,VBASE   ; video base
		MOV		A3,A0      ; Addres at videoram
		SETI		5          ; 6 Times
LP1:		MOV.B		(A3),(A4)
		INC		A4
		INC		A3          ; next   
		JMPI		LP1
		POP		A3
		POP		A4
		POPI	
		RETI
;----------------------------------------
PSTR:		MOVI.B	A0,0 ; PRINT A 0 OR 13 TERM. STRING POINTED BY A1 AT A2
		MOV.B		A0,(A1)
		CMP.B		A0,0
		JZ		STREXIT
		CMP.B		A0,13
		JNZ         PSTR2
		MOVI		A0,6
		INT		4
		JMP		STREXIT
PSTR2:	PUSH 		A1
		MOV		A1,A0
		MOVI		A0,4
		INT		4
		POP		A1
		SWAP		A2       ;  X
		INC		A2
		CMP.B		A2,XCC
		JNZ		LAB3
		MOVI.B	A2,0
		SWAP		A2
		INC		A2
		CMP.B		A2,YCC
		JNZ		LAB3
		MOVI		A0,6
		INT		4
LAB3:		SWAP		A2
		INC		A1
		JMP		PSTR
STREXIT:	RETI
;----------------------------------------

SCROLL:	PUSHI
		PUSH		A1
		SETI		7499	
		MOV		A0,VBASE
		MOV		A1,57644
SC1:		MOV.B		(A0),(A1)  ;  Only byte wide access to video ram
		INC		A0
		INC		A1
		JMPI		SC1
		SETI		299
SC2:		MOV.B		(A0),0
		INC		A0
		JMPI		SC2		
		POP		A1
		POPI
		RETI
;----------------------------------------

CLRSCR:	PUSHI
		SETI		2*3900-1	
		MOV		A0,VBASE
CLRS1:	MOV.B		(A0),0
		INC		A0
		JMPI		CLRS1
		POPI
;----------------------------------------
PLOT:		PUSHI
		PUSH		A1
		PUSH		A2        ; PLOT at A1,A2 mode in A4
		MOV		A0,A2
		AND		A0,7
		SRL		A2,3
		MULU.B	A2,XDIM2
		SLL		A2,1
		ADD		A2,A1
		ADD		A2,VBASE 
		MOV.B		A1,(A2)
		SETI		A0
PL1:		SLL		A1,1
		JMPI		PL1
		CMP		A4,0
		JNZ		PL3
		BCLR		A1,8
		JMP		PL4
PL3:		CMP		A4,2
		JNZ		PL5
		XOR		A1,$100
		JMP		PL4
PL5:		BSET		A1,8
PL4:		SETI		A0
PL2:		SRL		A1,1
		JMPI		PL2
		MOV.B		(A2),A1
		POP		A2
		POP		A1
		POPI
		RETI
;---------------------------------------
KEYB:		PUSHI
		SETI 		67           ; Convert Keyboard scan codes to ASCII
		MOV		A0,KEYBCD
LP3:		CMP.B		A1,(A0)
		JZ		LP4
		INC		A0
		JMPI		LP3
		MOV		A1,0
		JMP		LP10
LP4:		MOVIDX	A0
		MOV		A1,99
		SUB		A1,A0
		CMP.B		A1,94
		JBE		LP10
		ADD		A1,28
LP10:		POPI
		RETI

;--------------------------------------------------------------

MULT:		PUSH		A3
		PUSHI
		MOV		A0,A2
		XOR		A0,A1
		PUSH		A0
		BTST		A1,15    ; check if neg and convert 
		JZ		MUL2
		NOT		A1
		INC		A1
MUL2:		BTST		A2,15   ; check if neg and convert 
		JZ		MUL3
		NOT		A2
		INC		A2
MUL3:		MOV		A3,A2
		MULU.B	A3,A1
		MOV		A0,A1
		SWAP		A0
		MULU.B	A0,A2
		SETI		7		
SH1:		SLL		A0,1
		JMPI		SH1
		BTST		A0,15
		JNZ		MOVER
		ADD		A3,A0
		JN		MOVER
		MOV		A0,A2
		SWAP		A0
		MULU.B	A0,A1
		SETI		7		
SH2:		SLL		A0,1
		JMPI		SH2
		BTST		A0,15
		JNZ		MOVER
		ADD		A3,A0
		JN		MOVER
		POP		A0
		BTST		A0, 15
		MOVI		A0,0
		JZ		MULEND     ; Check result sign
		NOT		A3
		INC		A3
		JMP		MULEND
MOVER:      POP		A0
		MOV		A0,1
MULEND:	MOV		A1,A3	
		POPI
		POP		A3
		RETI

;-------------------------------------------------------------
DIV:		PUSHI
		PUSH		A3
		PUSH		A4
		MOV		A3,A1
		MOV		A1,32767
		MOV		A0,A3
		CMP		A0,0
		JZ		DIVE
		MOVI		A1,0
		XOR		A0,A2
		BTST		A0,15
		JZ		DIV1     ; Check result sign
		MOVI		A1,1
DIV1:		PUSH		A1
		MOV 		A1,A2  
		BTST		A1,15    ; check if neg and convert 
		JZ		DIV2
		NOT		A1
		INC		A1
		MOV		A2,A1
DIV2:		MOV 		A1,A3
		BTST		A1,15   ; check if neg and convert 
		JZ		DIV3
		NOT		A1
		INC		A1
		MOV		A3,A1
DIV3:		MOV		A1,A2
		CMP		A1,A3
		JA		DIV4
		JZ		DIV4
		MOV		A0,A1
		MOVI		A1,0
		JMP		DIV14
DIV4:		MOV		A0,A2
		MOVI		A1,0
DIV5:		BTST		A0,14
		JNZ		DIV6
		INC		A1
		SLL		A0,1
		JMP		DIV5
DIV6:		PUSH 		A1     ; store no of shifts
		MOVI		A4,0
		MOV		A1,A3
DIV7:		BTST		A1,14  ; align first 1's
		JNZ		DIV12
		SLL		A1,1
		INC		A4
		JMP		DIV7
DIV12:	MOV		A2,A0  
		MOV		A3,A1  
		MOV		A1,A4
		POP		A0  ; Get no of shifts
		MOV		A4,A0
		SUB		A1,A0
		PUSH		A1
		MOV		A0,A2  
		MOV		A1,A3  
DIV10:	CMP		A4,0
		JZ		DIV9
		SRL		A1,1
		SRL		A0,1
		DEC		A4
		JMP		DIV10
DIV9:		MOV		A2,A0  ; new dividend = remainder
		MOV		A3,A1  ; new divisor
		POP		A1
		SETI		A1
		MOVI		A1,0       ; quotient
DIV11:	SLL		A1,1       
		CMP		A0,A3  ; compare remainder with divisor
		JA		DIV13
		JZ		DIV13
		JMP		DIV8		
DIV13:	BSET		A1,1
		SUB		A0,A3
DIV8:		SRL		A3,1
		JMPI		DIV11
		SRL		A1,1
DIV14:	POP		A3
		CMP		A3,0
		JZ		DIVE
		NOT		A1
		INC		A1
		;NOT		A0
		;INC		A0
DIVE:		POP		A4
		POP		A3
		POPI
		RETI


; Charcter table Font
CTABLE	DB	0,0,0,0,0,0,58,0,0,0,0,0
C34_35	DB	96,0,96,0,0,0,20,62,20,62,20,0
C36_37	DB	58,42,127,42,46,0,34,4,8,16,34,0
C38_39      DB    20,62,20,62,20,0,96,0,0,0,0,0
C40_41	DB	28,34,0,0,0,0,34,28,0,0,0,0
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
C96_123	DB	0,128,0,0,0,0,0,8,62,34,0,0
C124_125 	DB	54,0,0,0,0,0,0,34,62,8,0,0
C126  	DB	64,128,64,128,0,0


KEYBCD	DB    $29,$16,$71,$26,$25,$2E,$3D,$52,$46,$45,$3E,$79,$41,$4E,$49,$4A,$70,$69,$72,$7A
		DB    $6B,$73,$74,$6C,$75,$7D,$7C,$4C,$7E,$55,$E1,$78,$1E,$1C,$32,$21,$23,$24,$2B,$34
		DB	$33,$43,$3B,$42,$4B,$3A,$31,$44,$4D,$15,$2D,$1B,$2C,$3C,$2A,$1D,$22,$35,$1A,$54
		DB	$5D,$58,$36,$3,$0B,$83,$0A,0

		ORG     	8192   ;Ram
SDCBUF	DS	514
NUM1		DS	4
NUM2		DS	4
NUM3		DS	4
COUNTER	DW	0 ; Counter for general use increased by hardware int 0 
START:	

