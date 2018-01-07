;*       Tiny Basic port for Lion cpu/System
;*
;*         ported by Theodoulos Liontakis 2016
;*
;*          from  michael sullivan's 8086 port of
;*                               
;*                   Li-Chen Wang's
;*
;*                   8080 tiny basic 
;*
;* @copyleft
;* all wrongs reserved
;*
		ORG     8192   ;Ram shared with rom routines
SDCBUF	DS	514
NUM1		DS	4
NUM2		DS	4
NUM3		DS	4
COUNTER	DS	2 ; Counter for general use increased by hardware int 0 


START:	CLI
		SETI	11364
		MOV	A1,TXTBGN	
MEMCLR:	MOV	(A1),0
		INC	A1
		INC	A1
		JMPI	MEMCLR
		MOV	A1,STACK 
		SETSP	A1
		STI
		SETI		24 
		MOV		A1,65144
COLINIT:	MOV.B		(A1),68
		INC		A1
		JMPI		COLINIT
		MOV.B	(A1),45  ; Set line 26 color
		MOV	(XX),$0019 ; Set INITIAL POS 
		MOV	A3,TITLE
		MOVI	A2,0
		MOVI	A0,0
		JSR	PRTSTG
		MOV	A3,TXTBGN
		MOV	A4,A3
		MOV	(TXTUNF),A3

RSTART:	MOV	A0,STACK
		SETSP	A0
		MOVI	A1,0
		MOV	(LOPVAR),A1
		MOV	(STKGOS),A1
		MOV	(CURRNT),A1
		MOV.B	(BUF_CNT),A1
		JSR	CRLF
		MOV   A3,OK 
		MOVI	A0,0
		JSR	prtstg
ST3:
		MOV	(XX),$0019
		MOVHL	A0,0
		MOV.B	A0,'>'
		JSR	GETLN
		PUSH	A4         ; A4 end of text in buffer
		MOV 	A3,BUFFER
		JSR	TSTNUM
		MOVHL	A0,0
		JSR	IGNBLNK
		OR	A1,A1      ; A1 num 
		POP	A2
		JZ	DIRECT
		DEC	A3
		DEC	A3
		MOV	A0,A1
		MOV	A4,A3
		JSR	STOSW  ; store lineno to 
		PUSH	A2
		PUSH  A3
		MOV	A0,A2
		SUB	A0,A3
		PUSH	A0
		JSR	FNDLN
		PUSH	A3
		JNZ	ST4
		PUSH	A3
		JSR	FNDNXT

		POP	A2
		MOV	A1,(TXTUNF)
		JSR	MVUP
		MOV	A1,A2
		MOV	(TXTUNF),A1
ST4:		
		POP	A2
		MOV	A1,(TXTUNF)

		POP	A0
		PUSH	A1
		CMP.B	A0,3
		JZ	RSTART
		ADD	A0,A1
		MOV	A1,A0	
		MOV	A3,TXTEND
		CMP	A1,A3
		JNC	QSORRY
		MOV	(TXTUNF),A1
		POP	A3
		JSR	MVDOWN
		POP	A3
		POP	A1
		JSR	MVUP
		JMP	ST3

TSTV:		
		MOVHL	A0,64
		JSR	IGNBLNK
		JC	RET01
TSTV1:	
		JNZ	TV1
		JSR	PARN
		ADD	A1,A1
		JC	QHOW
		PUSH	A3
		XCHG	A1,A3
		JSR	SIZE
		CMP	A1,A3
		JC	ASORRY
		MOV 	A1,TXTEND
		SUB	A1,A3
		POP	A3
RET01:	
		RET

TV1:		CMP.B	A0,'Z'  ; TEST VARIABLE
		JA	RET22
		CMP.B	A0,'A'
		JC	RET2
		INC	A3
TV1A:	
		MOV	A1,VARBGN
		SUB.B	A0,65
		AND	A0,$00FF
		SLA	A0,1
		ADD	A1,A0
RET2:		
		RET	
RET22:	
		CMP.B	A0,255
		RET

;----- TSTNUM

TSTNUM:
		MOVI	A1,0
		MOVHL	A2,A1
		MOVHL	A0,0
		JSR	IGNBLNK
TN1:
		CMP.B	A0,'0'
		JC	RET2
		CMP.B A0,':'
		JNC	RET2
		MOV.B	A0,$F0
		SWAP	A1
		AND.B	A0,A1
		SWAP	A1
		JNZ	QHOW
		ADD	A2,$0100
		PUSH	A2
		MOVI	A2,10
		MOV	A0,8   ; MULU.B A0,A2 
		INT	4      ; Multiplcation A1*A2 res in A1
		MOVI	A0,0
		MOV	A4,A3
		JSR	LODSB
		SUB.B	A0,'0'
		MOVHL	A0,0
		ADD	A1,A0
		POP	A2
		JSR	LODSB
		PUSH	SR
		INC	A3
		POP	SR
		JP	TN1
QHOW:
		PUSH	A3
AHOW:	
		MOV	A3,HOW
		JMP	ERROR

