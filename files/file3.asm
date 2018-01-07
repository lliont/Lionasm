; Test Program3

Data1		DB		1,2,3
Text1      TEXT      "Hello"
Data2		DB		1,2,3
		ORG 		128
NO		EQU		1234
		MOV 		A1,-1000
		NOP
		MOV  		A0,NO
Lab1:		MOV		(A0),A1   
		MOV  		A1,A0
		RETI
		NOT		A0
     		END

