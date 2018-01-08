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
		SLL		A1,4     ; * 16
		ADD		A0,A1
		ADD		A0,61440 ; video base
		MOV		(AD2),A0  ; Addres at videoram
		MOVI		A0,7
		MOV		(CNT),A0
		NOP
LP1:		MOV		A0,(CNT)
		DEC		A0
		MOV		(CNT),A0
		CMP		A0,1
		JNZ		LP1		
INTEXIT:	RETI

CTABLE	DB	0,0,0,0,0,0,0,0, $18,$3C,$3C,$18,$18,0,$18,0
C34_35	DB	$36,$36,$7F,$36,$7F,$36,$36,0,  $C,$3E,3,$1E,$30,$1F,$C,0

ORG     	4096   ;Ram
XX		DB		10
YY		DB		5
CNT		DW		7
AD1		DW		0
AD2		DW		0
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
		MOVI		A1,5
		MOV		(XX),A1
		MOVI		A1,10
		MOV		(YY),A1
		MOVI		A0,4
		MOV		A1,33
		INT		4
		JMP		LAB2

