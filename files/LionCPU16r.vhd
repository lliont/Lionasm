-- 16bit Lion CPU
-- Theodoulos Liontakis (C) 2015 

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all ; 
USE ieee.std_logic_unsigned."+" ;
USE ieee.std_logic_unsigned."-" ;
USE ieee.std_logic_unsigned."*" ; 

entity LionCPU16 is
	port
	(
		Di  : IN  Std_logic_vector(15 downto 0);
		DOo  : OUT  Std_logic_vector(15 downto 0);
		AD  : OUT  Std_logic_vector(15 downto 0); 
		RWo,ASo,DSo : OUT Std_logic;
		RD, Reset, Clock, Int, HOLD: IN Std_Logic;
		IO, HOLDA : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK : OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0)
	);
end LionCPU16;

Architecture Behavior of LionCPU16 is
constant CA:natural:=0; 
constant OV:natural:=1;
constant ZR:natural:=2;
constant NG:natural:=3; 
constant ZERO8 : std_logic_vector(7 downto 0):= (OTHERS => '0');
constant ZERO16 : std_logic_vector(15 downto 0):= (OTHERS => '0');
constant InitialState:Std_logic_vector(2 downto 0):="000";
constant FetchState:Std_logic_vector(2 downto 0):="001";
constant Fetch2State:Std_logic_vector(2 downto 0):="010";
constant IndirectState:Std_logic_vector(2 downto 0):="011";
constant RelativeState:Std_logic_vector(2 downto 0):="100";
constant ExecutionState:Std_logic_vector(2 downto 0):="110";
constant StoreState:Std_logic_vector(2 downto 0):="111";

SIGNAL IDX: Std_logic_vector(15 downto 0):=ZERO16;
SIGNAL X,Y,X1,X2,Y1,Do,Ai,Ao,AoII,QX1,QY1,QZ1: Std_logic_vector(15 downto 0);
SIGNAL PC:Std_logic_vector(15 downto 0):="0000000000010000";
SIGNAL IR,Z1: Std_logic_vector(15 downto 0):=ZERO16;
SIGNAL SR: Std_logic_vector(7 downto 0):=ZERO8;
SIGNAL ST: Std_logic_vector(15 downto 0):="1111111111111110";
SIGNAL M : Std_logic_vector(31 downto 0);
SIGNAL FF,R,RR: Std_logic_vector(2 downto 0);
SIGNAL TT: natural range 0 to 15;
SIGNAL sub , add, half, carry, overflow, zero, neg, cin, rhalf: Std_logic;
SIGNAL ds, as, rw , rdy, Wen, qsub: Std_logic;

COMPONENT ALU_LA4 IS
PORT (X, Y 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		Z 		: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		add, sub, half, cin, clock: IN STD_LOGIC ;
		carry,overflow,zero,neg: OUT STD_LOGIC ) ;
END COMPONENT ;

COMPONENT ALU_LA2 IS
PORT (X, Y 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		Z 		: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		add, sub, half, cin, clock: IN STD_LOGIC ;
		carry,overflow,zero,neg: OUT STD_LOGIC ) ;
END COMPONENT ;

COMPONENT QuADD IS
PORT (QX, QY 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		QZ 		: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		qsub: IN STD_LOGIC ) ;
END COMPONENT ;

COMPONENT regs IS
PORT (Ai : IN STD_logic_vector(15 downto 0);
		Ao, AoII : OUT STD_logic_vector(15 downto 0);
		clk,Wen,half: IN Std_logic;
		R,RR: IN std_logic_vector(2 downto 0) ) ;
END COMPONENT;


procedure set_reg(i:Std_logic_vector(2 downto 0); v: std_logic_vector; b: std_Logic:='0'; f:std_logic:='1') is
begin
	R<=i; Ai<=v; Wen<='1';	
	if b='1' then
		rhalf<='0';
		if f='1' then
			if v(7 downto 0) = ZERO8 then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
			SR(NG)<=V(7);
		end if;
	else
		rhalf<='1';
		if f='1' then
			if v = ZERO16 then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
			SR(NG)<=V(15);
		end if;
	end if;
end set_reg;

procedure set_flags is
begin
	SR(3 downto 0) <= neg & zero & overflow & carry ;
end set_flags;

begin
	ALU: ALU_LA4
	PORT MAP ( X1,Y1,Z1, add, sub, half, cin, clock, carry, overflow, zero, neg ) ;
	FADD: QuADD 
	PORT MAP ( QX1,QY1,QZ1,qsub ) ;
	REG:REGs
	PORT MAP ( Ai,Ao,AoII,clock,Wen,rhalf,R,RR ) ;	

DOo<=DO; DSo<=DS; ASo<=AS; RWo<=RW;

