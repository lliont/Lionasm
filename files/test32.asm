	  	ORG 		0  ; Rom 
INT0_3      DW		0,0,0,0
INT4        DW        #0000000000100100
		ORG     	32
		JMP		START
INTR4:    	CMP		A0,0
		JZ		SERIN
		CMP		A0,1
		JZ		SEROUT
		CMP		A0,4
		JZ		PUTC
		CMP		A0,5
		JZ		PSTR
		CMP		A0,6
		JZ		SCROLL
		CMP		A0,7
		JZ		REFRESH
		CMP		A0,8
		JZ		CLRSCR
		CMP		A0,10
		JZ		KEYB
		MOVI		A0,0
		RETI
SERIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,1  ;Result in A1, A0(1)=0 if not avail
		JZ		INTEXIT
		IN		A1,4
		MOVI		A0,2
		OUT		2,A0
		MOVI		A0,0
		OUT		2,A2
		MOVI		A0,2
		RETI
SEROUT:	IN		A0,6  ;Wite serial byte if ready
		BTST		A0,0  ;Result in A1, A0(0)=0 if not ready
		JZ		INTEXIT
		OUT		0,A1
		MOVI		A1,0
		MOVI		A0,1
		OUT		2,A0
		OUT		2,A1
		RETI
PUTC:		PUSHI
		MOV.B		A0,(YY)
		SLL		A0,5
		ADD.B		A0,(XX)
		ADD		A0,TEXTBUF
		MOV.B		(A0),A1
		CMP		A1,96  ;  PRINT Character in A1 at XX,YY
		JLE		LAB1
		SUB		A1,32
LAB1:		SUB		A1,32    
		SLL		A1,3
		ADD		A1,CTABLE
		MOV		(AD1),A1  ; save character table address
		MOVI		A0,0
		MOV.B		A0,(YY)
		SLL		A0,8    ; 32 perline  * 8 lines per char
		MOVI		A1,0
          	MOV.B 	A1,(XX)
		ADD		A0,A1
		ADD		A0,61440 ; video base
		MOV		(AD2),A0  ; Addres at videoram
		SETI		7
		MOV		A1,(AD1)
LP1:		MOV.B		A0,(A1)
		PUSHI
		SETI		7
		MOVI		A1,0
LP2:		BTST		A0,7
		JZ		LAB2
		BSET		A1,7
LAB2:		SLL		A0,1
		SRL		A1,1
		JMPI		LP2
		POPI
		MOV		A0,(AD2)
		MOV.B		(A0),A1
		MOV		A1,(AD1)
		INC		A1
		MOV		(AD1),A1
		MOV		A0,(AD2)
		ADD		A0,32          ; next line
		MOV		(AD2),A0  
		JMPI		LP1
		POPI	
		RETI
PSTR:		PUSH 		A1         ; PRINT A ZERO TERM. STRING POINTED BY A1
		MOVI		A0,0
		MOV.B		A0,(A1)
		MOV		A1,A0
		CMP		A1,0
		JZ		STREXIT
		MOV		A0,4
		INT		4
		MOVI		A0,0
		MOV.B		A0,(XX)
		INC		A0
		CMP		A0,32
		JNZ		LAB3
		MOVI		A0,0
		MOV.B		(XX),A0
		MOVI		A1,0
		MOV.B		A1,(YY)
		INC		A1
		CMP		A1,16
		JNZ		LAB4
		MOVI		A1,0
LAB4:		MOV.B		(YY),A1		
LAB3:		MOV.B		(XX),A0
		POP		A1
		INC		A1
		JMP		PSTR
STREXIT:	POP		A1
		RETI
SCROLL:	PUSHI                       ; Scroll text buffer
		SETI		480
		MOV		A0,TEXTBUF
		MOV		A1,A0
		ADD		A1,32
LP5:		MOV.B		(A0),(A1)
		INC		A1
		INC		A0
		JMPI		LP5
		SETI		31
		MOV		A0,TEXTBUF
		ADD		A0,480
LP8:		MOV.B		(A0),32
		INC		A0
		JMPI		LP8
		POPI
		RETI	
REFRESH:	PUSHI                       ; Refresh Screen 
		SETI		255
		MOV		A1,(XX)
		PUSH		A1