;--------  tables ----
tab1:	
	TEXT	"LIS"
	DB	'T'+128
	DA	LIST
	TEXT	"NE"
	DB	'W'+128
	DA	NEW
	TEXT	"RU"
	DB	'N'+128
	DA	RUN
	TEXT	"BY"
	DB	'E'+128
	DA	BYE
	TEXT	"SLIS"
	DB	'T'+128
	DA	SLIST
TAB2	TEXT	"NEX"
	DB	'T'+128
	DA	NEXT
	TEXT	"LE"
	DB	'T'+128
	DA	LET
	TEXT	"OU"
	DB	'T'+128
	DA	OUTCMD
	TEXT	"I"
	DB	'F'+128
	DA	IFF
	TEXT	"GOT"
	DB	'O'+128
	DA	GOTO
	TEXT	"GOSU"
	DB	'B'+128
	DA	GOSUB
	TEXT	"RETUR"
	DB	'N'+128
	DA	RETURN
	TEXT	"RE"
	DB	'M'+128
	DA	REM
	TEXT	"FO"
	DB	'R'+128
	DA	FOR
	TEXT "FIN"
	DB	'D'+128
	DA	FIND
	TEXT	"INPU"
	DB	'T'+128
	DA	INPUT
	TEXT	"PRIN"
	DB	'T'+128
	DA	PRINT
	TEXT	"POK"
	DB	'E'+128
	DA	POKE
	TEXT	"STO"
	DB	'P'+128
	DA	STOP
	TEXT	"COLO"
	DB	'R'+128
	DA	COLOR
	TEXT	"BEE"
	DB	'P'+128
	DA	BEEP
	TEXT	"CL"
	DB	'S'+128
	DA	CLS
	TEXT	"PO"
	DB	'S'+128
	DA	ATCMD
	TEXT	"PLO"
	DB	'T'+128
	DA	PLOT
	DB	'?'+128
	DA	PRINT
	DB 	128
	DA	DEFLT

TAB4	TEXT	"RN"
	DB	'D'+128
	DA	RND
	TEXT	"IN"
	DB	'P'+128
	DA	INP
	TEXT	"PEE"
	DB	'K'+128
	DA	PEEK
	TEXT	"US"
	DB	'R'+128
	DA	USR
	TEXT	"AB"
	DB	'S'+128
	DA	MYABS
	TEXT	"FRE"
	DB	'E'+128
	DA	SIZE
	TEXT	"WAIT"
	DB	'K'+128
	DA	WAITK
	TEXT	"SDINI"
	DB	'T'+128
	DA	SDINIT
	TEXT	"SREA"
	DB	'D'+128
	DA	SDREAD
	TEXT	"SWRIT"
	DB	'E'+128
	DA	SWRITE
	DB	128
	DA	XP40

TAB5	DB	'T', 'O'+128
	DA	FR1
	DB	128
	DA	QWHAT

TAB6	TEXT	"STE"
	DB	'P'+128
	DA	FR2
	DB	128
	DA	FR3
TAB8	DB	'>'
	DB 	'='+128
	DA	XP11
	DB	'#'+128
	DA	XP12
	DB	'>'+128
	DA	XP13
	DB	'='+128
	DA	XP15
	DB	'<'
	DB	'='+128
	DA	XP14
	DB	'<'+128
	DA	XP16
	DB	128	
	DA	XP17



DIRECT:
	MOV	A1,TAB1
	DEC	A1
EXEC:	
	MOVHL	A0,0
	JSR	IGNBLNK
	PUSH	A3
	MOV	A4,A3
EX1:
	JSR	LODSB
	INC	A3
	CMP.B	A0,'.'   
	JZ	EX4
	INC	A1
	MOVHL	A0,(A1)
	AND	A0,$7FFF
	CMPHL	A0
	JZ	EX2
EX0A:
	CMP.B	(A1),128
	JNC	EX0B
	INC	A1
	JMP	EX0A
EX0B:
	ADD	A1,3
	BTST	A1,0
	JZ	ALI2
	INC	A1
ALI2: CMP.B (A1),128
	JZ	EX3A
	DEC	A1
	POP	A3
	JMP	EXEC
EX4:
	INC	A1
	CMP.B	(A1),128
	JC	EX4
	JMP	EX3
EX3A:
	POP	A4
	PUSH	A4
	JMP	EX3
EX2:
	CMP.B	(A1),128
	JC	EX1
EX3:
	INC	A1
	BTST	A1,0   ; ALIGN TO EVEN ADDRESS
	JZ	ALIG
	INC	A1
ALIG:	POP	A0
	MOV	A3,A4	
	JMP 	(A1)
;--------------------

NEW:
	MOV (TXTUNF),TXTBGN
	MOV	A1,TXTBGN
	MOV	A0,TXTEND
	SUB	A0,A1
	SRL	A0,1
	INC	A0
	SETI	A0
	MOV	A0,TXTBGN
	DEC	A0
	DEC	A0
ERS:	MOV	(A0),0
	INC	A0
	INC	A0
	JMPI	ERS
	JMP	START

STOP:
	JSR	ENDCHK
	JMP	RSTART

RUN:
	JSR	ENDCHK
	MOV	A3,TXTBGN

