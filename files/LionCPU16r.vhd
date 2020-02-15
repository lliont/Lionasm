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
		ADo  : OUT  Std_logic_vector(15 downto 0); 
		RW,AS,DS : OUT Std_logic;
		RD, Reset, Clock, Int, HOLD: IN Std_Logic;
		IO,HOLDA, A16o,A17o,A18o : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK : OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0);
		BACS: OUT std_logic
	);
end LionCPU16;

Architecture Behavior of LionCPU16 is
constant CA:natural:=0; 
constant OV:natural:=1;
constant ZR:natural:=2;
constant NG:natural:=3; 
constant JXAD:natural:=4;  
constant TRAP:natural:=5;
constant INT_DIS:natural:=6;  

constant ZERO8 : std_logic_vector(7 downto 0):= (OTHERS => '0');
constant ZERO16 : std_logic_vector(15 downto 0):= (OTHERS => '0');
constant ONE16: std_logic_vector(15 downto 0) := "0000000000000001";
constant TWO16: std_logic_vector(15 downto 0) := "0000000000000010";
constant InitialState:Std_logic_vector(2 downto 0):="000";
constant FetchState:Std_logic_vector(2 downto 0):="001";
constant Fetch2State:Std_logic_vector(2 downto 0):="010";
constant IndirectState:Std_logic_vector(2 downto 0):="011";
constant RelativeState:Std_logic_vector(2 downto 0):="100";
constant ExecutionState:Std_logic_vector(2 downto 0):="110";
constant StoreState:Std_logic_vector(2 downto 0):="111";

SIGNAL IDX: Std_logic_vector(15 downto 0):=ZERO16;
SIGNAL PC,X2,Ao,AoII: Std_logic_vector(15 downto 0);
SIGNAL RPC:Std_logic_vector(15 downto 0):="0000000000010000";
SIGNAL Z1: Std_logic_vector(15 downto 0):=ZERO16;
SIGNAL SR: Std_logic_vector(15 downto 0):=ZERO16;
SIGNAL ST: Std_logic_vector(15 downto 0):="1111111111111110";
SIGNAL FF: Std_logic_vector(2 downto 0):=InitialState;
SIGNAL TT: natural range 0 to 15;
SIGNAL carry, overflow, zero, neg: Std_logic;
SIGNAL fetch,fetch1,fetch2,fetch3,mem_trans: boolean;
--SIGNAL ds, as: Std_logic;

COMPONENT ALU_LA4 IS
PORT (X, Y 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		Z 		: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
		sub, half, cin: IN STD_LOGIC ;
		carry,overflow,zero,neg: OUT STD_LOGIC ) ;
END COMPONENT ;

COMPONENT regs IS
PORT (Ai : IN STD_logic_vector(15 downto 0);
		Ao, AoII : OUT STD_logic_vector(15 downto 0);
		clk,Wen,half: IN Std_logic;
		R,RR: IN std_logic_vector(2 downto 0) ) ;
END COMPONENT;

shared variable Do,AD,X1,Y1,X,Y,Ai,IR,ODP: Std_logic_vector(15 downto 0):=ZERO16;
shared variable cin,Wen,sub,half,rhalf,A16,A17,A18: Std_logic;
shared variable M : Std_logic_vector(31 downto 0);
shared variable R,RR: std_logic_vector(2 downto 0);
shared variable rest,rest2,rest3,rel,setreg:boolean:=false;
shared variable tmp,tmp2,stmp,mtmp:Std_logic_vector(15 downto 0);
shared variable r1,r2: Std_logic_vector(2 downto 0);
shared variable bt, icnt: natural range 0 to 15;
shared variable bwb :Std_logic; --  bit to distinguish between word byte operations 

procedure set_reg(ri:Std_logic_vector(2 downto 0); v: std_logic_vector; b: std_Logic:='0'; f:std_logic:='1') is
begin
	R:=ri; Ai:=v; rhalf:=not b; 	
	if b='1' then
		if f='1' then
			if v(7 downto 0) = ZERO8 then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
			SR(NG)<=V(7);
		end if;
	else
		if f='1' then
			if v = ZERO16 then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
			SR(NG)<=V(15);
		end if;
	end if;
	Wen:='1';
end set_reg;

procedure set_code is
begin
	A18:=SR(15);
	A17:=SR(14);
	A16:=SR(13);
end set_code;

procedure set_data is
begin
	A18:=SR(12);
	A17:=SR(11);
	A16:=SR(10);
end set_data;

procedure set_stack is
begin
	A18:=SR(9);
	A17:=SR(8);
	A16:=SR(7);
end set_stack;

procedure set_flags is
begin
	SR(3 downto 0) <= neg & zero & overflow & carry ;
end set_flags;

begin
	ALU: ALU_LA4
	PORT MAP ( X1,Y1,Z1, sub, half, cin, carry, overflow, zero, neg ) ;
	REG:REGs
	PORT MAP ( Ai,Ao,AoII,clock,Wen,rhalf,R,RR ) ;	

DOo<=Do; 
ADo<=AD;
A16o<=A16;
A17o<=A17;
A18o<=A18; 

Process (Clock,RD,RESET)

procedure init_next_ins is 
begin
	 HOLDA<='0';	AD:=PC; half:='0';   stmp:=ST+2; rest2:=false;
	AS<='0'; sub:='0'; cin:='0';  setreg:=true; set_code;
	fetch<=false; fetch1<=false; fetch2<=false; mem_trans<=false;
	PC<=PC+2; mtmp:=ST-2; BACS<='0';
end init_next_ins;