LP6:		MOVIDX	A0
		AND		A0,$000F
		MOV.B		(XX),A0
		MOVIDX	A0
		SRL		A0,4
		MOV.B		(YY),A0
		MOVIDX	A0
		ADD		A0,TEXTBUF
		MOVI		A1,0
		MOV.B		A1,(A0)
		MOVI		A0,4
		INT		4
		JMPI		LP6
		POP		A1
		MOV		(XX),A1
		POPI
		RETI
CLRSCR:	PUSHI		         ; Clear screen buffer
		SETI		512
		MOV		A0,TEXTBUF
LP7:		MOV.B		(A0),32
		INC		A0
		JMPI		LP7
		POPI
		RETI
KEYB:		PUSHI
		SETI 		63            ; Convert Keyboard scan codes to ASCII
		MOV		A0,KEYBCD
LP3:		CMP.B		A1,(A0)
		JZ		LP4
		INC		A0
		JMPI		LP3
		MOV		A1,0
		JMP		INTEXIT
LP4:		MOVIDX	A0
		MOV		A1,95
		SUB		A1,A0
		POPI
		RETI	

INTEXIT:	RETI

CTABLE	DB	0,0,0,0,0,0,0,0,   $18,$3C,$3C,$18,$18,0,$18,0
C34_35	DB	$36,$36,0,0,0,0,0,0,    $36,$36,$7F,$36,$7F,$36,$36,0
C36_37	DB	$0C,$3E,3,$1E,$30,$1F,$0C,0,   0,$63,$33,$18,$0C,$66,$63,0
C38_39      DB    $1C,$36,$1C,$6E,$3B,$33,$6E,0,   6,6,3,0,0,0,0,0
C40_41	DB	$18,$0C,6,6,6,$0C,$18,0,   6,$0C,$18,$18,$18,$0C,6,0
C42_43	DB	0,$66,$3C,$FF,$3C,$66,0,0,   0,$0C,$0C,$3F,$0C,$0C,0,0
C44_45	DB	0,0,0,0,0,$0C,$0C,6,   0,0,0,$3F,0,0,0,0
C46_47	DB	0,0,0,0,0,$0C,$0C,0,   $60,$30,$18,$0C,6,3,1,0
C48_49	DB	$3E,$63,$73,$7B,$6F,$67,$3E,0,   $0C,$0E,$0C,$0C,$0C,$0C,$3F,0
C50_51	DB	$1E,$33,$30,$1C,6,$33,$3F,0,    $1E,$33,$30,$1C,$30,$33,$1E,0
C52_53	DB	$38,$3C,$36,$33,$7F,$30,$78,0,  $3F,3,$1F,$30,$30,$33,$1E,0
C54_55	DB	$1C,6,3,$1F,$33,$33,$1E,0,    $3F,$33,$30,$18,$0C,$0C,$0C,0
C56_57	DB	$1E,$33,$33,$1E,$33,$33,$1E,0,  $1E,$33,$33,$3E,$30,$18,$0E,0
C58_59	DB	0,$0C,$0C,0,0,$0C,$0C,0,  0,$0C,$0C,0,0,$0C,$0C,6
C60_61	DB	$18,$0C,6,3,6,$0C,$18,0,  0,0,$3F,0,0,$3F,0,0
C62_63	DB	6,$C,$18,$30,$18,$0C,6,0,  $1E,$33,$30,$18,$0C,0,$0C,0 
C64_65	DB	$3E,$63,$7B,$7B,$7B,3,$1E,0,  $0C,$1E,$33,$33,$3F,$33,$33,0
C66_67	DB	$3F,$66,$66,$3E,$66,$66,$3F,0,  $3C,$66,3,3,3,$66,$3C,0
C68_69	DB	$1F,$36,$66,$66,$66,$36,$1F,0,  $7F,$46,$16,$1E,$16,$46,$7F,0
C70_71	DB	$7F,$46,$16,$1E,$16,6,$0F,0,	$3C,$66,3,3,$73,$66,$7C,0
C72_73	DB	$33,$33,$33,$3F,$33,$33,$33,0,  $1E,$C,$C,$C,$C,$C,$1E,0
C74_75	DB	$78,$30,$30,$30,$33,$33,$1E,0,  $67,$66,$36,$1E,$36,$66,$67,0
C76_77	DB	$F,6,6,6,$46,$66,$7F,0,  $63,$77,$7F,$7F,$6B,$63,$63,0
C78_79	DB	$63,$67,$6F,$7B,$73,$63,$63,0,  $1C,$36,$63,$63,$63,$36,$1C,0
C80_81	DB	$3F,$66,$66,$3E,6,6,$F,0,   $1E,$33,$33,$33,$3B,$1E,$38,0
C82_83	DB	$3F,$66,$66,$3E,$36,$66,$67,0,  $1E,$33,7,$E,$38,$33,$1E,0
C84_85	DB	$3F,$2D,$C,$C,$C,$C,$1E,0,  $33,$33,$33,$33,$33,$33,$3F,0
C86_87	DB	$33,$33,$33,$33,$33,$1E,$C,0,  $63,$63,$63,$68,$7F,$77,$63,0
C88_89	DB	$63,$63,$36,$1C,$1C,$36,$63,0,  $33,$33,$33,$1E,$C,$C,$1E,0
C90_91	DB	$7F,$63,$31,$18,$4C,$66,$7F,0, $1E,6,6,6,6,6,$1E,0
C92_93	DB	3,6,$C,$18,$30,$60,$40,0,    $1E,$18,$18,$18,$18,$18,$1E,0
C94_95	DB	8,$1C,$36,$63,0,0,0,0,      0,0,0,0,0,0,0,$FF
C96		DB	$C,$C,$18,0,0,0,0,0
KEYBCD	DB    $29,$16,$71,$26,$25,$2E,$3D,$52,$46,$45,$3E,$79,$41,$4E,$49,$4A,$70,$69,$72,$7A
KEYBCD2	DB    $6B,$73,$74,$6C,$75,$7D,$7C,$4C,$7E,$55,$E1,$78,$1E,$1C,$32,$21,$23,$24,$2B,$34
KEYBCD3	DB	$33,$43,$3B,$42,$4B,$3A,$31,$44,$4D,$15,$2D,$1B,$2C,$3C,$2A,$1D,$22,$35,$1A,$54,$5D,$53,$36,0

		ORG     	4096   ;Ram