RUNNXL:
	MOVI	A1,0
	JSR	FNDLNP
	JNC	RUNTSL
	JMP	RSTART

RUNTSL:
	XCHG	A1,A3
	MOV	(CURRNT),A1
	XCHG	A1,A3
	INC	A3
	INC	A3
RUNSML:
	JSR	CHKIO
	MOV	A1,TAB2
	DEC	A1
	JMP	EXEC

GOTO:
	JSR	EXP
	PUSH	A3
	JSR	ENDCHK
	JSR	FNDLN
	JZ	GT1
	JMP	AHOW
GT1:	POP	A0
	JMP	RUNTSL

BYE:
	JMP START

; ----------- LIST 
SLIST:
	MOV.B	(SER),1  ; REDIRECT TO SERIAL PORT

LIST:
	JSR	TSTNUM
	JSR	ENDCHK
	JSR	FNDLN
LS1:
	JNC	LS2
	MOV.B	(SER),0
	JMP	RSTART
LS2:
	JSR	PRTLN
	JSR	CHKIO
	JSR	FNDLNP
	JMP	LS1

FIND:
	JSR	TSTNUM
	JSR	ENDCHK
	JSR	FNDLN
	JC	RSTART
	JSR	PRTLN
	JMP	ST3


PRINT:
	MOVI.B A2,6
	MOVHL	A0,59
	JSR	IGNBLNK
	JNZ	PR2
	JSR	CRLF
	JMP	RUNSML
PR2:
	MOVHL	A0,13
	JSR	IGNBLNK
	JNZ	PR0
	JSR	CRLF
	JMP	RUNNXL
PR0:	
	MOVHL	A0,'#'
	JSR	IGNBLNK
	JNZ	PR1
	JSR	EXP
	MOV.B	A2,A1
	JMP	PR3
PR1:
	JSR	QTSTG
	JMP	PR8
PR3:
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	PR6
	JSR	FIN
	JMP	PR0
PR6:
	MOVHL	A0,'\'
	JSR	IGNBLNK
	JZ	FINISH
	JSR	CRLF
	JMP	FINISH
PR8:
	JSR	EXP
	PUSH	A2
	MOV	A2,3
	JSR	PRTNUM
	POP	A2
	JMP	PR3

;--------------  GOSUB

GOSUB:
	JSR	PUSHA
	JSR	EXP
	PUSH	A3
	JSR	FNDLN
	JNZ	AHOW
	MOV	A1,(CURRNT)
	PUSH	A1
	MOV	A1,(STKGOS)
	PUSH	A1
	MOVI	A1,0
	MOV	(LOPVAR),A1
	GETSP	A0
	ADD	A1,A0
	MOV	(STKGOS),A1
	JMP	RUNTSL
RETURN:
	JSR	ENDCHK
	MOV	A1,(STKGOS)
	OR	A1,A1
	JZ	QWHAT
	SETSP	A1
	POP	A1
	MOV	(STKGOS),A1
	POP	A1
	MOV	(CURRNT),A1
	POP	A3
	JSR	POPA
	JMP 	FINISH

; ----------for

FOR:	JSR	PUSHA
	JSR	SETVAL
	DEC	A1
	MOV	(LOPVAR),A1
	MOV	A1,TAB5
	DEC	A1
	JMP	EXEC
FR1:
	JSR	EXP
	MOV	(LOPLMT),A1
	MOV	A1,TAB6
	DEC	A1
	JMP	EXEC
FR2:
	JSR	EXP
	JMP	FR4
FR3:
	MOVI	A1,1
FR4:
	MOV	(LOPINC),A1
FR5:
	MOV	A1,(CURRNT)
	MOV	(LOPLN),A1
	XCHG	A1,A3
	MOV	(LOPPT),A1
	MOVI	A2,10
	MOV	A1,(LOPVAR)
	XCHG	A3,A1
	MOV	A1,A2
	GETSP	A0
	ADD	A1,A0
	JMP	FR7A
FR7:
	ADD	A1,A2
FR7A:
	MOVHL	A0,(A1)
	INC	A1
	MOV.B	A0,(A1)
	DEC	A1
	OR	A0,A0
	JZ	FR8
	CMP	A0,A3
	JNZ	FR7
	XCHG	A3,A1
	MOVI	A1,0
	GETSP	A0
	ADD	A1,A0
	MOV	A2,A1
	MOVI	A1,10
	ADD	A1,A3
	JSR	MVDOWN
	SETSP	A1
FR8:
	MOV	A1,(LOPPT)
	XCHG	A1,A3
	JMP 	FINISH
NEXT:
	JSR	TSTV
	JC	QWHAT
	MOV	(VARNXT),A1
NX0:
	PUSH	A3
	XCHG	A3,A1
	MOV	A1,(LOPVAR)
	MOVLH	A0,A1
	OR.B	A0,A1
	JZ	AWHAT
	CMP	A3,A1
	JZ	NX3
	POP	A3
	JSR	POPA
	MOV	A1,(VARNXT)
	JMP	NX0
