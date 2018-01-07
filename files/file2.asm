; Test Program
Data1		DW		$3,#110110,50
NO		EQU		1234
		MOV 		A1,-1000
		NOP
		ORG 		128
		MOV  		A0,NO
Lab1:		MOV		(A0),A1   
		MOV  		A1,A0
		RETI
		NOT		A0
     		END

