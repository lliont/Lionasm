		MOV		A0,61440 ; Scroll screen 1 line
		MOV		A1,61696
		PUSHI
		SETI		1792
LP3:		MOV		(A0),(A1)
		INC		A0
		INC		A1
		JMPI		LP3
		SETI		256
		DEC		A1
LP4:		MOV		(A1),0
		DEC		A1
		JMPI		LP4
		POPI