NX3:
	MOVHL	A3,(A1)
	INC	A1
	MOV.B	A3,(A1)
	MOV	A1,(LOPINC)
	PUSH	A1
	ADD	A1,A3
	XCHG	A3,A1
	MOV	A1,(LOPVAR)
	SWAP	A3
	MOV.B	(A1),A3
	INC	A1
	SWAP 	A3
	MOV.B	(A1),A3
	MOV	A1,(LOPLMT)
	POP	A0
	SWAP	A0
	OR 	A0,A0
	JP	NX1
	XCHG	A1,A3
NX1:
	JSR	CKHLDE
	POP	A3
	JC	NX2
	MOV	A1,(LOPLN)
	MOV	(CURRNT),A1
	MOV	A1,(LOPPT)
	XCHG	A3,A1
	JMP 	FINISH
NX2:
	JSR	POPA
	JMP 	FINISH	

; ------------ EXPRES

SIZE:
	MOV	A1,(TXTUNF)
	PUSH	A3
	XCHG	A1,A3
SIZEA:
	MOV	A1,TXTEND  ;VARBGN
	SUB	A1,A3
	POP	A3
RET10:
	RET

; ------------ DIVIDE

DIVIDE:  ; INT 4/9 Div A2 by A1 res in A1,A0
	PUSH	A3
	PUSH	A1
	MOV	A1,A3
	POP	A2
	MOVI	A0,9
	INT	4
	MOV	A2,A1
	MOV	A1,A0
	MOV	A0,A2
	POP	A3
	RET
	
CHKSGN:
	OR	A1,A1
	JP	RET11
CHGSGN:
	NOT	A1
	INC	A1
	XOR	A2,$8000
RET11:
	RET

CKHLDE:
	MOVLH	A0,A1
	SWAP	A3
	XOR.B	A0,A3
	SWAP	A3
	JP	CK1
	PUSH	A3
	MOV	A3,A1
	POP	A1
CK1:
	CMP	A1,A3
	RET

;---- GETVAL FIN

SETVAL:
	JSR	TSTV
	JC	QWHAT
	PUSH	A1
	MOVHL	A0,'='
	JSR	IGNBLNK
	JNZ	QWHAT
	JSR	EXP
	MOV	A2,A1
	POP	A1
	SWAP	A2
	MOV.B	(A1),A2
	INC	A1
	SWAP	A2
	MOV.B	(A1),A2
	RET

FIN:
	MOVHL	A0,59
	JSR	IGNBLNK
	JNZ	FI1
	POP	A0
	JMP	RUNSML
FI1:
	MOVHL	A0,13
	JSR	IGNBLNK
	JNZ	FI2
	POP	A0
	JMP	RUNNXL
FI2:
	RET

ENDCHK:
	MOVHL	A0,13
	JSR	IGNBLNK
	JZ	FI2
QWHAT:
	PUSH	A3
AWHAT:
	MOV	A3,WHAT
ERROR:
	SUB.B	A0,A0
	JSR	PRTSTG
	POP	A3
	MOV	A1,(CURRNT)
	CMP	A1,0
	JZ	RSTART
	JN	INPERR
	MOV	A4,A1
	JSR	LODSW
	JSR	FNDLN
	MOV	A3,A1
	JSR	PRTLN
	POP	A2
ERR2:
	JMP	RSTART
QSORRY:
	PUSH	A3
ASORRY:
	MOV	A3,SORRY
	JMP	ERROR
;-----

REM:
	MOVI	A1,0
	JMP	IFF1A

IFF:
	JSR	EXP
IFF1A:
	CMP	A1,0
	JNZ	RUNSML
	JSR	FNDSKP
	JNC	RUNTSL
	JMP	RSTART

INPERR:
	MOV	A1,(STKINP)
	CLI
	SETSP	A1
	STI
	POP	A1
	MOV	(CURRNT),A1
	POP	A3
	POP	A3

INPUT:

	PUSH	A3
	JSR	QTSTG
	JMP	IP2
	JSR	TSTV
	JC	IP4
	JMP	IP3
IP2:
	PUSH	A3
	JSR	TSTV
	JC	QWHAT
	MOV	A4,A3
	JSR	LODSB
	MOV.B	A2,A0
	SUB.B	A0,A0
	MOV	A4,A3
	JSR	STOSB
	POP	A3
	JSR	PRTSTG
	MOV.B	A0,A2
	DEC	A3
	MOV	A4,A3
	JSR	STOSB
IP3:
	PUSH	A3
	XCHG	A1,A3
	MOV	A1,(CURRNT)
	PUSH	A1
	;MOV	A1,-999; 
	MOV	(CURRNT),-999
	GETSP	A0
	MOV	(STKINP),A0
	PUSH	A3
	MOV.B	A0,':'
	JSR	GETLN
IP3A:
	MOV	A3,BUFFER
	JSR	EXP
	NOP              ;jsr	endchk
	NOP
	NOP
	POP	A3
	XCHG	A1,A3
	SWAP	A3
	MOV.B	(A1),A3
	SWAP	A3
	INC	A1
	MOV.B	(A1),A3
	POP	A1
	MOV	(CURRNT),A1
	POP	A3
IP4:
	POP	A0
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	FINISH
	JMP	INPUT
	