begin
IF rising_edge(clock) THEN
	IF Reset = '1' THEN
		PC<="0000000000010000"; SR<="0000000000100000";  HOLDA<='0'; FF<=InitialState; TT<=0;
		AS<='1';  DS<='1'; RW<='1'; ST<="1111111111111110"; IO<='0'; rest3:=false;
		A16:='0'; A17:='0'; A18:='0'; rest2:=false; IA<="00"; IACK<='0'; icnt:=0; BACS<='0';
	ELSIF HOLD='0' AND (rest2=true)  then
		HOLDA<='1'; 
	ELSIF RD='0' then
		
	ELSIF (INT='0') and (rest2=true or rest3=true)  and (SR(INT_DIS)='0') and (IACK='0') THEN   -- Interrupts
		mtmp:=ST-2; FF<=ExecutionState; IA<=I; IACK<='1'; IR:="100000100000"&I&"00";
		HOLDA<='0'; rest2:=false; Wen:='0'; setreg:=true;  
		if rest3=true then PC<=PC-2; TT<=0; rest3:=false; end if;
	ELSIF SR(TRAP)='1' and IR(15 downto 9)/="1000010" and (rest2=true or rest3=true) then  -- SR(5) = trace flag reti
		IR:="1000001000111100";  --INT 15
		HOLDA<='0'; rest2:=false; mtmp:=ST-2; FF<=ExecutionState; Wen:='0'; 
		if rest3=true then PC<=PC-2; TT<=0; rest3:=false; end if;
	ELSE
		rest:=false;   
		case  FF is 
		when InitialState =>      -- Fetch Instruction 
			case TT is
			when 0 =>
				init_next_ins;  rhalf:='0'; Wen:='0';  rest3:=false;
			when others => 
				AS<='1'; rest:=true; rhalf:='0'; Wen:='0';  rest3:=false; BACS<='0';
				IR:=Di; RR:=Di(4 downto 2); R:=Di(8 downto 6);
				bt:=to_integer(unsigned(Di(5 downto 2)));
				bwb:=Di(5); rel:=(Di(15 downto 13)="111");  
				fetch3<=(Di(15 downto 12)="1100"); r2:=Di(4 downto 2); r1:=Di(8 downto 6);	
				if Di(0)='1' then 
					FF<=FetchState; AD:=PC; AS<='0'; 
				else 
					if Di(1)='1' then	FF<=IndirectState;
					else 
						if rel then FF<=RelativeState; else FF<=ExecutionState; end if;
					end if;
				end if;
			end case;
		when FetchState =>              -- Fetch next word into X
			case TT is 
			when 0 =>
				fetch1<=true; fetch<=true; PC<=PC+2; 
			when others =>
				X:=Di;  AS<='1'; 
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
				AD:=PC;  AS<='0';
			--when 1 =>
			when others =>
				Y:=Di; AS<='1'; 
				if IR(1)='1' then	FF<=IndirectState; else FF<=ExecutionState;	end if;
				rest:=true;
				PC<=PC+2; 
			end case;
		when IndirectState =>              -- indirect
			X1:=Ao;	Y1:=AoII;
			case TT is
			when 0 =>
				fetch2<=true; fetch<=true; AS<='0';  set_data;
				if IR(0)='1' then	AD:=X; X2<=X; else AD:=Y1; X2<=y1; end if;
			--when 1 =>  -Cyclone IV
			when others =>
				if X2(0)='0' and bwb='1' and (not rel) then
					X(7 downto 0):=Di(15 downto 8);
					X(15 downto 8):=Di(7 downto 0);
				else
					X:=Di; 
				end if;
				AS<='1';	set_code; FF<=ExecutionState;
				rest:=true;
			end case;
		when RelativeState =>              -- relative
			X1:=Ao;	Y1:=AoII;
			if fetch then RPC<=PC+X; else RPC<=PC+X1; end if;
			if IR(1)='1' then FF<=IndirectState; else FF<=ExecutionState; end if;
			rest:=true; 
		when ExecutionState =>        --- F="110" Operation execution cycles   
			if TT=0 and not mem_trans then X1:=Ao;	Y1:=AoII; end if;
			case IR(15 downto 9) is
			when "0000000" =>              -- NOP
					rest3:=true;
			when "0000001" =>              -- MOV MOV.B Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp:=X; else tmp:=Y1; end if;
				set_reg(r1,tmp,bwb,'0');
				rest3:=true;
			when "0000010" =>              -- MOV MOV.B <Reg>,(Reg,NUM,[reg],[n])
				AD:=X1;  set_data;
				if fetch then Y1:=X;	end if;
				if bwb then BACS<='1'; end if;
				FF<=StoreState;
				rest:=true;
--			when "0001100" =>           -- MOV.B <Reg>,(Reg,NUM,[reg],[n])
--				case TT is
--				when 0 =>
--					AD:=X1 ; AS<='0';  set_data;
				--when 1 =>