TEXTBUF	DW	0
		ORG 		4608
XX		DB		5
YY		DB		4
CNT		DW    	7
AD1		DW		0
AD2		DW		0
BUF		DW		0
TITLE		TEXT		"Lion SYSTEM!"
TEND		DW		0
START:	MOVI		A0,8
		INT		4         ; Clear Screen Buffer
		MOVI		A1,1
		MOV.B		(XX),A1
		MOVI		A1,4
		MOV.B		(YY),A1
		MOV		A1,TITLE
		MOVI		A0,5      ; Print Title
		INT		4
		MOVI		A0,0
		MOV.B		(XX),A0
		MOVI		A0,14
		MOV.B		(YY),A0
L2:		MOV		A1,95      ; Print cursor
		MOVI		A0,4
		INT		4
		MOV		A1,32
		MOVI		A0,4
		INT		4
		MOVI		A0,0
		INT		4           ; Get keyboard code
		BTST		A0,1        ; if availiable
		JZ		L2
		CMP		A1,$66     ; BS ?
		JNZ		L1
		MOV.B		A1,(XX)
		CMP.B		A1,0
		JZ		L2
		DEC		A1
		MOV.B		(XX),A1
		MOV		A1,32
		MOVI		A0,4
		INT		4
		JMP		L2
L1:		CMP		A1,$5A     ; Enter?
		JZ		L3
		MOVI		A0,10      ; Convert to ASCII
		INT		4
		CMP		A1,0
		JZ		L2         ; Get another if not ASCII
		MOVI		A0,4
		INT		4          ; Put the character
		MOVI		A1,0
		MOV.B		A1,(XX)
		INC		A1
		MOV.B		(XX),A1
		CMP		A1,31      ; Change Line ?
		JLE		L2
L3:		MOVI		A1,0
		MOV.B		(XX),A1
		MOV.B		A1,(YY)
		INC		A1
		MOV.B		(YY),A1
		CMP		A1,31
		JLE		L2
		MOV		A1,31
		MOV.B		(YY),A1
		MOV		A0,6
		INT		4          ; Scroll 1 line
		MOVI		A0,7       
		INT		4          ;Refresh screen		
		JMP		L2

