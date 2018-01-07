		ORG 		0
INT0_3	DW		0,0,0,0
INT4       DW        #0000000000100100
		ORG     	32
		JMP		4096
INTR4:    	CMP		A0,0
		JZ		SERIN
SERIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,1  ;Result in A1, A0(1)=0 if not avail
		JZ		INTEXIT
		IN		A1,4
		MOVI		A2,0
		MOVI		A0,1
		OUT		2,A0
		OUT		2,A2
		JMP		INTEXIT
INTEXIT:	RETI

