        ORG     4096        ; RAM start

TEXTBUF	DS		680

XX		DB		5
YY		DB		4
CNT		DW    	7
AD1		DW		0
AD2		DW		0
BUF		DW		0
TITLE		TEXT		"Lion System!"
TEND		DW		0
START:	MOV		A0,80
		MOV		A1,-3
		MUL.B		A1,5
		ADD		A1,A0
	
		MOVI		A0,4
		INT		4
LAB1:		NOP
		JMP		LAB1
		
