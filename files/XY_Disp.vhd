----------------------------------------------------------------------------
-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019

Library ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity XY_Display_MCP is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 1023;
		Q: IN std_logic_vector(15 downto 0);
		I2CC: OUT std_logic:='1';
		I2CD1,I2CD2,I2CD3: INOUT std_logic:='1'
	);
end XY_Display_MCP;


Architecture Behavior of XY_Display_MCP is

Constant tfast:natural :=18;
Constant tslow:natural :=99;

Signal ACK1,ACK2,ACK3: std_logic:='0';
Signal mcnt,turn :  natural range 0 to 1023:=0;
Signal state :  natural range 0 to 1023:=0;
Signal x,y,z,lx,ly : std_logic_vector(7 downto 0);
Shared variable caddr:  natural range 0 to 1023:=0;
Shared variable D1,D2,D3,C:std_logic:='1';

begin

addr<=caddr;

process (sclk,reset)

begin
	if  rising_edge(sclk) then
		if (reset='1') then
			mcnt<=0; turn<=0;
			caddr:=0; state<=0;
			I2CC<='1'; I2CD2<='1'; I2CD3<='1'; I2CD1<='1';
		else 
			if turn=0 then -- initialize
				if mcnt<tslow then mcnt<=mcnt+1;  
					else 	mcnt<=0; state<=state+1; end if; 
				case state is
				when 08 =>
					I2CC<='1';
					I2CC<='1'; I2CD1<='1'; I2CD2<='1'; I2CD3<='1';
				when 09 =>
					I2CC<='1';
					I2CC<='1'; I2CD1<='1'; I2CD2<='1'; I2CD3<='1';
				when 10 =>	
					I2CC<='1';
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if; --start
				when 11 =>
					I2CC<='0'; 
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 12=>
					I2CC<='1'; -- bit 1
				when 13=>
					I2CC<='0';
				when 14 =>
					I2CC<='1'; -- bit 2
				when 15 =>
					I2CC<='0';
				when 16 =>
					I2CC<='1'; -- bit 3
				when 17 =>
					I2CC<='0';
				when 18 =>
					I2CC<='1'; -- bit 4
				when 19 =>
					I2CC<='0';	
					if mcnt>tslow/2 then I2CD1<='1'; I2CD2<='1'; I2CD3<='1'; end if;
				when 20 =>
					I2CC<='1'; -- bit 5
				when 21 =>
					I2CC<='0'; 
					--if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 22=>
					I2CC<='1'; -- bit 6
				when 23=>
					I2CC<='0';
				when 24=>
					I2CC<='1'; -- bit 7 
				when 25=>
					I2CC<='0';
				when 26=>
					I2CC<='1'; -- bit 8
				when 27=>
					I2CC<='0'; 
