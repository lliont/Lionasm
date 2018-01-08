	  	ORG 		0  ; Rom 
INT0_3      DW		0,0,0,0             
INT4        DW        	#0000000000100100     ;interrupt vector 4
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
PUTC:		PUSHI        ;  PRINT Character in A1 at XX,YY
		PUSH		A1
		MOV.B		A0,(YY)
		MOV		A1,A0
		MULU.B	A0,34
		MOVI		A1,0
		MOV.B		A1,(XX)
		ADD		A0,A1   ; 0-33
		ADD		A0,TEXTBUF
		POP		A1
		MOV.B		(A0),A1
		CMP.B		A1,96  
		JLE		LAB1
		SUB		A1,32
		CMP.B		A1,90
		JLE		LAB1
		ADD		A1,6
LAB1:		SUB		A1,32    
		MULU.B	A1,6
		ADD		A1,CTABLE
		MOV		(AD1),A1  ; save character table address
		MOVI		A0,0
		MOV.B		A0,(YY)
		MULU.B	A0,204
		MOVI		A1,0
          	MOV.B 	A1,(XX)
		ADD		A0,A1
		ADD		A0,61440 ; video base
		MOV		(AD2),A0  ; Addres at videoram
		SETI		5
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
		ADD		A0,34          ; next line
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
		CMP		A0,34
		JNZ		LAB3
		MOVI		A0,0
		MOV.B		(XX),A0
		MOVI		A1,0
		MOV.B		A1,(YY)
		INC		A1
		CMP		A1,20
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
		SETI		322
		MOV		A0,TEXTBUF
		MOV		A1,A0
		ADD		A1,34
LP5:		MOV		(A0),(A1)
		INC		A1
		INC		A1
		INC		A0
		INC		A0
		JMPI		LP5
		SETI		33
		MOV		A0,TEXTBUF
		ADD		A0,646
LP8:		MOV.B		(A0),32
		INC		A0
		JMPI		LP8
		POPI
		RETI 
REFRESH:	PUSHI                       ; Refresh Screen 
		SETI		679
		MOV		A1,(XX)
		PUSH		A1      ;save position
		MOVI		A1,0
		MOVI		A0,0
		MOV.B  	(XX),A1
		MOV.B		(YY),A1
LP6:		MULU.B	A0,34
		ADD		A0,A1
		ADD		A0,TEXTBUF
		MOV.B		A1,(A0)
		MOVI		A0,4
		INT		4		
		MOVI		A0,0
		MOV.B		A0,(YY)
		MOVI		A1,0
		MOV.B		A1,(XX)
		INC		A1
		CMP.B		A1,34
		JNZ		LP9
		MOVI		A1,0
		INC		A0
LP9:		MOV.B		(XX),A1
		MOV.B		(YY),A0		
		JMPI		LP6
		POP		A1
		MOV		(XX),A1  ; Restore pos
		POPI
		RETI
CLRSCR:	PUSHI		         ; Clear screen buffer
		SETI		679
		MOV		A0,TEXTBUF
LP7:		MOV.B		(A0),32
		INC		A0
		JMPI		LP7
		POPI
		RETI
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
		JLE		LP10
		ADD		A1,28
LP10:		POPI
INTEXIT:	RETI

