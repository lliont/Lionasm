	  	ORG 		0  ; Rom 
INT0_3     DW		0,0,0,0
INT4       DW        #0000000000100100
		ORG     	32
		JMP		START
INTR4:    	CMP		A0,0
		JZ		SERIN
		CMP		A0,1
		JZ		SEROUT
		CMP		A0,4
		JZ		PUTC
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
PUTC:		SUB		A1,32
		SLL		A1,3
		ADD		A1,CTABLE
		MOV		(AD1),A1  ; save character table address
		MOVI		A0,0
		MOV.B		A0,(YY)
		SLL		A0,8    ; 32 perline  * 8 lines per char
		MOVI		A1,0
          	MOV.B 	A1,(XX)
		SLL		A1,1     ; * 2
		ADD		A0,A1
		ADD		A0,61440 ; video base
		MOV		(AD2),A0  ; Addres at videoram
		PUSHI
		SETI		7
		MOV		A1,(AD1)
LP1:		MOV.B		A0,(A1)
		MOVI		A1,0
		BTST		A0,7
		BSET		A1,1
		JZ		LP2
		BSET		A1,0
LP2:		BTST		A0,6
		BSET		A1,3
		JZ		LP3
		BSET		A1,2
LP3:		BTST		A0,5
		BSET		A1,5
		JZ		LP4
		BSET		A1,4
LP4:		BTST		A0,4
		BSET		A1,7
		JZ		LP5
		BSET		A1,6
LP5:		BTST		A0,3
		BSET		A1,9
		JZ		LP6
		BSET		A1,8
LP6:		BTST		A0,2
		BSET		A1,11
		JZ		LP7
		BSET		A1,10
LP7:		BTST		A0,1
		BSET		A1,13
		JZ		LP8
		BSET		A1,12
LP8:		BTST		A0,0
		BSET		A1,15
		JZ		LP9
		BSET		A1,14
LP9:		MOV		A0,(AD2)
		MOV		(A0),A1
		MOV		A1,(AD1)
		INC		A1
		MOV		(AD1),A1
		MOV		A0,(AD2)
		ADD		A0,32          ; next line
		MOV		(AD2),A0  
		JMPI		LP1
		POPI		
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



ORG     	4096   ;Ram
XX		DB		5
YY		DB		4
CNT		DW    	7
AD1		DW		0
AD2		DW		0
BUF		DW		0
TITLE		TEXT		"LION SYSTEM "
START:	MOV 		A0,#1111000000000000
LAB1:		MOV 		(A0),#1111111101010101
		ADD		A0,2
		CMP		A0,61568
		JNZ		LAB1
LAB2:		MOVI		A0,0
		INT		4

		BTST		A0,1
		JZ		LAB2
		MOVI		A0,1
		INT		4

		SETI		11
		MOVI		A1,2
		MOV.B		(XX),A1
		MOVI		A1,5
		MOV.B		(YY),A1
		MOV		A0,TITLE
		MOV		(BUF),A0
LP:		MOVI		A1,0
		MOV.B		A1,(A0)
		INC		A0
		MOV		(BUF),A0
		MOVI		A0,4
		INT		4
		MOV		A0,(BUF)
		MOVI		A1,0
		MOV.B		A1,(XX)
		INC		A1
		MOV.B		(XX),A1
		JMPI		LP
		JMP		LAB2

