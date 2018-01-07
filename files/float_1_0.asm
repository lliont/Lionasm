;  2015 Theodoulos Liontakis  - copy result to ram init

		ORG     	8192   ;Ram
		JMP		START
LLINE		DS		50
XX		DB		0
YY		DB		0
TITLE		TEXT		"Float Calc!"
		DB		0
START:	MOV		A2,$0E06
		MOV		A1,TITLE
		MOVI		A0,5      ; Print Title
		INT		4
		SETI		68
		MOV		A1,81	
		MOV		A2,60
		MOVI		A3,0
L6:		INC		A1
		NOT		A3
		MOV		B1,A3
		MOVI		A0,2
		INT		4
		JMPI		L6
		SETI		51
		MOV		A0,(LLINE)
L4:		MOV.B		(A0),32
		INC		A0
		JMPI		L4
		;PUSH		SR  ;  Trace on test
		;POP		A0
		;BSET		A0,5
		;PUSH		A0
		;POP		SR
		MOV		A2,$0019    ; Set X=0 Y=25
		MOV		(XX),A2
L2:		MOV		A2,(XX)
		MOV		A1,95      ; Print cursor
		MOVI		A0,4
		INT		4
		MOV		A1,32
		MOVI		A0,4
		INT		4
		MOVI		A0,0
		INT		4           ; Get keyboard code
		BTST		A0,1        ; if availiable
		JZ		L2
		CMP		A1,27        ; use ESC as backspase 
		JNZ		L1
		MOV.B		A1,(XX)
		JZ		L2
		DEC		A1
		MOV.B		(XX),A1
		MOV		A3,LLINE
		ADD		A3,A1
		MOV		A1,32
		MOV.B		(A3),A1
		MOVI		A0,4       ; clear previous char
		MOV		A2,(XX)
		INT		4
		JMP		L2
L1:		MOVI		A0,1
		INT		4
		CMP.B		A1,13      ; Enter?
		JZ		L3
		;MOVI		A0,10      ; Convert to ASCII if keyboard code
		;INT		4
		;CMP		A1,0
		;JZ		L2         ; Get another if not ASCII
		MOV		A3,LLINE
		ADD.B		A3,(XX)
		MOV.B		(A3),A1
		JSR		PCHI        ; Print and inc xx
		MOV.B		A1,(XX)
		CMP.B		A1,49      ; Change Line ?
		JBE		L2
L3:		JSR		CALC
		SETI		49
		MOV		A0,LLINE
L5:		MOV.B		(A0),32
		INC		A0
		JMPI		L5
		MOVI		A1,0
		MOV.B		(XX),A1
		MOV.B		A1,(YY)
		INC		A1
		MOV.B		(YY),A1
		CMP.B		A1,25
		JBE		L2
		MOV		A1,25
		MOV.B		(YY),A1
		MOVI		A1,0
		MOV.B		(XX),A1
		MOVI		A0,6
		INT		4          ; Scroll 1 line	
		JMP		L2

ER1		TEXT		" WHAT ?"
		DB		0
STRI		DW		0
NUM		DW		0
NUM1		DW		0
NUM2		DW		0

CALC:		MOVI		A0,0
		MOV		(STRI),A0
		JSR		GETNUM     ; Get first number
            MOV		A1,(NUM)
		MOV		(NUM1),A1
		CMP		B0,0
		JZ		ERR1
		JSR		ESP        ; eat spaces
		MOV		A0,LLINE	; Get operator
		ADD		A0,(STRI)
		MOV.B		A3,(A0)
		MOV		A0,(STRI)
		INC		A0
		MOV		(STRI),A0
		JSR		GETNUM     ; Get second number
		MOV		A0,(NUM)
		MOV		(NUM2),A0
		CMP		B0,0
		JZ		ERR1
		;MOV.B		A1,(OP)
		CMP.B		A3,43     ; is it a plus +
		JNZ		CL10
		JSR		PEQU
		JSR		ADDIT
		JMP		CL9
CL10:		CMP.B		A3,45		; is it a -
		JNZ		CL11
		JSR		PEQU
		JSR		SUBIT
		JMP		CL9
CL11:		CMP.B		A3,42     ; is it a plus *
		JNZ		CL12
		JSR		PEQU
		JSR		MULIT
		JMP		CL9
CL12:		CMP.B		A3,47		; is it a /
		JNZ		ERR1
		JSR		PEQU
		JSR		DIVIT
		PUSH		A0
		JSR		DISPL
		MOV		A1,32
		JSR		PCHI
		POP		A1
