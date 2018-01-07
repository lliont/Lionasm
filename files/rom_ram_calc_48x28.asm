	  	ORG 		0    ; Rom 
INT0_3      DW		0,0,0,0             
INT4        DA        	INTR4     ;interrupt vector 4
INT5_14     DW          0,0,0,0,0,0,0,0,0,0
INT15		DA		INTR15   ; trace interrupt

		JMP		START  ; address 32
INT4T0	DA		SERIN    ;  INT4 FUNCTION TABLE
INT4T1	DA		SEROUT
INT4T2	DA		PLOT   
INT4T3	DA		INT4R
INT4T4	DA		PUTC
INT4T5	DA		PSTR
INT4T6	DA		SCROLL2
INT4T7	DA		INT4R     
INT4T8	DA		INT4R     
INT4T9	DA		INT4R     ; NOT Defined
INT4T10	DA		KEYB

VBASE		EQU		57344
XDIM2		EQU		156  ; XDIM/2
YDIM		EQU		208
XCC		EQU		52
YCC		EQU		26

INTR15:	RETI
		
INTR4:	SLL		A0,1
		ADD		A0,INT4T0
		JMP		(A0)
INT4R:	MOVI		A0,0
		RETI
;---------------------------------------- 
SERIN:	IN		A0,6  ;Read serial byte if availiable
		BTST		A0,1  ;Result in A1, A0(1)=0 if not avail
		JZ		INTEXIT
		IN		A1,4
		MOVI		A0,2
		OUT		2,A0
		MOVI		A0,0
		OUT		2,A0
		MOVI		A0,2
		RETI
;----------------------------------------
SEROUT:	IN		A0,6  ;Wite serial byte if ready
		BTST		A0,0  ; A0(0)=0 if not ready
		JZ		INTEXIT
            PUSH        A1
		OUT		0,A1
		MOVI		A1,0
		MOVI		A0,1
		OUT		2,A0
		OUT		2,A1
		POP		A1
		RETI
;----------------------------------------
PUTC:		PUSHI        ;  PRINT Character in A1 at XX,YY
		PUSH		A2
		PUSH		A3
		CMP.B		A1,96  
		JBE		LAB1
		SUB		A1,32
		CMP.B		A1,90
		JLE		LAB1
		ADD		A1,6
LAB1:		SUB		A1,32    
		MULU.B	A1,6
		ADD		A1,CTABLE
		MOV		A2,A1       ; save character table address
		MOV.B		A0,(YY)
		MULU.B	A0,XDIM2
		SLL		A0,1
		MOVI		A1,0
          	MOV.B 	A1,(XX)
		ADD		A0,A1
		ADD		A0,VBASE   ; video base
		MOV		A3,A0      ; Addres at videoram
		SETI		5
		MOV		A1,A2
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
		MOV.B		(A3),A1
		INC		A2
		MOV		A1,A2
		ADD		A3,52          ; next line  
		JMPI		LP1
		POP		A3
		POP		A2
		POPI	
		RETI
;----------------------------------------
PSTR:		PUSH 		A1         ; PRINT A ZERO TERM. STRING POINTED BY A1
		MOVI		A0,0
		MOV.B		A0,(A1)
		MOV		A1,A0
;		CMP		A1,0
		JZ		STREXIT
		MOVI		A0,4
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
		JZ		STREXIT
		MOV.B		(YY),A1		
LAB3:		MOV.B		(XX),A0
		POP		A1
		INC		A1
		JMP		PSTR
STREXIT:	POP		A1
		RETI
;----------------------------------------

SCROLL2:	PUSHI
		SETI		7799	
		MOV		A0,VBASE
		MOV		A1,57656
SC1:		MOV.B		(A0),(A1)
		INC		A0
		INC		A1
		JMPI		SC1
		POPI
		RETI
;----------------------------------------
PLOT:		MOV		A0,VBASE  ; PLOT at A1,A2
		MULU.B	A2,204
		ADD		A0,A2
		MOV		A2,A1
		SLL		A1,3
		ADD		A0,A1
		MOV		A1,(A0)
		
		RETI
;---------------------------------------
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
		JBE		LP10
		ADD		A1,28