DEFLT:
	MOV	A4,A3
	JSR	LODSB
	CMP.B	A0,13
	JZ	FINISH
LET:
	JSR	SETVAL
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	FINISH
	JMP	LET

;-----
EXP:	JSR	EXPR2
	PUSH	A1
EXPR1:
	MOV	A1,TAB8
	DEC	A1
	JMP 	EXEC
XP11:
	JSR	XP18
	JC	RET4
	MOV.B	A1,A0
	RET
XP12:
	JSR	XP18
	JZ	RET4
	MOV.B	A1,A0
RET4:
	RET
XP13:
	JSR	XP18
	JBE	RET5
	MOV.B	A1,A0
RET5:
	RET
XP14:
	JSR	XP18
	MOV.B	A1,A0
	JBE	RET6
	MOVLH	A1,A1
RET6:
	RET
XP15:
	JSR	XP18
	JNZ	RET7
	MOV.B A1,A0
RET7:
	RET
XP16:
	JSR	XP18
	JNC	RET8
	MOV.B	A1,A0
RET8:
	RET
XP17:
	POP	A1
	RET
XP18:
	MOV.B	A0,A2
	POP	A1
	POP	A2
	PUSH	A1
	PUSH	A2
	MOV.B	A2,A0
	JSR	EXPR2
	XCHG	A1,A3
	POP	A0
	PUSH	A1
	MOV	A1,A0
	JSR	CKHLDE
	POP	A3
	MOVI	A1,0
	MOVI.B A0,1
	RET

EXPR2:
	MOVHL	A0,'-'
	JSR	IGNBLNK
	JNZ	XP21
	MOVI	A1,0
	JMP	XP26
XP21:
	MOVHL	A0,'+'
	JSR	IGNBLNK
XP22:
	JSR	EXPR3
XP23:
	MOVHL	A0,'+'
	JSR	IGNBLNK
	JNZ	XP25
	PUSH	A1
	JSR	EXPR3
XP24:
	XCHG	A1,A3
	POP	A0
	PUSH	A1
	MOV	A1,A0
	ADD	A1,A3
	POP	A3
	JO	QHOW
	JMP	XP23
XP25:
	MOVHL	A0,'-'
	JSR	IGNBLNK
	JNZ	RET9
XP26:
	PUSH	A1
	JSR	EXPR3
	JSR	CHGSGN
	JMP	XP24

EXPR3:
	JSR	EXPR4
XP31:
	MOVHL	A0,'*'
	JSR	IGNBLNK
	JNZ	XP34
	PUSH	A1
	JSR	EXPR4
	XCHG	A1,A3
	POP	A0
	PUSH	A1
	;MUL.B A0,A3 ; ****************
	PUSH	A0
	PUSH	A2
	MOV	A1,A3
	MOV	A2,A0
	MOV	A0,8   ;
	INT	4      ; Multiplcation A1*A2 res in A1
	CMP	A0,0   ; check overflow
	POP	A2
	POP	A0
	JNZ	AHOW
	;JO	AHOW
	JMP	XP35
XP34:
	MOVHL	A0,'/'
	JSR	IGNBLNK
	SETI	A0
	JZ	DIV1
	MOVHL	A0,'%'
	JSR	IGNBLNK
	JNZ	RET9
DIV1: PUSH	A1
	JSR	EXPR4
	XCHG	A1,A3
	POP	A0
	PUSH	A1
	MOV	A1,A0
	OR	A3,A3
	JZ	AHOW
	JSR	DIVIDE
	MOVIDX A0
	CMP.B	A0,'%'
	JZ	DIV2
	MOV	A1,A2
DIV2:	MOVI	A2,6
XP35:
	POP	A3
	JMP	XP31

EXPR4:
	MOV	A1,TAB4
	DEC	A1
	JMP	EXEC
XP40:   		
	JSR	TSTV  ; VARIABLE ?
	JC	XP41
	MOVHL A0,(A1)
	INC	A1
	MOV.B	A0,(A1)
	MOV	A1,A0
RET9:
	RET
XP41:	
	JSR	TSTNUM	; NUMBER ?
	MOVLH A0,A2
	OR.B	A0,A0
	JNZ	XP42
PARN:
	MOVHL	A0,'('
	JSR	IGNBLNK
	JNZ	PARN1
	JSR	EXP
PARN1:
	MOVHL	A0,')'
	JSR	IGNBLNK
	JNZ	XP43
XP42:
	RET
XP43:
	JMP	QWHAT

	
MYABS:
	JSR	PARN
	JSR	CHKSGN
	OR	A0,A1
	JP	RET10
	JMP	QHOW

;-----  OUT POKE

CLS:	
	MOVI	A0,3
	INT	4
	JMP	FINISH

ATCMD:
	JSR	EXP
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	QWHAT
	PUSH	A1
	JSR	EXP
	MOV.B	A0,A1
	POP	A1
	MOV.B	(XX),A0 
	MOV.B	(YY),A1		
	JMP 	FINISH


COLOR:
	JSR	EXP
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	QWHAT
	PUSH	A1
	JSR	EXP
	MOV.B	A0,A1
	POP	A1
	ADD	A1,65144
	MOV.B	(A1),A0
	JMP 	FINISH