CTABLE	DB	0,0,0,0,0,0,            $5c,0,0,0,0,0
C34_35	DB	6,0,6,0,0,0,            $28,$7c,$28,$7c,$28,0
C36_37	DB	$5C,$54,$FE,$54,$74,0,  $44,$20,$10,$08,$44,0
C38_39      DB    $28,$7c,$28,$7c,$28,0,  6,0,0,0,0,0
C40_41	DB	$38,$44,0,0,0,0,        $44,$38,0,0,0,0
C42_43	DB	2,7,2,0,0,0,            $10,$10,$7C,$10,$10,0
C44_45	DB	$C0,0,0,0,0,0,          $10,$10,$10,$10,$10,0
C46_47	DB	$40,0,0,0,0,0,          $60,$10,$0C,0,0,0
C48_49	DB	$7C,$64,$54,$4C,$7C,0,  0,$48,$7C,$40,0,0
C50_51	DB	$64,$54,$54,$54,$48,0,  $44,$54,$54,$54,$6c,0
C52_53	DB	$3C,$20,$70,$20,$20,0,  $5C,$54,$54,$54,$24,0
C54_55	DB	$7C,$54,$54,$54,$74,0,  4,4,$64,$14,$0C,0
C56_57	DB	$7C,$54,$54,$54,$7C,0,  $5C,$54,$54,$54,$7C,0
C58_59	DB	$44,0,0,0,0,0,          $C4,0,0,0,0,0
C60_61	DB	$10,$28,$44,0,0,0,      $28,$28,$28,$28,$28,0
C62_63	DB	$44,$28,$10,0,0,0,      $08,4,$54,8,0,0 
C64_65	DB	$7C,$44,$54,$54,$5C,0,  $7C,$24,$24,$24,$7C,0
C66_67	DB	$7C,$54,$54,$54,$6C,0,  $7C,$44,$44,$44,$44,0
C68_69	DB	$7C,$44,$44,$44,$38,0,  $7C,$54,$54,$54,$44,0
C70_71	DB	$7C,$14,$14,$14,$04,0,	$7C,$44,$44,$54,$74,0
C72_73	DB	$7C,$10,$10,$10,$7C,0,  $44,$44,$7C,$44,$44,0
C74_75	DB	$60,$40,$40,$44,$7C,0,  $7C,$10,$10,$28,$44,0
C76_77	DB	$7C,$40,$40,$40,$40,0,  $7C,$08,$10,$08,$7C,0
C78_79	DB	$7C,$08,$10,$20,$7C,0,  $38,$44,$44,$44,$38,0
C80_81	DB	$7C,$14,$14,$14,8,0,    $3C,$24,$64,$24,$3C,0
C82_83	DB	$7C,$14,$14,$14,$68,0,  $5C,$54,$54,$54,$74,0
C84_85	DB	$04,$04,$7C,$04,$04,0,  $7C,$40,$40,$40,$7C,0
C86_87	DB	$0C,$30,$40,$30,$0C,0,  $3C,$40,$30,$40,$3C,0
C88_89	DB	$44,$28,$10,$28,$44,0,  $0C,$10,$60,$10,$0C,0
C90_91	DB	$44,$64,$54,$4C,$44,0,  $7C,$44,0,0,0,0
C92_93	DB	$0C,$10,$60,0,0,0,      $44,$7C,0,0,0,0
C94_95	DB	0,2,1,2,0,0,            $40,$40,$40,$40,$40,$40
C96_123	DB	0,1,0,0,0,0,            0,16,$7C,$44,0,0
C124_125 	DB	$6C,0,0,0,0,0,          0,$44,$7C,$10,0,0
C126  	DB	2,1,2,1,0,0


KEYBCD	DB    $29,$16,$71,$26,$25,$2E,$3D,$52,$46,$45,$3E,$79,$41,$4E,$49,$4A,$70,$69,$72,$7A
		DB    $6B,$73,$74,$6C,$75,$7D,$7C,$4C,$7E,$55,$E1,$78,$1E,$1C,$32,$21,$23,$24,$2B,$34
		DB	$33,$43,$3B,$42,$4B,$3A,$31,$44,$4D,$15,$2D,$1B,$2C,$3C,$2A,$1D,$22,$35,$1A,$54
		DB	$5D,$58,$36,$3,$0B,$83,$0A,0

		ORG     	4096   ;Ram
TEXTBUF	DS		680
XX		DB		5
YY		DB		4
CNT		DW    	7
AD1		DW		0
AD2		DW		0
BUF		DW		0
TITLE		TEXT		"Lion System!"
TEND		DW		0
START:	MOVI		A0,8
		INT		4         ; Clear Screen Buffer
		MOVI		A1,10
		MOV.B		(XX),A1
		MOVI		A1,1
		MOV.B		(YY),A1
		MOV		A1,TITLE
		MOVI		A0,5      ; Print Title
		INT		4
		MOVI		A0,0
		MOV.B		(XX),A0
		MOVI		A0,6
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
		MOVI		A0,4       ; clear previous char
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
		CMP		A1,33      ; Change Line ?
		JLE		L2
L3:		MOVI		A1,0
		MOV.B		(XX),A1
		MOV.B		A1,(YY)
		INC		A1
		MOV.B		(YY),A1
		CMP		A1,19
		JLE		L2
		MOV		A1,19
		MOV.B		(YY),A1
		MOV		A0,6
		INT		4          ; Scroll 1 line
		MOVI		A0,7       
		INT		4          ;Refresh screen		
		JMP		L2