LP10:		POPI
INTEXIT:	RETI

; Charcter table Font
CTABLE	DB	0,0,0,0,0,0,            $5c,0,0,0,0,0
C34_35	DB	6,0,6,0,0,0,            $28,$7c,$28,$7c,$28,0
C36_37	DB	$5C,$54,$FE,$54,$74,0,  $44,$20,$10,$08,$44,0
C38_39      DB    $28,$7c,$28,$7c,$28,0,  6,0,0,0,0,0
C40_41	DB	$38,$44,0,0,0,0,        $44,$38,0,0,0,0
C42_43	DB	$15,$E,$4,$E,$15,0,    $10,$10,$7C,$10,$10,0
C44_45	DB	$C0,0,0,0,0,0,          $10,$10,$10,$10,$10,0
C46_47	DB	$40,0,0,0,0,0,          $0,$60,$10,$0C,0,0
C48_49	DB	$38,$64,$54,$4C,$38,0,  0,$48,$7C,$40,0,0
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

		ORG     	8192   ;Ram
LLINE		DS		52
XX		DB		5
YY		DB		4
CNT		DW    	7
BUF		DW		0
TITLE		TEXT		"Lion System Demo Calc!"
		DW		0
START:	MOVI		A1,5   ;  Entry Point
		MOV.B		(XX),A1
		MOVI		A1,5
		MOV.B		(YY),A1
		MOV		A1,TITLE
		MOVI		A0,5      ; Print Title
		INT		4
		SETI		51
		MOV		A0,(LLINE)
L4:		MOV.B		(A0),32
		INC		A0
		JMPI		L4
		;PUSH		SR  ;  Trace on
		;POP		A0
		;BSET		A0,5
		;PUSH		A0
		;POP		SR
		MOVI		A0,0
		MOV.B		(XX),A0
		MOV		A0,19
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
		CMP		A1,27        ; BS , ESC ?
		JNZ		L1
		MOV.B		A1,(XX)
		;CMP.B		A1,0
		JZ		L2
		DEC		A1
		MOV.B		(XX),A1
		MOV		A1,32
		MOVI		A0,4       ; clear previous char
		INT		4
		JMP		L2
L1:		MOVI		A0,1
		INT		4
		CMP.B		A1,13      ; Enter?
		JZ		L3
		;MOVI		A0,10      ; Convert to ASCII
		;INT		4
		;CMP		A1,0
		;JZ		L2         ; Get another if not ASCII
		MOV		A3,(LLINE)
		ADD		A3,(XX)
		MOV.B		(A3),A1
		JSR		PCHI        ; Print and inc xx
		MOV.B		A1,(XX)
		CMP.B		A1,33      ; Change Line ?
		JBE		L2
L3:		JSR		CALC
		SETI		51
		MOV		A0,(LLINE)
L5:		MOV.B		(A0),32
		INC		A0
		JMPI		L5
		MOVI		A1,0
		MOV.B		(XX),A1
		MOV.B		A1,(YY)
		INC		A1
		MOV.B		(YY),A1
		CMP.B		A1,19
		JBE		L2
		MOV		A1,19
		MOV.B		(YY),A1
		MOVI		A1,0
		MOV.B		(XX),A1
		MOVI		A0,6
		INT		4          ; Scroll 1 line
		;MOVI		A0,7       
		;INT		4          ;Refresh screen		
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
		JSR		ADDIT
		JMP		CL9
CL10:		CMP.B		A3,45		; is it a -
		JNZ		CL11
		JSR		SUBIT
		JMP		CL9
CL11:		CMP.B		A3,42     ; is it a plus *
		JNZ		CL12
		JSR		MULIT
		JMP		CL9
CL12:		CMP.B		A3,47		; is it a /
		JNZ		ERR1
		JSR		DIVIT
CL9:		JSR		DISPL
		RET
ERR1:		MOV		A1,ER1
		MOVI		A0,5
		INT		4
		RET

;------ EAT SPACES	----
ESP:		PUSH		A1
		PUSH		A0