--				when others =>
--					if AD(0)='1' then	
--						if  fetch then	Y1:=Di(15 downto 8) & X(7 downto 0);
--						else	Y1(15 downto 8):=Di(15 downto 8); end if;
--					else 
--						if  fetch then	Y1:= X(7 downto 0) & Di(7 downto 0);
--						else	Y1:= Y1(7 downto 0) & Di(7 downto 0);	end if;
--					end if;
--					if  fetch then	Y1:=X; end if; BACS<='1';
--					AS<='1';	rest:=true; FF<=StoreState;
				--end case;
			when "0000011" =>              --ADD & ADD.B Reg,(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					if fetch=true then Y1:=X; end if;
					half:=bwb;
				--when 1 =>
				when others =>
					rest3:=true;
					if setreg then set_reg(r1,Z1,bwb,'0'); end if;
					set_flags;
					sub:='0'; cin:='0';
				end case;
			when "0000100" =>              --SUB & SUB.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then Y1:=X; end if;
				sub:='1'; half:=bwb;
				IR(15 downto 9):="0000011"; -- continue as in ADD
				
			when "0000101" =>              --ADC Reg,(Reg,NUM,[reg],[n])
				if fetch then	Y1:=X;	end if;
				half:=bwb ; cin:=SR(CA); 
				IR(15 downto 9):="0000011"; -- continue as in ADD
				
			when "0000111" =>              -- OUT (n,Reg),Reg	
				case TT is
				when 0 =>
					Do:=Y1; 
					if fetch then AD:=X; else AD:=X1; end if;
					RW<='0';	IO<='1'; AS<='0'; DS<='0';   	
				when 1 =>
				when others =>
					rest3:=true;
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
					if fetch then
						if bwb='0' then
							M:=std_logic_vector(unsigned(X1) * unsigned(X));
						else
							M:=std_logic_vector(unsigned("00000000"&X1(7 downto 0)) * unsigned("00000000"&X(7 downto 0)));
						end if;
					else 
						if bwb='0' then
							M:=std_logic_vector(unsigned(X1) * unsigned(Y1));
						else
							M:=std_logic_vector(unsigned("00000000"&X1(7 downto 0)) * unsigned("00000000"&Y1(7 downto 0)));
						end if;
					end if;				
				when 1 =>
					SR(CA)<='0'; SR(NG) <= '0';
					if bwb='1' then 
						SR(OV) <='0'; --neg & zero & overflow & carry
						if M(15 downto 0) = ZERO16 then SR(ZR) <= '1'; else SR(ZR) <='0'; end if;
					else
						if not fetch then	SR(OV) <=  '0';
						else
							if M(31 downto 16)=ZERO16 then SR(OV) <= '0'; 
							else SR(OV)<='1';	end if;
						end if;
						if (M(15 downto 0) OR M(31 downto 16)) = ZERO16 then SR(ZR) <= '1'; else SR(ZR) <='0'; end if;
					end if;
					set_reg(r1,M(15 downto 0),'0','0'); 
					rest2:=fetch or bwb='1';
				when 2 =>
					Wen:='0';	
				when others =>
					rest3:=true;
					set_reg(r2,M(31 downto 16),'0','0');
				end case;
 

			when "0001101" =>               -- CMP & CMP.B (n),Reg
				half:=bwb;
				X1:=X; --if fetch then X1:= X; end if;
				sub:='1'; 
				setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD
			when "0001110" =>              --CMP & CMP.B Reg,(Reg,NUM,[reg],[n])
				half:=bwb;
				if fetch then Y1:=X;	end if;
				sub:='1'; 
				setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD
			when "0001111" =>              --AND & AND.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 AND X; else tmp:=X1 AND Y1; end if;
				set_reg(r1,tmp,bwb);
				rest3:=true;
			when "0010000" =>              --OR & OR.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 OR X; else tmp:=X1 OR Y1; end if;
				set_reg(r1,tmp,bwb);
				rest3:=true;
			when "0010001" =>              --XOR & XOR.B Reg,(Reg,NUM,[reg],[n])
				if fetch=true then tmp:=X1 XOR X; else tmp:=X1 XOR Y1; end if;
				set_reg(r1,tmp,bwb);
				rest3:=true;	
			when "0010010" =>              --NOT & NOT.B Reg
				tmp:= NOT X1;
				set_reg(r1,tmp,bwb);
				rest3:=true;
			when "0010011" =>              -- SETX (Reg,NUM,[reg],[n])
				if fetch then tmp:=X; else	tmp:=Y1; end if;
				IDX<=tmp;
				rest3:=true;
			when "0010100" =>              --JMPX 
				if fetch then	tmp:=X; else tmp:=Y1; end if;
				if IDX/=ZERO16 then PC<=tmp; end if;
				IDX<=IDX-1;
				rest2:=true;
			when "0010101" =>              -- MOVX RegA
				tmp:=IDX;
				set_reg(r1,tmp,'0','0');
				rest3:=true;
			when "0010110" =>              -- BTST  R,n
				if X1(bt)= '0' then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
				rest3:=true;
			when "0010111" =>              -- BSET  R,n
				tmp:=X1;	tmp(bt):='1';	set_reg(r1,tmp,'0','0'); 
				rest3:=true;
			when "0011000" =>              -- BCLR  R,n
				tmp:=X1;	tmp(bt):='0'; set_reg(r1,tmp,'0','0'); 
				rest3:=true;
			when "0001011" =>              -- BTST  R,R
				if X1(to_integer(unsigned(Y1(3 downto 0))))= '0' then SR(ZR)<='1'; else SR(ZR)<='0';  end if;
				rest3:=true;
			when "1010001" =>              -- BSET  R,R
				tmp:=X1;	tmp(to_integer(unsigned(Y1(3 downto 0)))):='1';	set_reg(r1,tmp,'0','0'); 
				rest3:=true;
			when "0011110" =>              -- BCLR  R,R
				tmp:=X1;	tmp(to_integer(unsigned(Y1(3 downto 0)))):='0'; set_reg(r1,tmp,'0','0'); 
				rest3:=true;						
			when "0011001" =>              --SRA Reg
				tmp:= std_logic_vector(shift_right(signed (X1),bt));
				set_reg(r1,tmp); 
				SR(CA)<=X1(bt-1);
				rest3:=true;
			when "0011010" =>              --SLA Reg
				tmp:= std_logic_vector(shift_left(signed (X1),bt));
				set_reg(r1,tmp); --A(r1)<=tmp; 
				--SR(CA)<=X1(16-bt);
				rest3:=true;
			when "0011011" =>              --SRL Reg
				SR(CA)<=X1(bt-1);
				tmp:= std_logic_vector(shift_right(unsigned (X1),bt));
				set_reg(r1,tmp);  
				rest3:=true;
			when "0011100" =>              --SLL Reg
				SR(CA)<=X1(16-bt);
				tmp:= std_logic_vector(shift_left(unsigned (X1),bt));
				set_reg(r1,tmp);  
				rest3:=true;
			when "0011111" =>  -- XCHG r1,r2
				case TT is
				when 0 =>
					set_reg(r2,X1,'0','0');
				when 1 =>
					Wen:='0';
				when others =>
					set_reg(r1,Y1,'0','0');
					rest3:=true;
				end case;	
			when "0100000" =>              -- MOVI Reg,0-15
				tmp:="000000000000"&IR(5 downto 2);
				set_reg(r1,tmp,'0','0');
				rest3:=true;
			when "0100001" =>               -- CMP & CMP.B (R),(Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					half:=bwb;
					IF fetch then Y1:= X; end if; 
					AD:=X1; AS<='0';
				when 1 =>
				--when 2 =>
					if bwb='1' then
						if X1(0)='1' then X1(7 downto 0):=Di(7 downto 0);
						             else X1(7 downto 0):=Di(15 downto 8); end if;
					else
						X1:=Di;
					end if;
					sub:='1'; AS<='1'; 
				when others =>
				--when 4 =>
				rest3:=true; sub:='0';
				set_flags;	
				end case;
			when "0100010" =>              -- MOVI.B Reg,0-15
				tmp(7 DOWNTO 0):="0000"&IR(5 downto 2);
				set_reg(r1,tmp,'1','0'); --A(r1)<=tmp;
				rest3:=true;		
			when "0100101" =>              -- JMP (Reg,NUM,[reg],[n])
				if fetch then PC<=X;
				else	PC<=Y1; end if;
				rest2:=true;
			when "0100110" =>              -- SRSET SRCLR n
				SR(to_integer(unsigned(IR(5 downto 2))))<=IR(8); 
				rest3:=true;
			when "0100111" =>              -- JZ & JNZ (Reg,NUM,[reg],[n])
				If SR(ZR)=bwb then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;
			when "0101001" =>              -- JO & JNO (Reg,NUM,[reg],[n])
				If SR(OV)=bwb then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;       
			when "0101011" =>              -- JC,JB & JNC (Reg,NUM,[reg],[n])
				If SR(CA)=bwb then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;        
			when "0101101" =>              -- JN & JP (Reg,NUM,[reg],[n])
				If SR(NG)=bwb then
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
				half:='1';
				Y1:="000000000000"&IR(5 downto 2);
				sub:='1'; 
				setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD
				
			when "0110001" =>              -- JL (Reg,NUM,[reg],[n])
				If  (SR(NG)/=SR(OV)) then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;
         when "0110010" =>              --CMPHL Reg,(Reg,NUM,[reg],[n])
				half:='1';
				X1(7 downto 0):=X1(15 downto 8);
				if fetch then Y1:=X;	end if;
				sub:='1'; setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD
       
			when "0110101" =>              -- JSR Reg  /NUM / <reg>/<n>
				case TT is
				when 0 =>
					AD:=ST;	AS<='0'; RW<='0';  Do:=PC;	DS<='0'; set_stack;
				--when 1 =>
				when others =>
					ST<=mtmp; --ST-2; 
					if fetch then PC<=X; else	PC<=Y1; end if;
					rest2:=true;
				end case;
			when "0110110" =>              --ROL Reg
				tmp:= std_logic_vector(shift_left(unsigned (X1),bt));
				tmp(0):=X1(bt-1);
				set_reg(r1,tmp);  
				rest3:=true;            
			when "0110111" =>              -- RET
				case TT is
				when 0 =>
					ST<=stmp; set_stack; --ST+2; 
				--when 1 =>
					AD:=stmp; AS<='0';  
				--when 1 =>
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
				AD:=ST; 	set_stack;
				if fetch then Y1:=X; else Y1:=X1; end if;
				ST<=mtmp;  FF<=StoreState;
				rest:=true;
			when "0111101" =>              -- PUSHX | SR
					AD:=ST;	
					if bwb='0' then Y1:=IDX; else Y1:=SR; end if;
					ST<=mtmp; set_stack;
					rest:=true; FF<=StoreState;
			when "0111110" =>              -- POPX | POPSR
				case TT is
				when 0 =>
					AD:=stmp;	AS<='0'; set_stack;
				--when 1 =>
					ST<=stmp;
				when others =>
					if bwb='0' then IDX<=Di; else SR<=Di; end if;
					rest3:=true;
				end case;

			when "1000000" =>              -- POP Rn
				case TT is
				when 0 =>
					  AD:=stmp; AS<='0'; set_stack;
				--when 1 =>
						ST<=stmp;
				when others =>
					tmp:=Di;
					set_reg(r1,tmp,'0','0');
					rest3:=true;
				end case;		
			when "1000001" =>              -- INT n  don't change opcode
				case TT is
				when 0 =>
					AD:=ST; Do:=PC; RW<='0'; Wen:='0'; set_stack;
					AS<='0'; DS<='0';  icnt:=icnt+1;
				when 1 => 
				--when 2 =>
					AS<='1';  DS<='1'; RW<='1';
				when 2 =>
					AD:=mtmp; Do:=SR;
					AS<='0'; DS<='0';  RW<='0'; SR(INT_DIS)<='1'; 
				--when 4 =>
					ST<=mtmp-2;  
				when 3 =>
					RW<='1'; AS<='1'; DS<='1';  
				when 4 =>
					AD:="00000000000"&IR(5 downto 2)&"0"; 
					AS<='0'; 
				--when 7 =>
				when others =>
					PC<=Di; SR(TRAP)<='0'; SR(15 downto 13)<="000"; 
					A16:='0'; A17:='0'; A18:='0';
					rest2:=true; 
				end case;
			when "1000010" =>              -- RETi  PRET don't change opcode
				case TT is
				when 0 =>
					AD:=stmp; AS<='0';   set_stack;
				when 1 =>
					--ST<=stmp;
				--when 2 =>
					 ST<=stmp+2;   AS<='1';
					if bwb='0' then SR<=Di; else SR(15 downto 13)<=Di(15 downto 13); end if;
				when 2 =>
					AD:=ST;	AS<='0';  
				--when 4 =>
				when others =>	
					PC<=Di; 
					if bwb='0' then icnt:=icnt-1; IA<="11"; IACK<='0'; end if;
					rest2:=true;
				end case;
			when "1000011" =>              -- CLI STI
					SR(INT_DIS)<=bwb;
					rest3:=true;
			when "1000101" =>   -- GETSP / MOV An,SP
				set_reg(r1,ST,'0','0');
				rest3:=true;
			when "1000110" =>              -- IN Reg, (Reg, n)
				case TT is
				when 0 =>
					--RW<='1'; 
					if fetch then AD:=X; else	AD:=Y1;	end if;
					 AS<='0';   IO<='1';
				when 1 =>
				when others =>
					if (bwb='1') and (AD(0)='0') then
						tmp(7 downto 0):=Di(15 downto 8);
					else
						tmp:=Di;
					end if;
					set_reg(r1,tmp,bwb,'0'); --AS<='1'; 
					rest3:=true;
				end case;
			when "1000111" | "1001000" =>              -- INC DEC & INC.B DEC.B Rn
				Y1:="0000000000000001";
				sub:= NOT IR(9);
				half:=bwb;
				IR(15 downto 9):="0000011"; -- continue as in ADD	
			when "1001001" =>              -- MOV MOV.B (n),Reg 
					AD:=X; FF<=StoreState; set_data;
					BACS<=bwb;
					rest:=true;
--			when "1001010" =>              -- MOV.B (n),Reg	
--					AD:=X2 ;  set_data;
--					if X2(0)='1' then	
--						tmp:=X(15 downto 8)&Y1(7 downto 0);
--					else 
--						tmp:=Y1(7 downto 0) & X(15 downto 8);
--					end if;
--					Y1:=tmp;
--					rest:=true; FF<=StoreState;    
			when "1001100" =>              -- MOVHL Reg,(Reg,NUM,[reg],[n])
				if fetch2 then
					if X2(0)='1'  then tmp:=X(7 downto 0)&X1(7 downto 0);
								  else tmp:=X(15 downto 8)&X1(7 downto 0);	end if;
				else
					if fetch1 then	tmp:=X(7 downto 0)&X1(7 downto 0);
								 else tmp:=Y1(7 downto 0)&X1(7 downto 0); end if;
				end if;
				set_reg(r1,tmp,'0','0'); 
				rest3:=true;
			when "1001101" =>              -- MOVLH Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp(7 downto 0):=X(15 downto 8);
				   		 else tmp(7 downto 0):=Y1(15 downto 8); end if;
				set_reg(r1,tmp,'1','0'); 
				rest3:=true;
			when "1001110" =>              -- MOVHH Reg,(Reg,NUM,[reg],[n])
				if fetch then	tmp:=X(15 downto 8)&X1(7 downto 0);
				else tmp:=Y1(15 downto 8)&X1(7 downto 0); end if;
				set_reg(r1,tmp,'0','0'); 
				rest3:=true;
			when "1001111" =>              --SRL.B Reg
				tmp(7 downto 0):= std_logic_vector(shift_right(unsigned (X1(7 downto 0)),bt));
				set_reg(r1,tmp,'1'); 
				SR(CA)<=X1(bt-1);
				rest3:=true;
			when "1010000" =>              --SLL.B Reg
				tmp(7 downto 0):=  std_logic_vector(shift_left(unsigned (X1(7 downto 0)),bt));
				set_reg(r1,tmp,'1');  
				SR(CA)<=X1(8-bt);
				rest3:=true; 
			when "1010010" =>              --CMPI Reg,(0-15)
				Y1:="000000000000"&IR(5 downto 2);
				sub:='1'; 
				setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD
			when "1010011" =>              --SUBI Reg,0-15   1011001-6275
				Y1:="000000000000"&IR(5 downto 2);
				sub:='1'; bwb:='0';
				IR(15 downto 9):="0000011"; -- continue as in ADD			
			when "1010100" =>              --ADDI Reg,0-15
				Y1:="000000000000"&IR(5 downto 2);
				bwb:='0';
				IR(15 downto 9):="0000011"; -- continue as in ADD
			when "1010101" =>              -- NEG Rn
				tmp:=X1;
				X1:=NOT tmp;
				Y1:=ONE16;
				half:=bwb;
				IR(15 downto 9):="0000011"; -- continue as in ADD
			when "1010110" =>              -- OUT Reg,n	
				Do:=X; AD:=X1; RW<='0'; IO<='1'; AS<='0';  DS<='0';
				IR(15 downto 9):="0000111"; -- continue as in OUT n,ax
			when "1010111" =>              -- OUT.B (Reg,n),Reg	
				case TT is
				when 0 =>
					if fetch then AD:=X; else AD:=X1; end if;
					IO<='1'; RW<='1'; AS<='0'; 
				when 1 =>
				when 2 =>
					if AD(0)='0' then
						Do:=Y1(7 downto 0)&Di(7 downto 0);
					else
						Do:=Di(15 downto 8)&Y1(7 downto 0);
					end if;
					RW<='0'; DS<='0'; 
				--when 3 =>
				when others =>
					rest3:=true;
				end case;
			when "1011000" =>                     -- OUT.B Reg,n	
					AD:=X1; Y1:=X; IO<='1'; AS<='0'; 
					IR(15 downto 9):="1010111";  -- as OUT.B	
			when "1001011" =>    --SLLL Reg
			      case TT is
					when 0 =>
						SR(CA)<=X1(15);
						tmp:=X1(14 downto 0)&Y1(15);
						set_reg(r1,tmp); 
					when 1 => 
						Wen:='0';
					when others =>
						tmp:=Y1(14 downto 0)&"0";
						set_reg(r2,tmp);		
						rest3:=true;  
					end case;
			when "1011001" =>              --SRLL Reg
				   case TT is
					when 0 =>
						tmp:="0"&X1(15 downto 1);
						set_reg(r1,tmp);
						SR(CA)<=Y1(0);
					when 1 =>
						Wen:='0';
					when others =>
						tmp:=X1(0)&Y1(15 downto 1);  
						set_reg(r2,tmp);		
						rest3:=true;
					end case;
			when "1011100" | "1011101" =>              -- ADD SUB [n],reg  ADD.B [n],reg
				X1:=X; sub:=IR(9); 
				half:=bwb;	AD:=X2;
				IR(15 downto 9):="1100100"; -- continue ADD [n],n	
			when "1011110" | "1011111" =>              -- ADD SUB [reg],reg  ADD.B [reg],reg
				X1:=AoII;  Y1:=X; -- assembler reverses X1,Y1 
				sub:=IR(9); 
				half:=bwb; AD:=X2;
				IR(15 downto 9):="1100100"; -- continue ADD [n],n	
			when "1011010" | "0110100" =>              -- ADD SUB [reg],n  ADD.B [reg],n 
				case TT is
				when 0 =>
					Y1:=X; AD:=X1; AS<='0'; half:=bwb;
				when 1 =>
				--when 2 => 
					X1:=Di; sub:= NOT IR(10); AS<='1'; 
				--when 3 =>
				when others  =>
					if half='1' then 
						if X2(0)='0' then 
							Y1:=Z1(7 downto 0)&X(15 downto 8);
						else 
							Y1:=X(15 downto 8)&Z1(7 downto 0);
						end if;
					else 
						Y1:=Z1;
					end if;    
					set_flags;	FF<=StoreState; set_data;	rest:=true;
					sub:='0';
				end case;
				
			when "0100011" =>              -- JGE (Reg,NUM,[reg],[n])
				If SR(ZR)='1' or (SR(NG)=SR(OV)) then
					if fetch then PC<=X;
					else	PC<=Y1; end if;
				end if;
				rest2:=true;  

			when "1011011" | "0111010" =>              --ADD SUB SP,(Reg,NUM,[reg],[n])
					rest2:=true;
					if fetch then tmp:=X; else tmp:=Y1; end if;
					if IR(9)='1' then ST<=ST+tmp; else ST<=ST-tmp; end if;
			when "0110011" =>   --JXAB JXAW
					IDX<=IDX-1;	
					if (IDX/=ZERO16) then 
						if fetch then PC<=X; else PC<=Y1; end if;
						if SR(JXAD)='0' then  tmp:=X1+2-bwb; else tmp:=X1-2+bwb; end if;
						set_reg(r1,tmp,'0','0'); 
					end if;
					rest2:=true;
				
			when "0101000" =>  -- pmov .b An1,(An2,address)
				case TT is
				when 0 =>
					if fetch then AD:=X; else	AD:=Y1;	end if;
					AS<='0'; A16:=ODP(0);  A17:=ODP(1); A18:=ODP(2);
				--when 1 =>
				when others =>
					if (bwb='1') and (AD(0)='0') then
						tmp(7 downto 0):=Di(15 downto 8);
					else
						tmp:=Di;
					end if;
					set_reg(r1,tmp,bwb,'0');
					rest3:=true;
				end case;
			when "0101100" => -- pmov .b (address,An1),An2
				case TT is
				when 0 =>
					if fetch then AD:=X; else AD:=X1; end if;
					A16:=ODP(0);  A17:=ODP(1); A18:=ODP(2); AS<='0';  
				--when 1 =>
				when 1 =>
					if bwb='0' then Do:=Y1; else
						if AD(0)='0' then
							Do:=Y1(7 downto 0)&Di(7 downto 0);
						else
							Do:=Di(15 downto 8)&Y1(7 downto 0);
						end if;
					end if;
				   AS<='1'; 
				when 2 =>
					RW<='0'; AS<='0';  DS<='0'; 
				--when 4 =>
				when others =>
					rest3:=true;
				end case;
			when "0000110" =>  -- SODP SDP SSP An | SSP n 
				case bt is
					when 0 =>
						ODP:="0000000000000"&X1(2 downto 0);
					when 1 =>
						SR(9 downto 7)<=X1(2 downto 0);
					when 2 =>
						SR(12 downto 10)<=X1(2 downto 0);
					when 8 to 15 =>
						SR(9 downto 7)<=IR(4 downto 2);
					when others =>
				end case;
				rest3:=true;
			when "0100100" =>     --SDP n | SODP n
				if bwb='0' then
					SR(12 downto 10)<=IR(4 downto 2);
				else
					ODP:="0000000000000"&IR(4 downto 2);
				end if;
				rest3:=true;
			when "0111100" => -- PJMP An1,An2 | PJMP A1,n
				if bwb='1' then
					SR(15 downto 13)<=Y1(2 downto 0);
				else
					SR(15 downto 13)<=IR(4 downto 2);
				end if;
				if fetch then PC<=X; else PC<=X1; end if;
				rest2:=true;
			when "1000100" =>       --PJSR (An1 | address),(An2 | n 0..7)
				case TT is
				when 0 =>
					AD:=ST; Do:=PC; RW<='0'; set_stack;
					AS<='0'; DS<='0';  
				when 1 => 
				--when 2 =>
					AS<='1';  DS<='1'; RW<='1';
				when 2 =>
					AD:=mtmp; Do:=SR;
					AS<='0'; DS<='0';  RW<='0';  
				when 3 =>
					ST<=mtmp-2;  
				when others =>
					RW<='1'; AS<='1'; DS<='1';  
					if fetch then PC<=X;  else PC<=X1; end if;
					if bwb='1' then
						SR(15 downto 13)<=Y1(2 downto 0);
					else
						SR(15 downto 13)<=IR(4 downto 2);
					end if;
					rest2:=true; 
				end case;
			when "0111111" =>              -- MTOI An1,An2 | MTOM An1,An2
				case TT is
				when 0 =>
					IO<='0'; AD:=Y1; AS<='0'; RW<='1'; DS<='1'; mem_trans<=true; set_data;
				when 1 =>
				when 2 =>
					AD:=X1; RW<='0'; Do:=Di; IO<=bwb; AS<='0'; DS<='0';
				when others =>
					if (IDX/=ZERO16) then 
						IDX<=IDX-1;
						if SR(JXAD)='0' then
							X1:=X1+2;
							Y1:=Y1+2;
						else 
							X1:=X1-2;
							Y1:=Y1-2;
						end if;
						rest:=true;
					else
						rest3:=true;
					end if;
				end case;
			when "0101010" =>              -- NTOI An1,An2 NTOM An1,An2
				case TT is
				when 0 =>
					mem_trans<=true; set_data;
					if fetch then Do:=X; else Do:=Y1; end if;
					AD:=X1; RW<='0';  IO<=bwb; AS<='0'; DS<='0';
				when 1 =>
				when others =>
					AS<='0'; DS<='0'; RW<='1';
					if (IDX/=ZERO16) then 
						IDX<=IDX-1;
						if SR(JXAD)='0' then
							X1:=X1+2;
						else 
							X1:=X1-2;
						end if;
						rest:=true;
					else
						rest3:=true;
					end if;
				end case;
			when "1101000" =>              -- ITOI ITOM An1,An2 
				case TT is
				when 0 =>
					IO<='1'; AD:=Y1; AS<='0'; RW<='1'; DS<='1'; mem_trans<=true; set_data;
				when 1 =>
				when 2 =>
					AD:=X1; RW<='0'; Do:=Di; IO<=bwb; AS<='0'; DS<='0';
				when others =>
					if (IDX/=ZERO16) then 
						IDX<=IDX-1;
						if SR(JXAD)='0' then
							X1:=X1+2;
							Y1:=Y1+2;
						else 
							X1:=X1-2;
							Y1:=Y1-2;
						end if;
						rest:=true;
					else
						rest3:=true;
					end if;
				end case;
			when "1101001" =>              -- ITOI.B ITOM.B An1,An2 
				case TT is
				when 0 =>
					IO<='1'; AD:=Y1; AS<='0'; RW<='1'; DS<='1'; mem_trans<=true; set_data;
				when 1 =>
				when 2 =>
					if Y1(0)='0' then	tmp(7 downto 0):=Di(15 downto 8);
									 else	tmp(7 downto 0):=Di(7 downto 0); end if;
					AD:=X1; RW<='1'; IO<=bwb; AS<='0'; DS<='0';
				when 3 =>
				when 4 =>
					if X1(0)='0' then	Do:=tmp(7 downto 0)&Di(7 downto 0);
									 else	Do:=Di(15 downto 8)&tmp(7 downto 0); end if;
					AD:=X1; RW<='0'; IO<=bwb; AS<='0'; DS<='0';
				when others =>
					if (IDX/=ZERO16) then 
						IDX<=IDX-1;
						if SR(JXAD)='0' then
							X1:=X1+1;
							Y1:=Y1+1;
						else 
							X1:=X1-1;
							Y1:=Y1-1;
						end if;
						rest:=true;
					else
						rest3:=true;
					end if;
				end case;
				
			when "1101010" =>              -- MTOI.B An1,An2 | MTOM.B An1,An2
				case TT is
				when 0 =>
					IO<='0'; AD:=Y1; AS<='0'; RW<='1'; DS<='1'; mem_trans<=true; set_data;
				when 1 =>
				when 2 =>
					if Y1(0)='0' then	tmp(7 downto 0):=Di(15 downto 8);
									 else	tmp(7 downto 0):=Di(7 downto 0); end if;
					AD:=X1; RW<='1'; IO<=bwb; AS<='0'; DS<='0';
				when 3 =>
				when 4 =>
					if X1(0)='0' then	Do:=tmp(7 downto 0)&Di(7 downto 0);
									 else	Do:=Di(15 downto 8)&tmp(7 downto 0); end if;
					AD:=X1; RW<='0'; IO<=bwb; AS<='0'; DS<='0';
				when others =>
					if (IDX/=ZERO16) then 
						IDX<=IDX-1;
						if SR(JXAD)='0' then
							X1:=X1+1;
							Y1:=Y1+1;
						else 
							X1:=X1-1;
							Y1:=Y1-1;
						end if;
						rest:=true;
					else
						rest3:=true;
					end if;
				end case;
     
------instructions  between 1100... and 11010.... cause double fetch -----------------			

			when "1100000" =>              -- MOV (n),n
				AD:=X; Y1:=Y; FF<=StoreState; set_data;
				rest:=true;
			when "1100001" =>              -- MOV.B (n),n
				tmp:=X; 	AD:=X2; set_data;
				if X2(0)='1' then	
					Y1:=tmp(15 downto 8) & Y(7 downto 0);
				else 
					Y1:= Y(7 downto 0) & tmp(15 downto 8);
				end if;
				rest:=true; FF<=StoreState;
			when "1100010" =>               -- CMP & CMP.B (n),n
				Y1:=Y;
				half:=bwb;				
				X1:= X; 
				sub:='1'; 
				setreg:=false;
				IR(15 downto 9):="0000011"; -- continue as in ADD

			when "1100011" =>              -- OUT n,n	
					AD:=X; Do:=Y;  RW<='0'; IO<='1';  AS<='0';  DS<='0';
					IR(15 downto 9):="0000111"; -- continue as in OUT n,ax
					
			when "1100100" | "1100101" =>              -- ADD,SUB  [n],n  ADD.B, SUB.B [n],n
				case TT is
				when 0 =>
					X1:=X; Y1:=Y; 
					sub:=IR(9); half:=bwb;	AD:=X2; set_data;
				--when 1  =>
				when others =>
					if bwb='1' then 
						if X2(0)='0' then 
							Y1:=Z1(7 downto 0)&X(15 downto 8);
						else 
							Y1:=X(15 downto 8)&Z1(7 downto 0);
						end if;
					else 
						Y1:=Z1;
					end if;    
					set_flags;	FF<=StoreState;	rest:=true;
					sub:='0';
				end case;
				
		-----------    instructions after "111..." relative 
			when "1110000" =>              -- JR (Reg,NUM,[reg],[n])
				PC<=RPC; 
				rest2:=true;
			when "1110001" =>   --JRXAB JRXAW
				IDX<=IDX-1;	
				if (IDX/=ZERO16) then 
					PC<=RPC;
					if SR(JXAD)='0' then  tmp:=X1+2-bwb; else tmp:=X1-2+bwb; end if;
					set_reg(r1,tmp,'0','0'); 
				end if;
				rest2:=true;				
			when "1110010" =>              -- JRN (Reg,NUM,[reg],[n])
				if SR(NG)='1' then	PC<=RPC; 	end if;
				rest2:=true;
			when "1110011" =>              -- JRO (Reg,NUM,[reg],[n])
				if SR(OV)='1' then	PC<=RPC; end if;
				rest2:=true;
			when "1110100" =>              -- JRC (Reg,NUM,[reg],[n])
				if SR(CA)='1' then	PC<=RPC; end if;
				rest2:=true;
			when "1110101" =>              -- JRG (Reg,NUM,[reg],[n])
				If SR(ZR)='0' and (SR(NG)=SR(OV)) then	PC<=RPC; end if;
				rest2:=true;
			when "1110110" =>              -- JRSR (Reg,NUM,[reg],[n])
				case TT is
				when 0 =>
					AD:=ST;	AS<='0'; RW<='0'; Do:=PC; set_stack;
					DS<='0'; 
				when others =>
					ST<=mtmp; --ST-2; --DS<='1'; RW<='1'; AS<='1';
					PC<=RPC;
					rest2:=true;
				end case;	
			when "1110111" =>              -- JRBE (Reg,NUM,[reg],[n])
				If SR(ZR)='1' or SR(CA)='1' then	PC<=RPC; end if;
				rest2:=true;
			when "1111000" =>              -- JRLE (Reg,NUM,[reg],[n])
				If SR(ZR)='1' or (SR(NG)/=SR(OV)) then	PC<=RPC; end if;
				rest2:=true;
			when "1111001" =>              -- JRZ JRNZ (Reg,NUM,[reg],[n])
				if SR(ZR)=bwb then	PC<=RPC; end if;
				rest2:=true;
			when "1111010" =>              -- JRA (Reg,NUM,[reg],[n])
				If SR(ZR)='0' and SR(CA)='0' then PC<=RPC; end if;
				rest2:=true;
			when "1111011" =>              -- MOVR Reg,([n],[R])  MOVR.B Reg,([n],[R])  GADR
				case TT is
				when 0 =>
					AD:=RPC;	AS<='0'; set_data; --RW<='1'; 
				--when 1=>
				when others =>
					rest3:=true;
					if fetch2 then	tmp:=Di; else tmp:=RPC;	end if;
					set_reg(r1,tmp,bwb,'0');   --AS<='1';
				end case;
			when "1111100" =>              -- MOVR MOVR.B([n],[R]),Reg	   
				AD:=RPC; set_data; --RW<='1'; 
				BACS<=bwb;
				AS<='1';	rest:=true; FF<=StoreState;
			when "1111101" =>   -- JRGE ! 		
				If SR(ZR)='1' or (SR(NG)=SR(OV)) then	PC<=RPC; end if;  
			   rest2:=true;
			when "1111110" =>              -- JRL (Reg,NUM,[reg],[n])
				If  (SR(NG)/=SR(OV)) then PC<=RPC; end if;
				rest2:=true;
			when "1111111" =>              --JRX 
				if IDX/=ZERO16 then PC<=RPC; end if;
				IDX<=IDX-1;
				rest2:=true;
			when others => -- instructions  NOP	
				rest3:=true;
			end case;
			
		when StoreState => -- FF="111" write Y1 to mem in AD
 			case TT is
			when 0 =>
				IO<='0'; AS<='0';  Do:=Y1; DS<='0'; RW<='0';	
			when others =>	
				rest3:=true;
			end case;
		when others =>
			rest2:=true;
		end case;
		----------------------------------------------------------------
		if rest or rest2 then TT<=0;  else 	TT<=TT+1; end if;
		if rest2 then 
			RW<='1'; IO<='0'; DS<='1'; AS<='1'; FF<=InitialState;
		end if;
		if rest3 then -- prepare next instruction and skip TT=0 step
			init_next_ins;
			RW<='1'; IO<='0'; DS<='1'; AS<='1'; FF<=InitialState;	TT<=1;
		end if;
	END IF ;
END IF;
end Process;

end Behavior;


