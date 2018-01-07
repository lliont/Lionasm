;  2015 Theodoulos Liontakis  - system rom

	  	ORG 		0    ; Rom 
INT0_3      DW		0,0,0,0   ; hardware interrupts
INT4        DA        	INTR4     ;interrupt vector 4
INT5_14     DW          0,0,0,0,0,0,0,0,0,0
INT15		DA		INTR15   ; trace interrupt

		SETI		25       ; Set default color table
		MOV		A1,65144
COLINIT:	MOV.B		(A1),68
		INC		A1
		JMPI		COLINIT			
		JMP		START  ; address 32

;  INT4 FUNCTION TABLE
INT4T0	DA		SERIN    ; Serial port in    
INT4T1	DA		SEROUT   ; Serial port out
INT4T2	DA		PLOT     ; at X=A1,Y=A2 B1=1 set B1=0 clear
INT4T3	DA		INT4R    ; NOT Defined
INT4T4	DA		PUTC     ; Print char at A1.H A1.L
INT4T5	DA		PSTR     ; Print zero terminated string
INT4T6	DA		SCROLL   ; Scrolls screen 1 char (8 points) up
INT4T7	DA		INT4R    ; NOT Defined
INT4T8	DA		MULT     ; Multiplcation A1*A2 res in A1
INT4T9	DA		DIV      ; Div A2 by A1 res in A1,A0
INT4T10	DA		KEYB     ; converts to ascii the codes from serial keyboard

VBASE		EQU		57344
XDIM2		EQU		150    ; XDIM/2 Screen Horizontal Dim. / 2
YDIM		EQU		208    ; Screen Vertical Dimention
XCC		EQU		50     ; Horizontal Lines
YCC		EQU		26     ; Vertical Rows

INTR15:	RETI        ; trace interrupt
		
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
PUTC:		PUSHI        ;  PRINT Character in A1 at A2 (XY)
		PUSH		B0
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
		MOV		B0,A1       ; save character table address
		MOV.B		A0,A2
		MULU.B	A0,XDIM2
		SLL		A0,1
		MOVI		A1,0
		SWAP		A2
          	MOV.B 	A1,A2
		SWAP		A2
		MULU.B	A1,6
		ADD		A0,A1
		ADD		A0,VBASE   ; video base
		MOV		A3,A0      ; Addres at videoram
		SETI		5
		MOV		A1,B0
LP1:		MOV.B		A0,(A1)
		PUSHI
		SETI		7
		MOVI		A1,0
LP2:		BTST		A0,7
		JZ		LAB2
		BSET		A1,8
LAB2:		SLL		A0,1
		SRL		A1,1
		JMPI		LP2
		POPI
		MOV.B		(A3),A1
		INC		B0
		MOV		A1,B0
		INC		A3          ; next line  
		JMPI		LP1
		POP		A3
		POP		B0
		POPI	
		RETI
;----------------------------------------
PSTR:		MOVI		A0,0 ; PRINT A ZERO TERM. STRING POINTED BY A1
		MOV.B		A0,(A1)
		JZ		STREXIT
		PUSH 		A1
		MOV		A1,A0
		MOVI		A0,4
		INT		4
		POP		A1
		SWAP		A2       ;  X
		INC		A2
		CMP.B		A2,XCC
		JNZ		LAB3
		MOV.B		A2,0
		SWAP		A2
		INC		A2
		CMP.B		A2,YCC
		JZ		STREXIT
		SWAP		A2		
LAB3:		SWAP		A2
		INC		A1
		JMP		PSTR
STREXIT:	RETI
;----------------------------------------

SCROLL:	PUSHI
		SETI		7499	
		MOV		A0,VBASE
		MOV		A1,57644
SC1:		MOV.B		(A0),(A1)
		INC		A0
		INC		A1
		JMPI		SC1
		SETI		299
SC2:		MOV.B		(A0),0
		INC		A0
		JMPI		SC2
		POPI
		RETI