--					if mcnt>tslow/2 then I2CD1<='Z'; I2CD2<='Z'; I2CD3<='Z'; end if;
				when 28=>
					I2CC<='1';
				when 29=>
					I2CC<='1';
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if; --start
				when 30 =>
					--I2CC<='1'; I2CD1<='1'; I2CD2<='1'; I2CD3<='1';
				when 31 =>
					I2CC<='0'; 
					if mcnt>tslow/2 then I2CD1<='1'; I2CD2<='1'; I2CD3<='1'; end if; -- device code
				when 32=>
					I2CC<='1'; --bit 1
				when 33=>
					if mcnt>tslow/2 then I2CD1<='1'; I2CD2<='1'; I2CD3<='1'; end if; -- device code
					I2CC<='0';
				when 34 =>
					I2CC<='1'; --bit 2
				when 35 =>
					I2CC<='0'; 
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 36 =>
					I2CC<='1'; --bit 3
				when 37 =>
					I2CC<='0';
				when 38 =>
					I2CC<='1'; --bit 4
				when 39 =>
					I2CC<='0';	
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if; -- address
				when 40 =>
					I2CC<='1'; --bit 5
				when 41 =>
					I2CC<='0'; 
					if mcnt>tslow/2 then I2CD1<='1'; I2CD2<='1'; I2CD3<='1'; end if;
				when 42 =>
					I2CC<='1';  --bit 6
				when 43 =>
					I2CC<='0';  
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 44 =>
					I2CC<='1';  --bit 7
				when 45 =>
					I2CC<='0';
					if mcnt>tslow/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if; -- Write
				when 46 =>
					I2CC<='1';  --bit 8
				when 47 =>
					if mcnt>tslow/2 then I2CD1<='Z'; I2CD2<='Z'; I2CD3<='Z'; end if; 
					I2CC<='0';
				when 48 =>
					I2CC<='1'; 
					if mcnt>tslow/2 then ACK1<=I2CD1; ACK2<=I2CD2; ACK3<=I2CD3; end if;
				when 49=>
					--I2CC<='0';
					--if mcnt>tslow/2 then I2CD1<='1'; I2CD2<='1'; I2CD3<='1'; end if;
				when 50 =>
					I2CC<='1';  
					turn<=1; state<=0; mcnt<=0;
				when others =>
				end case;
			elsif turn=1 then  --turn
				if mcnt<tfast then mcnt<=mcnt+1; else mcnt<=0; state<=state+1; end if; 
				case state is
				when 0 =>
					case mcnt is
					when 0 =>
					when 1 =>
						z<=Q(7 downto 0);  
					when 2 =>
						caddr:=caddr+1; lx<=x; ly<=y;
					when 3 => 
					when 4 =>
						y<=Q(7 downto 0); 
						x<=Q(15 downto 8);
					when 5 =>
						caddr:=caddr+1; 						
					when others=>
					end case;
					I2CC<='1';
				when 1 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if; -- second byte
				when 2 =>
					I2CC<='1'; --bit 1
				when 3 =>
					I2CC<='0';
				when 4 =>
					I2CC<='1'; --bit 2
				when 5 =>
					I2CC<='0';
				when 6 =>
					I2CC<='1'; --bit 3
				when 7 =>
					I2CC<='0';
				when 8 =>
					I2CC<='1'; --bit 4
				when 9 =>
					I2CC<='0';
				when 10 =>
					I2CC<='1'; --bit 5
				when 11 =>
					I2CC<='0';
				when 12 =>
					I2CC<='1'; --bit 6
				when 13 =>
					I2CC<='0';
					if mcnt>tfast/2 then I2CD1<=z(7); I2CD2<=x(7); I2CD3<=y(7); end if;
				when 14 =>
					I2CC<='1'; --bit 7
				when 15 =>
					I2CC<='0';
					if mcnt>tfast/2 then I2CD1<=z(6); I2CD2<=x(6); I2CD3<=y(6); end if;
				when 16 =>
					I2CC<='1'; --bit 8
				when 17 =>
					I2CC<='0';
					if mcnt>tfast/2 then I2CD1<='Z'; I2CD2<='Z'; I2CD3<='Z'; end if;
				when 18 =>
					I2CC<='1'; 
					if mcnt>tfast/2 then ACK1<=I2CD1; ACK2<=I2CD2; ACK3<=I2CD3; end if;
				when 19 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(5); I2CD2<=x(5); I2CD3<=y(5); end if;
				when 20 =>
					I2CC<='1'; --bit 1
				when 21 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(4); I2CD2<=x(4); I2CD3<=y(4); end if;
				when 22 =>    --bit 2
					I2CC<='1';
				when 23 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(3); I2CD2<=x(3); I2CD3<=y(3); end if;
				when 24 =>
					I2CC<='1'; --bit 3
				when 25 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(2); I2CD2<=x(2); I2CD3<=y(2); end if;
				when 26 =>
					I2CC<='1'; --bit 4
				when 27 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(1); I2CD2<=x(1); I2CD3<=y(1); end if;
				when 28 =>  
					I2CC<='1';  --bit 5
				when 29 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<=z(0); I2CD2<=x(0); I2CD3<=y(0); end if;
				when 30 =>   
					I2CC<='1';  --bit 6
				when 31 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 32 =>
					I2CC<='1';  --bit 7
				when 33 =>
					I2CC<='0'; 
					if mcnt>tfast/2 then I2CD1<='0'; I2CD2<='0'; I2CD3<='0'; end if;
				when 34 =>
					I2CC<='1'; --bit 8
				when 35 =>
					I2CC<='0';
					if mcnt>tfast/2 then I2CD1<='Z'; I2CD2<='Z'; I2CD3<='Z'; end if;
				when 36 =>
					I2CC<='1'; 
					ACK1<=I2CD1; ACK2<=I2CD2; ACK3<=I2CD3; 
				when 37 =>
					mcnt<=0; state<=0; turn<=1;
				when others =>
				end case;
			end if;
		end if; --reset
	end if;
end process;

end;




-----------------------------------------------------------------------------
-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all ;
USE ieee.numeric_std.all ;

entity XY_Display_TLC is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 1023;
		Q: IN std_logic_vector(15 downto 0);
		DACW,MUX: OUT std_logic;
		DACA: OUT std_logic_vector(1 downto 0);
		DACD: OUT std_logic_vector(7 downto 0)
	);
end XY_Display_TLC;


Architecture Behavior of XY_Display_TLC is

Signal turn: std_logic:='0';
Signal mcnt :  natural range 0 to 2047:=0;
Signal x,y,z: std_logic_vector(7 downto 0);
Shared variable caddr,step,cnt: natural range 0 to 1023:=0;
Shared variable e,lx,ly,cx,cy,dx,dy,maxd,sx,sy:integer range -2048 to 2047;
Shared variable WR,WR2: std_logic:='1';
Shared variable restart: natural range 0 to 3:=0;
begin

addr<=caddr;
DACW<=WR;

process (sclk,reset)