PLOT:
	JSR	EXP
	CMP	A1,299
	JBE	PLT3
	MOV	A1,299
PLT3:	PUSH 	A2
	PUSH	A4
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	QWHAT
	PUSH	A1
	JSR	EXP
	CMP	A1,207
	JBE	PLT2
	MOV	A1,207
PLT2:	PUSH	A1
	MOVHL	A0,44
	MOVI	A4,1
	JSR	IGNBLNK
	JNZ	PLT1
	JSR	EXP
	MOV	A4,A1
PLT1:	POP	A2
	POP	A1
	MOVI	A0,2
	INT	4
	POP	A4
	POP	A2
	JMP 	FINISH

BEEP:
	JSR	EXP
	OUT	8,A1
	JMP 	FINISH

POKE:
	JSR	EXP
	PUSH	A1
	MOVHL	A0,44
	JSR	IGNBLNK
	JZ	POK1
	JMP	QWHAT
POK1:
	JSR	EXP
	MOV.B	A0,A1
	POP	A1
	MOV.B	(A1),A0
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	FINISH
	JMP	POKE

PEEK:
	JSR	PARN
	MOV.B	A1,(A1)
	MOVHL	A1,0
	RET

RND:	JSR	PARN
	OR	A1,A1
	JN	QHOW
	JNZ	RND1
	MOVI	A1,0
	;IN  	A1,12
	MOV	A1,(COUNTER)
	BCLR	A1,15
	MOV	(RAND),A1
	RET
RND1:	
	PUSH	A2
	PUSH	A1
	MOV	A1,(RAND)
	MOV	A2,67
	MOVI  A0,8
	INT	4
	ADD	A1,101
	MOV	(RAND),A1
	MOV	A2,A1
	POP	A1
	INC	A1
	MOVI	A0,9
	INT	4
	POP	A2
	MOV	A1,A0
	RET

WAITK:
	MOVI	A0,0
	INT	4           ; Get keyboard code
	BTST	A0,1        ; if availiable
	JNZ	WK1
	MOVI	A0,7
	INT	4
	BTST	A0,2
	JZ	WAITK
	MOVI	A0,10
	INT	4
WK1:
	RET	


SDINIT:
	MOV	A0,11
	INT	4
	MOV	A1,A0
	RET

SDREAD:
	JSR	PARN
	MOV	A0,13
	INT	4
	MOV	A1,A0
	RET

SWRITE:
	JSR	PARN
	MOV	A0,14
	INT	4
	MOV	A1,A0
	RET

;----- GETLN

GETLN:
		jsr	chrout
		push	a1
		mov	a4,BUFFER  ; a4<->di
GL1:
		MOVI	A0,0
		INT	4           ; Get keyboard code fro serial port
		BTST	A0,1        ; if availiable
		JNZ	KEYIN
		MOVI	A0,7
		INT	4
		BTST	A0,2
		JZ	GL1
		MOVI	A0,10
		INT	4
KEYIN:
		MOV	A0,A1      ; CHAR IN A0
		CMP.B	A0,97
		JC	SKP2
		CMP.B	A0,122
		JA	SKP2
		AND.B	A0,$DF        ; UPPER CASE 
SKP2:	      CMP.B A0,8       ; BS
		JNZ   gl2
		CMP	A4,BUFFER
		JBE	gl1
		DEC	A4
		PUSH	A2
		MOV	A2,(XX)
		SUB	A2,$0100
		MOV	(XX),A2
		MOVI	A0,4
		MOV	A1,32
		INT	4
		POP	A2
		JMP	gl1
gl2:		JSR	STOSB
		CMP.B A0,13
		JZ    gl1e
		CMP	A4,BUFEND
		JZ	gl3
		JSR	CHROUT
		JMP	GL1
gl3:		
		DEC	A4
		JMP	GL1
GL1E:		
		JSR	CHROUT
		MOV	A1,A4
		SUB	A1,BUFFER
		DEC	A1
		MOV.B	(BUF_CNT),A1
		POP	A1
		MOV	A3,A4
		RET
		
FNDLN:	
		OR	A1,A1
		JN	QHOW
		MOV	A3,TXTBGN
FNDLNP:
FL1:		
		MOV	A0,(TXTUNF)
		DEC	A0
		CMP	A0,A3
		JC	RET13
		MOV	A4,A3
		JSR	LODSW
		CMP	A0,A1
		JC	FNDNXT
RET13:
		RET

FNDNXT:	
		INC	A3
FL2:
		INC	A3
	
FNDSKP:
		MOV	A4,A3
		JSR	LODSB
		CMP.B	A0,13
		JNZ	FL2
		INC	A3
		JMP	FL1


; ----  CHROUT
CRLF:
		MOVI	A0,$0D
CHROUT:	
		CMP.B	(OCSW),0
		JZ	COUT1
		PUSH	A0
		CMP.B	A0,$0D
		JZ	CR_SCRL
		PUSH	A1
		PUSH 	A2
		MOV	A1,A0
		MOV	A2,(XX)
		MOV	A0,4
		CMP.B	(SER),1   ; REDIRECT TO SERIAL ?
		JNZ	NRMI
		MOVI	A0,1
		SETI	10000    ;  DELAY FOR SERIAL TRANSMIT