Process (Reset,Clock)
variable rest,rest2,fetch,fetch1,fetch2,fetch3,rel,setreg:boolean:=false;
variable tmp,tmp2,stmp:Std_logic_vector(15 downto 0);
variable r1,r2: Std_logic_vector(2 downto 0);
variable bt: natural range 0 to 15;
variable bwb: Std_logic; --  bit to distinguish between word byte operations 
begin
IF Reset = '1' THEN
		PC <= "0000000000010000"; SR <= ZERO8; IA<="00"; HOLDA<='0';
		AS<='1';  DS<='1'; RW<='1'; ST <= "1111111111111110"; --was (16382) end of internal ram
		AD <= (OTHERS => '0'); IR<=(OTHERS=>'0');	 
		Wen<='0'; rhalf<='0'; IACK<='0';
		FF<=InitialState; TT<=0; add<='0'; sub<='0';  cin<='0'; rdy<='0'; 
	ELSIF Clock'EVENT AND Clock = '1' AND HOLD='0' AND FF=InitialState AND TT=0  then
		HOLDA<='1'; Wen<='0';
	ELSIF Clock'EVENT AND Clock = '1' AND RD='0' THEN 
	   rdy<='1'; Wen<='0';
	ELSIF Clock'EVENT AND Clock = '1' AND HOLD='1' and INT='0' AND FF=InitialState AND TT=0 and SR(7)='0' THEN   -- Interrupts
		IR<="100000100000"&I&"00";
		FF<=ExecutionState; TT<=0; Wen<='0';
		IA<=I; IACK<='1';
		HOLDA<='0';
	ELSIF Clock'EVENT AND Clock = '1'  THEN   
		rest:=false; rest2:=false; HOLDA<='0'; 
		case  FF is -- Fetch Instruction 
		when InitialState =>
			case TT is
			when 0 =>
				fetch:=false; fetch1:=false; fetch2:=false; rel:=false; setreg:=true;
				AD<=PC; half<='0';  cin<='0'; add<='0'; sub<='0'; qsub<='0';
				 AS<='0'; 
			when 1 =>
				Wen<='0'; rhalf<='0'; QX1<=PC; QY1<="0000000000000010";
			when 2 =>
				PC<=QZ1; --PC+2;
				 AS<='1'; QX1<=ST; QY1<="0000000000000010";
				IR<=Di;
				RR<=Di(4 downto 2); R<=Di(8 downto 6);
			when others =>
				stmp:=QZ1;
				r2:=RR; r1:=R;	X1<=Ao;	Y1<=AoII;
				bt:=to_integer(unsigned(IR(5 downto 2)));
				bwb:= IR(5);
				rel:= IR(15 downto 13)="111"; --'1' and IR(14)='1' and IR(13)='1';
				fetch3:=IR(15 downto 13)="110"; --'1' and IR(14)='1' and IR(13)='0';
				if IR(0)='1' then
					FF<=FetchState; AD<=PC; AS<='0'; 
				else 
					if IR(1)='1' then	
						FF<=IndirectState;
					else	
						if rel then FF<=RelativeState; else FF<=ExecutionState; end if;
					end if;
				end if;
				rest:=true;
			end case;
		when FetchState =>              -- Fetch next word into X
			case TT is 
			when 0 =>
				fetch1:=true;
				QX1<=PC; QY1<="0000000000000010";
			when others =>
				PC<=QZ1;
				X<=Di;  AS<='1'; 
				if fetch3 then 
					FF<=Fetch2State;
				else	
					if IR(1)='1' then	
						if rel then FF<=RelativeState; else FF<=IndirectState; end if;
					else	
						if rel then FF<=RelativeState; else FF<=ExecutionState; end if;
					end if;
				end if;
				rest:=true;
			end case;
		when Fetch2State =>             -- fetch one more into Y
			case TT is
			when 0 =>
				AD<=PC;  AS<='0';
			when 1 =>
				QX1<=PC; QY1<="0000000000000010";
			when others =>
				Y<=Di; AS<='1'; PC<=QZ1; --PC+2; 
				if IR(1)='1' then	FF<=IndirectState; else FF<=ExecutionState;	end if;
				rest:=true;
			end case;
		when IndirectState =>              -- indirect
			case TT is
			when 0 =>
				fetch2:=true; AS<='0';  
				if IR(0)='1' then	AD<=X; x2<=X; else AD<=Y1; x2<=y1; end if;
			when 1 =>
			when others =>
				if x2(0)='0' and bwb='1' and (not rel) then
					X(7 downto 0)<=Di(15 downto 8);
					X(15 downto 8)<=Di(7 downto 0);
				else
					X<=Di; 
				end if;
				AS<='1';	FF<=ExecutionState;
				rest:=true;
			end case;
		when RelativeState =>              -- relative
			case TT is
			when 0 =>
				tmp2:=Y1; tmp:=X1;
				if fetch1 or fetch2 then Y1<=X; else Y1<=tmp; end if;
				X1<=PC; add<='1';
			--when 1  =>
			when others =>
				 Y1<=tmp2; add<='0';
				 rest:=true; if IR(1)='1' then FF<=IndirectState; else FF<=ExecutionState; end if;
			end case;
		when "101" =>
		when ExecutionState =>               --- F="110" Operation execution cycles 
			fetch:=fetch1 or fetch2;  
			case IR(15 downto 9) is
			when "0000000" =>              -- NOP
					rest2:=true;
			when "0000001" =>              -- MOV Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp:=X; else tmp:=Y1; end if;
				set_reg(r1,tmp,'0','0');
				rest2:=true;
			when "0000010" =>              -- MOV <Reg>,(Reg,NUM,[reg],[n])
				AD<=X1;  
				if fetch then Y1<=X;	end if;
				FF<=StoreState;
				rest:=true;
			when "0000011" =>              --ADD & ADD.B Reg,(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					half<=bwb;
					if fetch=true then Y1<=X; end if;
					add<='1';
				--when 1 =>
				when others =>
					add<='0'; sub<='0'; cin<='0';
					rest2:=true;
					if setreg then set_reg(r1,Z1,bwb,'0'); end if;
					set_flags;
				end case;
			when "0000100" =>              --SUB & SUB.B Reg,(Reg,NUM,[reg],[n])
				half<=bwb;
				if fetch=true then Y1<=X; end if;
				sub<='1'; 
				IR(15 downto 9)<="0000011"; -- continue as in ADD
				
			when "0000101" =>              --ADC Reg,(Reg,NUM,[reg],[n])
				if fetch then	Y1<=X;	end if;
				half<=bwb ; cin<=SR(CA); add<='1';
				IR(15 downto 9)<="0000011"; -- continue as in ADD

			when "0000110" =>              -- MOV.B Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp(7 downto 0):=X(7 downto 0);
							 else tmp(7 downto 0):=Y1(7 downto 0); end if;
				set_reg(r1,tmp,'1','0'); 
				rest2:=true;
			when "0000111" =>              -- OUT (n,Reg),Reg	
				case TT is
				when 0 =>
					if fetch then AD<=X; else AD<=X1; end if;
					IO<='1'; AS<='0';   RW<='0';	 Do<=Y1;
				when 1 =>
					DS<='0'; 
				when 2 =>
				when others =>
					--IO<='0';	DS<='1'; AS<='1'; RW<='1';
					rest2:=true;
				end case;
			when "0001000" =>              --SWAP R
				tmp:=X1(7 downto 0) & X1(15 downto 8);
				set_reg(r1,tmp,'0','0'); 
				rest2:=true;
			when "0001001" =>              -- MOV ST,Rn  SETSP
					ST<=Y1; 
					rest2:=true;
			when "0001010" =>            --MULU Reg,Reg	MULU.B Reg,(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					SR(CA)<='0'; SR(NG) <= '0';
					if fetch then
						if bwb='0' then
							M<=std_logic_vector(unsigned(X1) * unsigned(X));
						else
							M<=std_logic_vector(unsigned("00000000"&X1(7 downto 0)) * unsigned("00000000"&X(7 downto 0)));
						end if;
					else 
						if bwb='0' then
							M<=std_logic_vector(unsigned(X1) * unsigned(Y1));
						else
							M<=std_logic_vector(unsigned("00000000"&X1(7 downto 0)) * unsigned("00000000"&Y1(7 downto 0)));
						end if;
					end if;				
				when 1 =>
					if bwb='1' then 
						SR(OV) <='0'; --neg & zero & overflow & carry
						if M(15 downto 0) = ZERO16 then SR(ZR) <= '1'; else SR(ZR) <='0'; end if;
					else
						if not fetch then
							SR(OV) <=  '0';
						else
							if M(31 downto 16)=ZERO16 then	
								SR(OV) <= '0'; --neg & zero & overflow & carry
							else
								SR(OV)<='1';
							end if;
						end if;
						if (M(15 downto 0) OR M(31 downto 16)) = ZERO16 then SR(ZR) <= '1'; else SR(ZR) <='0'; end if;
					end if;
					tmp:=M(15 downto 0); set_reg(r1,tmp,'0','0'); 
					rest2:=fetch or bwb='1';
				when 2 =>
					Wen<='0';
				when others =>
					tmp:=M(31 downto 16); set_reg(r2,tmp,'0','0');
					rest2:=true;
				end case;
 
			when "0001100" =>           -- MOV.B <Reg>,(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					AD<=X1 ; AS<='0';  
				when 1 =>
				when others =>
					if AD(0)='1' then	
						if  fetch then
							Y1<=Di(15 downto 8) & X(7 downto 0);
						else
							Y1(15 downto 8)<=Di(15 downto 8);
						end if;
					else 
						if  fetch then
							Y1<= X(7 downto 0) & Di(7 downto 0);
						else
							Y1<= Y1(7 downto 0) & Di(7 downto 0);
						end if;
					end if;
					AS<='1';	rest:=true; FF<=StoreState;
				end case;
			when "0001101" =>               -- CMP & CMP.B (n),Reg
					half<=bwb;
					X1<=X; --if fetch then X1<= X; end if;
					sub<='1'; 
					setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD
			when "0001110" =>              --CMP & CMP.B Reg,(Reg,NUM,[reg],[n])
				half<=bwb;
				if fetch then Y1<=X;	end if;
				sub<='1'; 
				setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD
			when "0001111" =>              --AND & AND.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 AND X; else tmp:=X1 AND Y1; end if;
				set_reg(r1,tmp,bwb);
				rest2:=true;
			when "0010000" =>              --OR & OR.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 OR X; else tmp:=X1 OR Y1; end if;
				set_reg(r1,tmp,bwb);
				rest2:=true;
			when "0010001" =>              --XOR & XOR.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 XOR X; else tmp:=X1 XOR Y1; end if;
				set_reg(r1,tmp,bwb);
				rest2:=true;	
			when "0010010" =>              --NOT & NOT.B Reg
				tmp:= NOT X1;
				set_reg(r1,tmp,bwb);
				rest2:=true;
			when "0010011" =>              -- SETX (Reg,NUM,[reg],[n])
					if fetch then tmp:=X; else	tmp:=Y1; end if;
					IDX<=tmp;
					rest2:=true;
			when "0010100" =>              --JMPX 
					if fetch then	tmp:=X; else tmp:=Y1; end if;
					if IDX/=ZERO16 then PC<=tmp; end if;
					IDX<=IDX-1;
					rest2:=true;
			when "0010101" =>              -- MOVX RegA
					tmp:=IDX;
					set_reg(r1,tmp,'0','0');
					rest2:=true;
			when "0010110" =>              -- BTST  R,n
					if X1(bt)= '0' then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
					rest2:=true;
			when "0010111" =>              -- BSET  R,n
					tmp:=X1;	tmp(bt):='1';	set_reg(r1,tmp,'0','0'); 
					rest2:=true;
			when "0011000" =>              -- BCLR  R,n
					tmp:=X1;	tmp(bt):='0'; set_reg(r1,tmp,'0','0'); 
					rest2:=true;
			when "0001011" =>              -- BTST  R,R
					if X1(to_integer(unsigned(Y1(3 downto 0))))= '0' then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
					rest2:=true;
			when "1010001" =>              -- BSET  R,R
					tmp:=X1;	tmp(to_integer(unsigned(Y1(3 downto 0)))):='1';	set_reg(r1,tmp,'0','0'); 
					rest2:=true;
			when "0011110" =>              -- BCLR  R,R
					tmp:=X1;	tmp(to_integer(unsigned(Y1(3 downto 0)))):='0'; set_reg(r1,tmp,'0','0'); 
					rest2:=true;						
			when "0011001" =>              --SRA Reg
					tmp:= std_logic_vector(shift_right(signed (X1),bt));
					set_reg(r1,tmp); 
					SR(CA)<=X1(bt-1);
					rest2:=true;
			when "0011010" =>              --SLA Reg
					tmp:= std_logic_vector(shift_left(signed (X1),bt));
					set_reg(r1,tmp); --A(r1)<=tmp; 
					--SR(CA)<=X1(16-bt);
					rest2:=true;
			when "0011011" =>              --SRL Reg
					SR(CA)<=X1(bt-1);
					tmp:= std_logic_vector(shift_right(unsigned (X1),bt));
					set_reg(r1,tmp);  
					rest2:=true;
			when "0011100" =>              --SLL Reg
					SR(CA)<=X1(16-bt);
					tmp:= std_logic_vector(shift_left(unsigned (X1),bt));
					set_reg(r1,tmp);  
					rest2:=true;
			when "0011111" =>  -- xchg r1,r2
				case TT is
				when 0 =>
					tmp:=X1;
					set_reg(r2,tmp,'0','0');
				when 1 =>
					Wen<='0';
				when others =>
					tmp:=Y1;
					set_reg(r1,tmp,'0','0');
					rest2:=true;
				end case;	
			when "0100000" =>              -- MOVI Reg,0-15
					tmp:="000000000000"&IR(5 downto 2);
					set_reg(r1,tmp,'0','0');
					rest2:=true;
			when "0100001" =>               -- CMP & CMP.B (R),(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					half<=bwb;
					IF fetch then Y1<= X; end if; 
					AD<=X1; AS<='0';
				when 1 =>
				when 2 =>
					if bwb='1' then
						if X1(0)='1' then X1(7 downto 0)<=Di(7 downto 0);
						             else X1(7 downto 0)<=Di(15 downto 8); end if;
					else
						X1<=Di;
					end if;
					sub<='1'; AS<='1'; 
				when 3  =>
					sub<='0';	set_flags;
					rest2:=true;
				when others =>
				end case;
			when "0100010" =>              -- MOVI.B Reg,0-15
					tmp(7 DOWNTO 0):="0000"&IR(5 downto 2);
					set_reg(r1,tmp,'1','0'); --A(r1)<=tmp;
					rest2:=true;		
			when "0100101" =>              -- JMP (Reg,NUM,[reg],[n])
					if fetch then PC<=X;
					else	PC<=Y1; end if;
					rest2:=true;
			when "0100110" =>              -- JZ (Reg,NUM,[reg],[n])
					If SR(ZR)='1' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0100111" =>              -- JNZ (Reg,NUM,[reg],[n])
					If SR(ZR)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101000" =>              -- JO (Reg,NUM,[reg],[n])
					If SR(OV)='1' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101001" =>              -- JNO (Reg,NUM,[reg],[n])
					If SR(OV)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101010" =>              -- JC,JB (Reg,NUM,[reg],[n])
					If SR(CA)='1' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101011" =>              -- JNC (Reg,NUM,[reg],[n])
					If SR(CA)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101100" =>              -- JN (Reg,NUM,[reg],[n])
					If SR(NG)='1' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101101" =>              -- JP (Reg,NUM,[reg],[n])
					If SR(NG)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101110" =>              -- JBE (Reg,NUM,[reg],[n])
					If SR(ZR)='1' or SR(CA)='1' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0101111" =>              -- JA (Reg,NUM,[reg],[n])   
					If SR(ZR)='0' and SR(CA)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0011101" =>              -- JAE (Reg,NUM,[reg],[n])   
					If SR(ZR)='1' or SR(CA)='0' then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0110000" =>              --CMPI.B Reg,0-15
				half<='1';
				Y1<="000000000000"&IR(5 downto 2);
				sub<='1'; 
				setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD
				
			when "0110001" =>              -- JL (Reg,NUM,[reg],[n])
				If  (SR(NG)/=SR(OV)) then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;
         when "0110010" =>              --CMPHL Reg,(Reg,NUM,[reg],[n])
				half<='1';
				X1(7 downto 0)<=X1(15 downto 8);
				if fetch then Y1<=X;	end if;
				sub<='1'; setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD
       
			when "0110101" =>              -- JSR Reg  /NUM / <reg>/<n>
				case TT is
				when 0 =>
					AD<=ST;	AS<='0'; RW<='0';  Do<=PC;
				when 1 =>
					DS<='0'; 
				when 2 =>
				when others =>
					ST<=ST-2; --RW<='1'; AS<='1';  DS<='1';
					if fetch then tmp:=X;
					else	tmp:=Y1; end if;
					PC<=tmp;	rest2:=true;
				end case;
			when "0110110" =>              --ROL Reg
					tmp:= std_logic_vector(shift_left(unsigned (X1),bt));
					tmp(0):=X1(bt-1);
					set_reg(r1,tmp);  
					rest2:=true;            
			when "0110111" =>              -- RET
				case TT is
				when 0 =>
					ST<=ST+2; 
				when 1 =>
					AD<=ST; AS<='0';  
				when 2 =>
				when others =>
					PC<=Di;
					rest2:=true;
				end case;
			when "0111000" =>              -- JLE (Reg,NUM,[reg],[n])
					If SR(ZR)='1' or (SR(NG)/=SR(OV)) then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;
			when "0111001" =>              -- JG (Reg,NUM,[reg],[n])
					If SR(ZR)='0' and (SR(NG)=SR(OV)) then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;   
			when "0111011" =>              -- PUSH Rn, n, (Rn), (n)
					tmp:=ST;
					AD<=tmp; 	
					if fetch then Y1<=X; else Y1<=X1; end if;
					ST<=ST-2;  FF<=StoreState;
					rest:=true;
			when "0111100" =>              -- PUSH SR
					tmp:=ST;
					AD<=tmp; Y1(7 downto 0)<=SR; ST<=ST-2;
					rest:=true;  FF<=StoreState;
			when "0111101" =>              -- PUSHX
					tmp:=ST;
					AD<=tmp;	Y1<=IDX; ST<=ST-2;
					rest:=true; FF<=StoreState;
			when "0111110" =>              -- POPX 
				case TT is
				when 0 =>
					ST<=stmp; 
					AD<=stmp;	AS<='0'; 
				when 1 =>
				when others =>
					IDX<=Di; 
					rest2:=true;
				end case;
			when "0111111" =>              -- POP SR
				case TT is
				when 0 =>
					ST<=stmp; AD<=stmp;	AS<='0';
				when 1 =>
				when others =>
					SR<=Di(7 downto 0); 
					rest2:=true;
				end case;
			when "1000000" =>              -- POP Rn
				case TT is
				when 0 =>
					ST<=stmp; AS<='0'; AD<=stmp;
				when 1 =>
				when others =>
					tmp:=Di;
					set_reg(r1,tmp,'0','0');
					rest2:=true;
				end case;		
			when "1000001" =>              -- INT n  don't change opcode
				case TT is
				when 0 =>
					AD<=ST; AS<='0'; RW<='0'; Do<=PC; Wen<='0';
					DS<='0'; 
				when 1 =>
					ST<=ST-2;
				when 2 =>
					AS<='1';  DS<='1';
				when 3 =>
					AD<=ST; Do(7 downto 0)<=SR;
					AS<='0';  RW<='0';   DS<='0'; 
				when 4 =>
					ST<=ST-2;
				when 5 =>
					SR(7)<='1';
					AS<='1'; DS<='1';  RW<='1'; 
					tmp:="00000000000"&IR(5 downto 2)&"0"; AD<=tmp;
				when 6 =>
					AS<='0'; 
				when 7 =>
				when others =>
					PC<=Di; SR(5)<='0'; 
					rest2:=true; 
				end case;
			when "1000010" =>              -- RETi  don't change opcode
				case TT is
				when 0 =>
					ST<=stmp;
					AD<=stmp; AS<='0';   
				when 1 =>
				when 2 =>
					SR<=Di( 7 downto 0); ST<=ST+2;   AS<='1';
				when 3 =>
					AD<=ST;	AS<='0';  
				when 4 =>
				when others =>	
					PC<=Di;  IA<="00"; IACK<='0'; --AS<='1';
					rest2:=true;
				end case;
			when "1000011" =>              -- CLI
					SR(7)<='1';
					rest2:=true;
			when "1000100" =>              -- STI
					SR(7)<='0';
					rest2:=true;
			when "1000101" =>   -- GETSP
				--tmp:=ST;
				set_reg(r1,ST,'0','0');
				rest2:=true;
			when "1000110" =>              -- IN Reg, (Reg, n)
				case TT is
				when 0 =>
					if fetch then tmp:=X; else	tmp:=Y1;	end if;
					AD<=tmp; IO<='1';	AS<='0';   
				when 1 =>
				when others =>
					if (bwb='1') and (AD(0)='0') then
						tmp(7 downto 0):=Di(15 downto 8);
					else
						tmp:=Di;
					end if;
					set_reg(r1,tmp,bwb,'0'); --AS<='1'; 
					IO<='0'; rest2:=true;
				end case;
			when "1000111" | "1001000" =>              -- INC DEC & INC.B DEC.B Rn
					Y1<="0000000000000001";
					add<=IR(9); sub<= NOT IR(9);
					half<=bwb;
					IR(15 downto 9)<="0000011"; -- continue as in ADD
					
			when "1001001" =>              -- MOV (n),Reg 
					AD<=X; FF<=StoreState;
					rest:=true;
			when "1001010" =>              -- MOV.B (n),Reg	
					AD<=X2 ;  
					if X2(0)='1' then	
						tmp:=X(15 downto 8)&Y1(7 downto 0);
					else 
						tmp:= Y1(7 downto 0) & X(15 downto 8);
					end if;
						Y1<=tmp;
					rest:=true; FF<=StoreState;    

			when "1001100" =>              -- MOVHL Reg,(Reg,NUM,[reg],[n])
				if fetch2 then
					if X2(0)='1'  then	tmp:=X(7 downto 0)&X1(7 downto 0);
								  else	tmp:=X(15 downto 8)&X1(7 downto 0);	end if;
				else
					if fetch1 then	tmp:=X(7 downto 0)&X1(7 downto 0);
								 else tmp:=Y1(7 downto 0)&X1(7 downto 0); end if;
				end if;
				set_reg(r1,tmp,'0','0'); 
				rest2:=true;
			when "1001101" =>              -- MOVLH Reg,(Reg,NUM,[reg],[n])
					if fetch then	tmp(7 downto 0):=X(15 downto 8);
								 else tmp(7 downto 0):=Y1(15 downto 8); end if;
				set_reg(r1,tmp,'1','0'); 
				rest2:=true;
			when "1001110" =>              -- MOVHH Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp:=X(15 downto 8)&X1(7 downto 0);
				else tmp:=Y1(15 downto 8)&X1(7 downto 0); end if;
				set_reg(r1,tmp,'0','0'); 
				rest2:=true;
			when "1001111" =>              --SRL.B Reg
					tmp(7 downto 0):= std_logic_vector(shift_right(unsigned (X1(7 downto 0)),bt));
					set_reg(r1,tmp,'1'); 
					SR(CA)<=X1(bt-1);
					rest2:=true;
			when "1010000" =>              --SLL.B Reg
					tmp(7 downto 0):=  std_logic_vector(shift_left(unsigned (X1(7 downto 0)),bt));
					set_reg(r1,tmp,'1');  
					SR(CA)<=X1(8-bt);
					rest2:=true; 

			when "1010010" =>              --CMPI Reg,(0-15)
					Y1<="000000000000"&IR(5 downto 2);
					sub<='1'; 
					setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD

			when "1010011" =>              --SUBI Reg,0-15   1011001-6275
					Y1<="000000000000"&IR(5 downto 2);
					sub<='1'; bwb:='0';
				   IR(15 downto 9)<="0000011"; -- continue as in ADD			
			when "1010100" =>              --ADDI Reg,0-15
				Y1<="000000000000"&IR(5 downto 2);
				add<='1'; bwb:='0';
				IR(15 downto 9)<="0000011"; -- continue as in ADD
			when "1010101" =>              -- NEG Rn
				tmp:=X1;
				X1<=NOT tmp;
				Y1<="0000000000000001";
				add<='1';
				half<=bwb;
				IR(15 downto 9)<="0000011"; -- continue as in ADD
				
			when "1010110" =>              -- OUT Reg,n	
				AD<=X1; 
				IO<='1'; AS<='0';   RW<='0';	 Do<=X;
				IR(15 downto 9)<="0000111"; -- continue as in OUT n,ax
				
			when "1010111" =>              -- OUT.B (Reg,n),Reg	
				case TT is
				when 0 =>
					if fetch then AD<=X; else AD<=X1; end if;
					IO<='1'; AS<='0';  
				when 1 =>
				when 2 =>
					if AD(0)='0' then
						Do<=Y1(7 downto 0)&Di(7 downto 0);
					else
						Do<=Di(15 downto 8)&Y1(7 downto 0);
					end if;
				   AS<='1'; IO<='0';
				when 3 =>
					RW<='0'; AS<='0'; IO<='1'; DS<='0'; 
				when 4 =>
				when others =>
					--IO<='0';	DS<='1'; AS<='1'; RW<='1';
					rest2:=true;
				end case;
				
			when "1011000" =>                     -- OUT.B Reg,n	
					AD<=X1; IO<='1'; AS<='0'; Y1<=X;
					IR(15 downto 9)<="1010111";  -- as OUT.B
								
			when "1001011" =>    --SLLL Reg
			      case TT is
					when 0 =>
						SR(CA)<=X1(15);
						tmp:=X1(14 downto 0)&Y1(15);
						set_reg(r1,tmp); 
					when 1 => 
						Wen<='0';
					when others =>
						tmp:=Y1(14 downto 0)&"0";
						set_reg(r2,tmp);		
						rest2:=true;  
					end case;
			when "1011001" =>              --SRLL Reg
				   case TT is
					when 0 =>
						SR(CA)<=Y1(0);
						tmp:="0"&X1(15 downto 1);
						set_reg(r1,tmp);  
					--when 1 =>  -- for stupid size !!!
					when 1 =>
						Wen<='0';
					when others =>
						tmp:=X1(0)&Y1(15 downto 1);
						rest2:=true;  
						set_reg(r2,tmp);		
					end case;

			when "1011100" | "1011101" =>              -- ADD SUB [n],reg  ADD.B [n],reg
					X1<=X; sub<=IR(9); add<=NOT IR(9); 
					half<=bwb;	AD<=X2;
					IR(15 downto 9)<="1100100"; -- continue ADD [n],n
					
			when "1011110" | "1011111" =>              -- ADD SUB [reg],reg  ADD.B [reg],reg
					X1<=AoII;  Y1<=X; -- assembler reverses X1,Y1 
					sub<=IR(9); add<=NOT IR(9); 
					half<=bwb; AD<=X2;
					IR(15 downto 9)<="1100100"; -- continue ADD [n],n
					
			when "1011010" | "0110100" =>              -- ADD SUB [reg],n  ADD.B [reg],n 
				case TT is
				when 0 =>
					Y1<=X; AD<=X1; AS<='0';
				when 1 =>
				when 2 =>
					AS<='1'; X1<=Di; sub<= NOT IR(10); add<=IR(10); 
				when others  =>
					add<='0'; sub<='0';
					if half='1' then 
						if X2(0)='0' then 
							Y1<=Z1(7 downto 0)&X(15 downto 8);
						else 
							Y1<=X(15 downto 8)&Z1(7 downto 0);
						end if;
					else 
						Y1<=Z1;
					end if;    
					set_flags;	FF<=StoreState;	rest:=true;
				end case;
				
			when "0100011" =>              -- JGE (Reg,NUM,[reg],[n])
					If SR(ZR)='1' or (SR(NG)=SR(OV)) then
						if fetch then PC<=X;
						else	PC<=Y1; end if;
					end if;
					rest2:=true;  

			when "1011011" | "0111010" =>              --ADD SUB SP,(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					X1<=ST;
				--when 1  =>
					if fetch then Y1<=X; end if;
					add<=IR(9); sub<=NOT IR(9);
				when others  =>
					add<='0'; sub<='0';
					ST<=Z1;
					rest2:=true;
				end case;	
			when "0110011" =>
				rest2:=true;
			
     
------instructions equal or between 1100... and 11100.... cause double fetch -----------------			

			when "1100000" =>              -- MOV (n),n
				AD<=X; Y1<=Y; FF<=StoreState;
				rest:=true;
			when "1100001" =>              -- MOV.B (n),n
				tmp:=X; 	AD<=X2;
				if X2(0)='1' then	
					Y1<=tmp(15 downto 8) & Y(7 downto 0);
				else 
					Y1<= Y(7 downto 0) & tmp(15 downto 8);
				end if;
				rest:=true; FF<=StoreState;
			when "1100010" =>               -- CMP & CMP.B (n),n
				Y1<=Y;
				half<=bwb;				
				X1<= X; 
				sub<='1'; 
				setreg:=false;
				IR(15 downto 9)<="0000011"; -- continue as in ADD

			when "1100011" =>              -- OUT n,n	
					AD<=X;
					IO<='1'; AS<='0';   RW<='0';	 Do<=Y;  
					IR(15 downto 9)<="0000111"; -- continue as in OUT n,ax
					
			when "1100100" | "1100101" =>              -- ADD,SUB  [n],n  ADD.B, SUB.B [n],n
				case TT is
				when 0 =>
					X1<=X; Y1<=Y;
					sub<=IR(9); add<=NOT IR(9); half<=bwb;	AD<=X2;
				when 1  =>
				when others =>
					add<='0'; sub<='0';
					if bwb='1' then 
						if X2(0)='0' then 
							Y1<=Z1(7 downto 0)&X(15 downto 8);
						else 
							Y1<=X(15 downto 8)&Z1(7 downto 0);
						end if;
					else 
						Y1<=Z1;
					end if;    
					set_flags;	FF<=StoreState;	rest:=true;
				end case;
				
		-----------    instructions after "11100..." relative 
			when "1110000" =>              -- JR (Reg,NUM,[reg],[n])
				PC<=Z1; 
				rest2:=true;
			when "1110001" =>              -- JRZ (Reg,NUM,[reg],[n])
				if SR(ZR)='1' then PC<=Z1; end if;
				rest2:=true;
			when "1110010" =>              -- JRN (Reg,NUM,[reg],[n])
				if SR(NG)='1' then	PC<=Z1; 	end if;
				rest2:=true;
			when "1110011" =>              -- JRO (Reg,NUM,[reg],[n])
				if SR(OV)='1' then	PC<=Z1; end if;
				rest2:=true;
			when "1110100" =>              -- JRC (Reg,NUM,[reg],[n])
				if SR(CA)='1' then	PC<=Z1; end if;
				rest2:=true;
			when "1110101" =>              -- JRG (Reg,NUM,[reg],[n])
				If SR(ZR)='0' and (SR(NG)=SR(OV)) then	PC<=Z1; end if;
				rest2:=true;
			when "1110110" =>              -- JRSR (Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					AD<=ST;	AS<='0'; RW<='0'; Do<=PC; 
				when 1 =>
					DS<='0'; 
				when 2 =>
				when others =>
					ST<=ST-2; --DS<='1'; RW<='1'; AS<='1';
					PC<=Z1;
					rest2:=true;
				end case;	
			when "1110111" =>              -- JRBE (Reg,NUM,[reg],[n])
				If SR(ZR)='1' or SR(CA)='1' then	PC<=Z1; end if;
				rest2:=true;
			when "1111000" =>              -- JRLE (Reg,NUM,[reg],[n])
				If SR(ZR)='1' or (SR(NG)/=SR(OV)) then	PC<=Z1; end if;
				rest2:=true;
			when "1111001" =>              -- JRNZ (Reg,NUM,[reg],[n])
				if SR(ZR)='0' then	PC<=Z1; end if;
				rest2:=true;
			when "1111010" =>              -- JRA (Reg,NUM,[reg],[n])
				If SR(ZR)='0' and SR(CA)='0' then PC<=Z1; end if;
				rest2:=true;
			when "1111011" =>              -- MOVR Reg,([n],[R])  MOVR.B Reg,([n],[R])  GADR
				case TT is
				when 0 =>
					AD<=Z1;	AS<='0'; --RW<='1';
				when 1=>
				when others =>
					if fetch2 then	tmp:=Di; else tmp:=Z1;	end if;
					set_reg(r1,tmp,bwb,'0');       
					rest2:=true;	--AS<='1';
				end case;
			when "1111100" =>              -- MOVR MOVR.B([n],[R]),Reg	   
				case TT is
				when 0 =>
					AD<=Z1;  --RW<='1'; 
					if bwb='0' then rest:=true; FF<=StoreState; else AS<='0'; end if;
				when 1 =>
				when others =>
					if AD(0)='1' then	
						Y1(15 downto 8)<=Di(15 downto 8);
					else 
						Y1<= Y1(7 downto 0) & Di(7 downto 0);
					end if;
					AS<='1';	rest:=true; FF<=StoreState;
				end case;
			when "1111101" =>   -- JRGE ! 		
				If SR(ZR)='1' or (SR(NG)=SR(OV)) then	PC<=Z1; end if;  
			   rest2:=true;
			when "1111110" =>              -- JRL (Reg,NUM,[reg],[n])
				If  (SR(NG)/=SR(OV)) then PC<=Z1; end if;
				rest2:=true;
			when "1111111" =>              --JRX 
				if IDX/=ZERO16 then PC<=Z1; end if;
				IDX<=IDX-1;
				rest2:=true;
			when others => -- instructions  NOP	
				rest2:=true;
			end case;
			
		when others => -- FF="111" write Y1 to mem in AD
 			case TT is
			when 0 =>
				AS<='0'; RW<='0'; Do<=Y1;
				DS<='0'; 
			when	1 =>
			when others =>	
				--DS<='1'; AS<='1'; RW<='1';
				rest2:=true;
			end case;
		end case;
		----------------------------------------------------------------
		if (rest=true) or (rest2=true) then
			TT<=0;
			if rest2=true then 
				RW<='1'; IO<='0'; DS<='1'; AS<='1';
				if SR(5)='1' and IR(15 downto 9)/="1000010"  then  -- SR(5) = trace flag reti
					IR<="1000001000111100";  --INT 
					FF<=ExecutionState;
				else	
					FF<=InitialState;
				end if;
			end if;
		else
			TT<=TT+1;
		end if;
	--ELSIF	Clock'EVENT AND Clock = '0'  THEN
	END IF ;
end Process;

end Behavior;