begin
	if  rising_edge(sclk) then
		if (reset='1') then
			mcnt<=0; turn<='0';
			caddr:=0;
			WR:='1'; x<="00000000"; y<="00000000";
			MUX<='0'; cnt:=1; restart:=0;
		else 
			case mcnt is
			when 0 =>
				lx:=to_integer(unsigned(x)); 
				ly:=to_integer(unsigned(y));
			when 1 =>
				z<=Q(7 downto 0); cnt:=1;
			when 2 =>	
				caddr:=caddr+1; step:=0;
			when 3 =>
				DACA<="00"; DACD<=z; 
			when 4 =>
				y<=Q(7 downto 0); 
				x<=Q(15 downto 8);
			when 5 =>
				cx:=to_integer(unsigned(x)); cy:=to_integer(unsigned(y)); 
				if cx>lx then dx:=cx-lx; else dx:=lx-cx;  end if;
				if cy>ly then dy:=cy-ly; else dy:=ly-cy;  end if;
			when 6 =>
				WR:='0'; 
				if cx>lx then sx:=1; elsif lx>cx then sx:=-1; else sx:=0; end if;
				if cy>ly then sy:=1; elsif ly>cy then sy:=-1; else sy:=0; end if;
			when 7 =>
				WR:='1';
				caddr:=caddr+1;
				if dx>=dy then maxd:=dx; e:=2*dy-dx; else maxd:=dy; e:=2*dx-dy; end if;
				if maxd>1 then restart:=2; end if; 
				 DACA<="10";
				 DACD<=x;
			when 8 =>
				WR:='0'; 
		   when 9 =>
				WR:='1';
				DACA<="11"; DACD<=y;
				restart:=0;
			when 10 =>
				WR:='0';
			when 11 =>
				WR:='1';
			when 12 =>
				restart:=1;
			when others=>
				case step is
			   when 0 =>
					if e>=0 then 
						if dy>dx then 
							lx:=lx+sx;
							e:=e-2*dy;
						else 
							ly:=ly+sy;
							e:=e-2*dx;
						end if;
					else step:=step+1; end if;
				when 1 =>
					if dy>dx then
						ly:=ly+sy;
						e:=e+2*dx;
					else
						lx:=lx+sx;
						e:=e+2*dy;
					end if;
					step:=step+1;
					DACA<="10";
					DACD<=std_logic_vector(to_unsigned(lx,8));
				when 2 =>
					step:=step+1;
					WR:='0';
				when 3 =>
					WR:='1';
					step:=step+1;
					DACA<="11"; DACD<=std_logic_vector(to_unsigned(ly,8));
				when 4 =>
					WR:='0';
					step:=step+1;
				when 5 =>
					WR:='1';
					cnt:=cnt+1;
					step:=step+1;
				when 6 =>
					step:=step+1;
				when 7 =>
					step:=0;		
					if cnt>maxd then restart:=1; end if;
				when others=>
				end case;
			end case;
			if restart=1 then mcnt<=0; restart:=0; elsif restart=2 then mcnt<=20; restart:=0; else mcnt<=mcnt+1; end if;
		end if; --reset
	end if;
end process;

end;

----------------------------------------------------------------------------------------

-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019

Library ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity XY_Display_TLC_i is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 1023;
		Q: IN std_logic_vector(15 downto 0);
		DACW,MUX: OUT std_logic;
		DACA: OUT std_logic_vector(1 downto 0);
		DACD: OUT std_logic_vector(7 downto 0)
	);
end XY_Display_TLC_i;


Architecture Behavior of XY_Display_TLC_i is

Signal turn: std_logic:='0';
Signal mcnt :  natural range 0 to 2047:=0;
Signal x,y,z,lx,ly: std_logic_vector(7 downto 0);
Shared variable caddr:  natural range 0 to 1023:=0;
Shared variable WR,WR2: std_logic:='1';
begin

addr<=caddr;
DACW<=WR;

process (sclk,reset)

begin
	if  rising_edge(sclk) then
		if (reset='1') then
			mcnt<=0; turn<='0';
			caddr:=0;
			WR:='1';
			MUX<='0';
		else 
			if mcnt<80 then mcnt<=mcnt+1;  
				else 	mcnt<=0; end if; --TURN <= NOT TURN;
			case mcnt is
			when 0 =>	
			when 1 =>
				z<=Q(7 downto 0);  
			when 2 =>
				caddr:=caddr+1; lx<=x; ly<=y;
			when 3 => 
			when 4 =>
				y<=Q(7 downto 0); 
				x<=Q(15 downto 8);
				DACA<="00"; DACD<=z;
			when 5 =>
				WR:='0'; 
			when 6 =>
				 WR:='1'; 
				 DACA<="10";
				 DACD<=x;
			when 7 =>
				WR:='0'; 
		   when 8 =>
				WR:='1';
				caddr:=caddr+1;
				DACA<="11"; DACD<=y;
				WR:='0';
			when 9 =>
				WR:='1';
			when 51 =>
				DACA<="00"; DACD<="00000000";
			when 52 =>
				WR:='0'; 
			when 53 =>
			when 54 =>
			   WR:='1';
			when others=>
--				if mcnt>11+maxd then mcnt<=0; end if;
			end case;
		end if; --reset
	end if;
end process;

end;