;----------------------------------------
PLOT:		PUSHI
		PUSH		A1
		PUSH		A2        ; PLOT at A1,A2 mode in B1
		MOV		A0,A2
		AND		A0,7
		SRL		A2,3
		MULU.B	A2,XDIM2
		SLL		A2,1
		ADD		A2,A1
		ADD		A2,VBASE 
		MOV.B		A1,(A2)
		SETI		A0
PL1:		SLL		A1,1
		JMPI		PL1
		CMP		B1,0
		JNZ		PL3
		BCLR		A1,8
		JMP		PL4
PL3:		BSET		A1,8
PL4:		SETI		A0
PL2:		SRL		A1,1
		JMPI		PL2
		MOV.B		(A2),A1
		POP		A2
		POP		A1
		POPI
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

;--------------------------------------------------------------

MULT:		PUSH		A3
		MOV		A0, A2
		XOR		A0, A1
		PUSH		A0
		BTST		A1,15    ; check if neg and convert 
		JZ		MUL2
		NOT		A1
		INC		A1
MUL2:		BTST		A2,15   ; check if neg and convert 
		JZ		MUL3
		NOT		A2
		INC		A2
MUL3:		MOV		A3,A2
		MULU.B	A3,A1
		MOV		A0,A1
		SWAP		A0
		MULU.B	A0,A2
		SLL		A0,8
		ADD		A3,A0
		MOV		A0,A2
		SWAP		A0
		MULU.B	A0,A1
		SLL		A0,8
		ADD		A3,A0
		POP		A0
		BTST		A0, 15
		JZ		MULEND     ; Check result sign
		NOT		A3
		INC		A3
MULEND:	MOV		A1,A3
		POP		A3
		RETI

;-------------------------------------------------------------
DIV:		PUSHI
		PUSH		A3
		PUSH		B0
		PUSH		B1
		MOV		A3,A1
		MOV		A1,32767
		MOV		A0,A3
		JZ		DIVE
		XOR		A0,A2
		MOVI		A1,0
		BTST		A0,15
		JZ		DIV1     ; Check result sign
		MOVI		A1,1
DIV1:		MOV		B1,A1
		MOV 		A1,A2  
		BTST		A1,15    ; check if neg and convert 
		JZ		DIV2
		NOT		A1
		INC		A1
		MOV		A2,A1
DIV2:		MOV 		A1,A3
		BTST		A1,15   ; check if neg and convert 
		JZ		DIV3
		NOT		A1
		INC		A1
		MOV		A3,A1
DIV3:		MOV		A1,A2
		CMP		A1,A3
		JA		DIV4
		JZ		DIV4
		MOV		A0,A1
		MOVI		A1,0
		JMP		DIVE
DIV4:		MOV		A0,A2
		MOVI		A1,0
DIV5:		BTST		A0,14
		JNZ		DIV6
		INC		A1
		SLL		A0,1
		JMP		DIV5
DIV6:		PUSH 		A1     ; store no of shifts
		MOVI		B0,0
		MOV		A1,A3
DIV7:		BTST		A1,14  ; align first 1's
		JNZ		DIV12
		SLL		A1,1
		INC		B0
		JMP		DIV7
DIV12:	MOV		A2,A0  
		MOV		A3,A1  
		MOV		A1,B0
		POP		A0  ; Get no of shifts
		MOV		B0,A0
		SUB		A1,A0
		PUSH		A1
		MOV		A0,A2  
		MOV		A1,A3  
DIV10:	CMP		B0,0
		JZ		DIV9
		SRL		A1,1
		SRL		A0,1
		DEC		B0
		JMP		DIV10
DIV9:		MOV		A2,A0  ; new dividend = remainder
		MOV		A3,A1  ; new divisor
		POP		A1
		SETI		A1
		MOVI		A1,0       ; quotient
DIV11:	SLL		A1,1       
		CMP		A0,A3  ; compare remainder with divisor
		JA		DIV13
		JZ		DIV13
		JMP		DIV8		
DIV13:	BSET		A1,1
		SUB		A0,A3
DIV8:		SRL		A3,1
		JMPI		DIV11
		SRL		A1,1
		CMP		B1,0
		JZ		DIVE
		NOT		A1
		INC		A1
DIVE:		POP		B1
		POP		B0
		POP		A3
		POPI
		RETI


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
START:	