CL9:		JSR		DISPL
		RET
ERR1:		MOV		A2,(XX)
		MOV		A1,ER1
		MOVI		A0,5
		INT		4
		RET

;------ EAT SPACES	----
ESP:		PUSH		A0
ESP1:		MOV		A0,(STRI)
		ADD		A0,LLINE
		MOV.B		A0,(A0)
		CMP.B		A0,32
		JNZ		ESPE
		MOV		A0,(STRI)
		INC		A0
		MOV		(STRI),A0
		CMP		A0,32
		JBE  		ESP1
ESPE:		POP		A0
		RET

;---------- ADDITION ------------------------------

ADDIT:	MOV 		A1,(NUM1)
		ADD		A1,(NUM2)
		RET

;---------- SUBTRACTION ------------------------------

SUBIT:	MOV 		A1,(NUM1)
		SUB		A1,(NUM2)
		RET

;---------- MULTIPLICATION ------------------------------
MULIT:	MOV		A2,(NUM2)
		MOV		A1,(NUM1)
		MOVI		A0,8
		INT		4
		RET

;---------- DIVISION ------------------------------

DIVIT:	MOVI		A0,9
		MOV		A2,(NUM1)
		MOV		A1,(NUM2)
		INT		4
		RET

;---------  DISPLAY A CHAR AND INC XX -----
PCHI:		PUSH		A0
		PUSH		A2
		MOVI		A0,4
		MOV		A2,(XX)
		INT		4        
		ADD		A2,$0100
		MOV		(XX),A2
		POP		A2
		POP		A0
		RET

;-----------PRINT " = " -------------------------
PEQU:		PUSH		A1
		MOV		A1,32
		JSR		PCHI
		MOV		A1,61  ; =
		JSR		PCHI
		MOV		A1,32
		JSR		PCHI
		POP		A1
		RET

;---------  DISPLAY NUMBER -----
DISPL:	PUSH		B0
		BTST		A1,15
		JZ		DI0
		NOT		A1          ; Convert to positive 
		INC		A1
		MOV		B0,A1
		MOV		A1,45    ; print '-'
		JSR		PCHI
		MOV		A1,B0
DI0:		MOV		A3,10000
		MOV		A2,A1
DI1:		MOV		A1,A3
		MOV		A0,9
		INT		4
		ADD		A1,48
		JSR		PCHI
		CMP		A3,1
		JBE		DIEND
		MOV		B0,A0
		MOV		A1,10
		MOV		A2,A3
		MOV		A0,9
		INT		4
		MOV		A3,A1
		MOV		A2,B0
		JMP		DI1
DIEND:	POP		B0
		RET

; ------------ GET INTEGER ----------------------
GETNUM:	PUSHI
		JSR		ESP  ; eat spaces
		MOVI		B0,0    ; B0 will contain the num of digits
		MOV		A1,(STRI)
		ADD		A1,LLINE
`		MOVI		A0,0	
		MOV		B1,A0 ;save sign
		MOV.B		A0,(A1)
		CMP.B		A0,45  ; is it minus
		JNZ		CL2
		MOVI 		B1,1
		INC		A1
		MOV.B		A0,(A1)
CL2:		CMP.B		A0,47
		JBE		CL1
		CMP.B		A0,57
		JA		CL1
		SUB.B		A0,48  ; Convert digit to number
CL3:		PUSH		A0     ; First I push all digits to stack
		INC		B0
		CMP		B0,49
		JZ		CL1
		INC		A1
		MOV.B		A0,(A1)
		JMP		CL2
CL1:		CMP		B0,0
		JZ		CEND
		SUB		A1,LLINE
		MOV		(STRI),A1

		POP		A1             ; Get first digit
		MOV		A2,A1
		CMP		B0,1
		JZ		CL8
		DEC		B0
		MOV		A1,B0
		DEC		A1    ; to set correct idx
		SETI		A1
		MOVI		B0,0
CL4:		POP		A1       ; Get next digit
		PUSHI
		MOV		A0,B0
		SETI		A0
CL5:		MOV		A0,A1
		SLL		A1,3
		SLL		A0,1
		ADD		A1,A0  ;X10
		JMPI		CL5
		INC		B0
		ADD		A2,A1
		POPI
		JMPI		CL4
		INC 		B0
CL8:		CMP		B1,1
		JNZ		CEND
		NOT		A2
		INC		A2
CEND:		MOV		(NUM),A2
		POPI 			
		RET		
;-----------------------------------------------------