ESP1:		MOV		A1,(STRI)
		ADD		A1,LLINE
		MOV.B		A0,(A1)
		CMP.B		A0,32
		JNZ		ESPE
		MOVI		A1,1
		ADD		A1,(STRI)
		MOV		(STRI),A1
		CMP		A1,32
		JBE  		ESP1
ESPE:		POP		A0
		POP		A1
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
M1		DW		0
M2		DW		0
MULIT:	MOV		A0,(NUM2)
		XOR		A0,(NUM1)
		MOVI		A1,0
		BTST		A0,15
		JZ		ML1     ; Check result sign
		MOVI		A1,1
ML1:		MOV		B1,A1
		MOV 		A1,(NUM1)  
		BTST		A1,15    ; check if neg and convert 
		JZ		ML2
		NOT		A1
		INC		A1
		MOV		(NUM1),A1
ML2:		MOV 		A1,(NUM2)
		BTST		A1,15   ; check if neg and convert 
		JZ		ML3
		NOT		A1
		INC		A1
ML3:		MOV		(NUM2),A1
		MOV 		A1,(NUM1)
		MOV		A0,(NUM2)
		MULU.B	A1,A0
		MOV		(M1),A1
		SWAP		A0
		MOV		A1,(NUM1)
		MULU.B	A0,A1
		SLL		A0,8
		ADD		A0,(M1)
		MOV		(M1),A0
		MOV		A1,(NUM1)
		SWAP		A1
		MOV		A0,(NUM2)
		MULU.B	A1,A0
		SLL		A1,8
		ADD		A1,(M1)
		MOV		A0,B1  ; correct the sign
		;CMP		A0,0
		JZ		MLEND
		NOT		A1
		INC		A1
MLEND:	RET

;---------- DIVISION ------------------------------

NN		DW		0

DIVIT:	MOV		A1,32767
		MOV		A0,(NUM2)
		;CMP		A0,0
		JZ		DVE
		XOR		A0,(NUM1)
		MOVI		A1,0
		BTST		A0,15
		JZ		DV1     ; Check result sign
		MOVI		A1,1
DV1:		MOV		B1,A1
		MOV 		A1,(NUM1)  
		BTST		A1,15    ; check if neg and convert 
		JZ		DV2
		NOT		A1
		INC		A1
		MOV		(NUM1),A1
DV2:		MOV 		A1,(NUM2)
		BTST		A1,15   ; check if neg and convert 
		JZ		DV3
		NOT		A1
		INC		A1
		MOV		(NUM2),A1
DV3:		MOV		A1,(NUM1)
		CMP		A1,(NUM2)
		JA		DV4
		JZ		DV4
		MOVI		A1,0
		RET
DV4:		MOV		A0,(NUM1)
		MOVI		A1,0
DV5:		BTST		A0,14
		JNZ		DV6
		INC		A1
		SLL		A0,1
		JMP		DV5
DV6:		MOV		(NN),A1 ; store no of shifts
		MOVI		B0,0
		MOV		A1,(NUM2)
DV7:		BTST		A1,14
		JNZ		DV12
		SLL		A1,1
		INC		B0
		JMP		DV7
DV12:		MOV		(NUM1),A0  
		MOV		(NUM2),A1  
		MOV		A1,B0
		MOV		A0,(NN)
		MOV		B0,A0
		SUB		A1,A0
		MOV		(NN),A1
		MOV		A0,(NUM1)  
		MOV		A1,(NUM2)  
DV10:		CMP		B0,0
		JZ		DV9
		SRL		A1,1
		SRL		A0,1
		DEC		B0
		JMP		DV10
DV9:		MOV		(NUM1),A0  ; new dividend = remainder
		MOV		(NUM2),A1  ; new divisor
		MOV		A1,(NN)
		SETI		A1
		MOVI		A1,0       ; quotient
DV11:		SLL		A1,1       
		CMP		A0,(NUM2)  ; compare remainder with divisor
		JA		DV13
		JZ		DV13
		JMP		DV8		
DV13:		BSET		A1,1
		SUB		A0,(NUM2)
DV8:		PUSH		A0
		MOV		A0,(NUM2)
		SRL		A0,1
		MOV		(NUM2),A0
		POP		A0
		JMPI		DV11
		SRL		A1,1
		MOV		A0,B1  ; correct the sign
		;CMP		A0,0
		JZ		DVE
		NOT		A1
		INC		A1