DLY:		NOP
		JMPI	DLY
NRMI:		INT	4
		;ADD	A2,$0100
		SWAP	A2
		CMP.B	A2,48
		JBE	SKP4
		JSR 	CRLF
		MOV	A2,-1	
SKP4:		INC.B	A2
		MOV.B	(XX),A2
		SWAP	A2
		POP	A2
		POP	A1
		POP	A0
		RET

CR_SCRL:	PUSH	A1
		MOV	a0,6
		CMP.B	(SER),1
		JNZ	NRMI2
		SETI	10000    ;  DELAY FOR SERIAL TRANSMIT
DLY3:		NOP
		JMPI	DLY3
		MOVI	A1,13
		MOVI	A0,1
NRMI2:
		INT	4
		CMP.B	(SER),1
		JNZ	SKP3
		SETI	10000    ;  DELAY FOR SERIAL TRANSMIT
DLY2:		NOP
		JMPI	DLY2
		MOVI	A0,1
		MOVI	A1,10
		INT	4
SKP3:		MOV.B	(XX),0
		POP	A1
		POP	A0
		RET
COUT1:	
		cmp.b	a0,0
		jz	ret16
		JSR   STOSB
		PUSH	A0
		mov.b	a0,(BUF_CNT)
		inc.b	a0
		mov.B	(BUF_CNT),a0
		POP	A0
ret16:
		RET

CHKIO:
	PUSH	A2
	PUSH	A3
	PUSH	A1
	MOVI	A0,0
	INT	4           ; Get keyboard code
	BTST	A0,1        ; if availiable
	JNZ	CI1
	MOV	A0,7
	INT	4
	BTST	A0,2
	JZ	IDONE
	MOV	A0,10
	INT	4
CI1:	
	MOV	A0,A1
	CMP.B	A0,27
	JNZ	IDONE
	JMP	RSTART
IDONE:
	POP	A1
	POP	A3
	POP	A2
	RET

PRTSTG:     
	MOVHL	A2,A0
PS1:
	MOV	A4,A3
	JSR	LODSB
	PUSH	SR
	INC	A3
	POP	SR
	SWAP	A2
	CMP.B	A0,A2
	SWAP	A2
	JNZ	PS2
	RET
PS2:
	JSR	CHROUT
	CMP.B	A0,13
	JNZ	PS1
	RET	

QTSTG:
	MOVHL	A0,34
	JSR	IGNBLNK
	JNZ	QT3
	MOV.B	A0,34
QT1:
	JSR	PRTSTG
	CMP.B	A0,13
	POP	A1
	JNZ	QT2
	JMP	RUNNXL
QT2:
	ADD	A1,4
	JMP	A1
QT3:
	MOVHL	A0,39
	JSR	IGNBLNK
	JNZ	QT4
	MOV.B	A0,39
	JMP	QT1
QT4:
	MOVHL	A0,92
	JSR	IGNBLNK
	JNZ	QT5
	POP	A1
	JMP	QT2
QT5:
	RET

	;---------  DISPLAY NUMBER -----
PRTNUM:	
	PUSH	A3
	MOVI	A3,10	
	PUSH	A3
	MOVHH	A2,A3
	DEC.B	A2
	JSR	CHKSGN
	JP	PN1
	MOVHL	A2,'-'
	DEC.B	A2
PN1:
	PUSH	A2
PN2:
	JSR	DIVIDE
	OR	A2,A2
	JZ	PN3
	POP	A0
	PUSH	A1
	DEC.B	A0
	PUSH	A0
	MOV	A1,A2
	JMP	PN2
PN3:
	POP	A2
PN4:
	DEC.B	A2
	MOV.B	A0,A2
	OR.B	A0,A0
	JN	PN5
	MOV.B	A0,32
	JSR	CHROUT
	JMP	PN4
PN5:
	MOVLH	A0,A2
	JSR	CHROUT
	MOV.B	A3,A1
PN6:
	MOV.B	A0,A3
	CMP.B	A0,10
	POP	A3
	JZ	RET14
	ADD.B	A0,48
	JSR	CHROUT
	JMP	PN6

PRTLN:
	MOV	A4,A3
	JSR	LODSW
	MOV	A1,A0
	INC	A3
	INC	A3
PRTLN1:
	MOV.B	A2,4
	JSR	PRTNUM
	MOV.B	A0,32
	JSR	CHROUT
	SUB.B	A0,A0
	JSR	PRTSTG
RET14:
	RET

;---------- MVUP MVDOWN

MVUP:
	CMP	A3,A1
	JZ	RET15
	MOV	A4,A3
	JSR	LODSB
	MOV	A4,A2
	JSR	STOSB
	INC	A3
	INC	A2
	JMP	MVUP

MVDOWN:
	CMP	A3,A2
	JZ	RET15
MD1:
	DEC	A3
	DEC	A1
	MOV	A4,A3
	JSR	LODSB
	MOV.B	(A1),A0
	JMP	MVDOWN