DVE:		RET

;---------  DISPLAY A CHAR AND INC XX -----
PCHI:		PUSH		A0
		MOVI		A0,4
		INT		4          
		MOV.B		A0,(XX)
		INC		A0
		MOV.B		(XX),A0
		POP		A0
		RET

;---------  DISPLAY NUMBER -----
DISPL:	MOV		B0,A1
		MOV		A1,32
		JSR		PCHI
		MOV		A1,61
		JSR		PCHI
		MOV		A1,32
		JSR		PCHI
		MOV		A1,B0
		BTST		A1,15
		JZ		DI0
		NOT		A1          ; Convert to positive 
		INC		A1
		MOV		B0,A1
		MOV		A1,45    ; print '-'
		JSR		PCHI
		MOV		A1,B0
DI0:		MOVI		A0,0
DI1:        CMP		A1,9999
		JLE		DI2
		INC		A0
		SUB		A1,10000
		MOV		B0,A1
		JMP		DI1
DI2:		ADD		A0,48
		MOV		A1,A0
		JSR		PCHI
		MOV		A1,B0
		MOVI		A0,0
DI3:        CMP		A1,999
		JLE		DI4
		INC		A0
		SUB		A1,1000
		MOV		B0,A1
		JMP		DI3
DI4:		ADD		A0,48
		MOV		A1,A0
		JSR		PCHI
		MOV		A1,B0
		MOVI		A0,0
DI5:        CMP		A1,99
		JLE		DI6
		INC		A0
		SUB		A1,100
		MOV		B0,A1
		JMP		DI5
DI6:		ADD		A0,48
		MOV		A1,A0
		JSR		PCHI
		MOV		A1,B0
		MOVI		A0,0
DI7:        CMP		A1,9
		JLE		DI8
		INC		A0
		SUB		A1,10
		MOV		B0,A1
		JMP		DI7
DI8:		ADD		A0,48
		MOV		A1,A0
		JSR		PCHI
		MOV		A1,B0
		ADD		A1,48
		MOVI		A0,4
		INT		4
		MOV.B		A0,(XX)
		INC		A0
		MOV.B		(XX),A0
		RET

; ------------ GET INTEGER NUMBER ----------------------
GETNUM:	JSR		ESP  ; eat spaces
		MOVI		B0,0    ; B0 will contain the num of digits
		MOV		A1,(STRI)
		MOV		A2,A1
		ADD		A1,LLINE
`		MOVI		A0,0	
		MOV		B1,A0 ;save sign
		MOV.B		A0,(A1)
		CMP.B		A0,45  ; is it minus
		JNZ		CL2
		MOV		A0,1
		MOV 		B1,A0
		INC		A2
		INC		A1
		MOV.B		A0,(A1)
CL2:		CMP.B		A0,47
		JBE		CL1
		CMP.B		A0,57
		JA		CL1
		SUB.B		A0,48  ; Convert to number
CL3:		PUSH		A0     ; First I push all digits to stack
		INC		B0
		CMP		B0,33
		JZ		CL1
		MOV		A1,B0
		ADD		A1,LLINE
		ADD		A1,A2
		MOVI		A0,0
		MOV.B		A0,(A1)
		JMP		CL2
CL1:		MOV		A1,B0
		CMP		A1,0
		JZ		CEND
		ADD		A1,A2
		MOV		(STRI),A1

		POP		A1             ; Get first digit
		MOV		A2,A1
		MOV		A0,A1
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
		MOV		A0,A1
CL5:		SLL		A0,3     ;  X8 
		SLL         A1,1    ;   X2
		ADD		A0,A1    ;  X10
		MOV		A1,A0    ; prepare next calc
		JMPI		CL5
		INC		B0
		ADD		A2,A0
		POPI
		JMPI		CL4
		INC 		B0
CL8:		MOV		A1,B1
		CMP		A1,1
		JNZ		CEND
		NOT		A2
		INC		A2
CEND:		MOV		(NUM),A2 			
		RET		
;-----------------------------------------------------