POPA:
	POP	A2
	POP	A1
	MOV	(LOPVAR),A1
	OR	A1,A1
	JZ	PP1
	POP	A1
	MOV	(LOPINC),A1
	POP	A1
	MOV	(LOPLMT),A1
	POP	A1
	MOV	(LOPLN),A1
	POP	A1
	MOV	(LOPPT),A1
PP1:
	PUSH	A2
RET15:
	RET

PUSHA:
	MOV	A1,STKLMT
	JSR	CHGSGN
	POP	A2
	GETSP	A0
	ADD	A1,A0
	JNC	QSORRY

	MOV	A1,(LOPVAR)
	OR	A1,A1
	JZ	PU1
	MOV	A1,(LOPPT)
	PUSH	A1
	MOV	A1,(LOPLN)
	PUSH	A1
	MOV	A1,(LOPLMT)
	PUSH	A1
	MOV	A1,(LOPINC)
	PUSH	A1
	MOV	A1,(LOPVAR)
PU1:
	PUSH	A1
	PUSH	A2
	RET

;----------- ignblnk ---------

IGNBLNK:
	mov	a4,a3
ign1:
	JSR	LODSB
	cmp.b	a0,32
	jnz	ign2
	inc	a3
	jmp	ign1
ign2:
	SWAP	A0
	cmphl	a0
	SWAP	A0
	jnz	_ret
	push	sr
	inc	a3
	pop	sr
_ret:	ret
		

FINISH:
	JSR	FIN
	JMP	QWHAT

;--------------------------------

STOSB: PUSH	SR
	MOV.B	(A4),A0
	INC	A4
	POP	SR
	RET
LODSB: PUSH	SR
	MOV.B	A0,(A4)
	INC	A4
	POP	SR
	RET
STOSW: PUSH	SR
	btst	a4,0
	jnz	stow1
	MOV	(A4),A0
	INC	A4
	INC	A4
	jmp	stowe
stow1: swap	A0
	mov.b	(a4),a0
	inc	a4
	swap	a0
	mov.b	(a4),a0
	inc	a4
stowe: POP	SR
	RET
LODSW: PUSH	SR
	btst	a4,0
	jnz	lodw1
	MOV	A0,(A4)
	INC	A4
	INC	A4
	jmp	lodwe
lodw1: mov.b	a0,(a4)
	swap	a0
	inc	a4
	mov.b	a0,(a4)
	inc	a4
lodwe: POP	SR
	RET
;----------ADDED

OUTCMD:
	JSR	EXP
	MOV	A0,OUTIO
	INC 	A0
	INC	A0
	MOV	(A0),A1
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	QWHAT
	JSR	EXP
	JSR	OUTIO
	JMP	FINISH

INP:
	JSR	PARN
	MOV	A0,INPIO
	INC	A0
	INC	A0
	MOV	(A0),A1
	JMP	INPIO

; 'usr(i(,j))'
;
; usr call a machine language subroutine at location 'i'  if
; the optional parameter 'j' is used its value is passed  in
; hl. the value of the function should be returned in hl.

USR:
	PUSH	A2
	MOVHL	A0,'('
	JSR	IGNBLNK
	JNZ	QWHAT
	JSR	EXP
	MOVHL	A0,')'
	JSR	IGNBLNK
	JNZ	PASPRM
	PUSH	A3
	MOV	A3,USRET
	PUSH	A3
	PUSH	A1
	RET
PASPRM:
	MOVHL	A0,44
	JSR	IGNBLNK
	JNZ	USRET1
	PUSH	A1
	JSR	EXP
	MOVHL	A0,')'
	JSR	IGNBLNK
	JNZ	USRET1
	POP	A2
	PUSH	A3
	MOV	A3,USRET
	PUSH	A3
	PUSH	A2
	RET
USRET:
	POP	A3
USRET1:
	POP	A2
	RET

outio:
 	out $FFFF,A1
 	ret

INPIO:
	IN	A1,$FFFF
	RET
;-----------------------------------------------------
; DATA
XX		DB	0
YY		DB	0

TITLE		TEXT	"Tiny Basic for Lion System 2016"
		DB	13
how		TEXT  "how?"
		DB	$0d
OK		TEXT	"OK"
		DB	13
what		TEXT    "what?"
		DB	$0d
sorry		TEXT    "sorry"
		DB    $0d

OCSW		DB	$FF
SER		DB	0
RAND		DW	$0007
CURRNT	DW	0
STKGOS	DW	0
VARNXT	DW	0
STKINP	DW	0
LOPVAR	DW	0
LOPINC	DW	0
LOPLMT	DW	0
LOPLN		DW	0
LOPPT		DW	0
RANPNT	DA	RSTART

TXTUNF	DA    TXTBGN
		DW	0
		DW	0
TXTBGN	DS	28000   ; 22K program space
TXTEND	DS	2

BF		DS	1
BUF_CNT	DS	1  ; MUST BE BEFOR BUFFER?
BUFFER	DS	98
BUFEND:

VARBGN	DS	120

STKLMT	DS	2000
STACK:	



