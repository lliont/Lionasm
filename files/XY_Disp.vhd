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
			if mcnt<86 then mcnt<=mcnt+1;  
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

-----------------------------------------------------------------------------
-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019  MCP4822

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all ;
USE ieee.numeric_std.all ;

entity XY_Display_MCP4822 is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 1023;
		Q: IN std_logic_vector(15 downto 0);
		DACW: OUT std_logic;
		DACA: OUT std_logic_vector(1 downto 0);
		DACD: OUT std_logic_vector(7 downto 0);
		CS,SCK,SDI: OUT std_logic;
		LDAC: OUT std_logic:='1'
	);
end XY_Display_MCP4822;


Architecture Behavior of XY_Display_MCP4822 is

Signal spi_rdy,spi_w: std_logic:='0';
Shared variable mcnt,cnt :  natural range 0 to 255:=0;
Signal x,y,z: std_logic_vector(7 downto 0);
Signal spi_in: std_logic_vector(15 downto 0);
Shared variable caddr: natural range 0 to 1023:=0;
Shared variable e,lx,ly,cx,cy,dx,dy,maxd,sx,sy:integer range -2048 to 2047;
Shared variable restart: natural range 0 to 3:=0;
Shared variable swait: std_logic:='0';

Component SPI16_fast is
	port
	(
		SCLK, MOSI: OUT std_logic ;
		clk, reset, w : IN std_logic ;
		ready : OUT std_logic;
		data_in : IN std_logic_vector (15 downto 0)
	);
end Component;
 

begin
FSPI: spi16_fast
	PORT MAP ( SCK,SDI,sclk,reset,spi_w,spi_rdy,spi_in);
addr<=caddr;

process (sclk,reset)

begin
	if  rising_edge(sclk) then
		if (reset='1') then
			mcnt:=0; 
			caddr:=0; swait:='0'; cs<='1';
			DACW<='1'; x<="00000000"; y<="00000000";
			cnt:=0; restart:=0; LDAC<='0';
		else 
			case mcnt is
			when 0 =>
				swait:='0';
				lx:=to_integer(unsigned(x)); 
				ly:=to_integer(unsigned(y));
			when 1 =>	
				z<=Q(7 downto 0);
			when 2 =>
				 cnt:=0;
				caddr:=caddr+1;  
			when 3 =>
				DACA<="00"; DACD<=z;
			when 4 =>
				y<=Q(7 downto 0); 
				x<=Q(15 downto 8);
			when 5 =>
				caddr:=caddr+1;
				cx:=to_integer(unsigned(x)); cy:=to_integer(unsigned(y)); 
				DACW<='0';
			when 6 =>
				if cx>lx then dx:=cx-lx; else dx:=lx-cx;  end if;
				if cy>ly then dy:=cy-ly; else dy:=ly-cy;  end if;
			when 7 =>
				if cx>lx then sx:=1; elsif lx>cx then sx:=-1; else sx:=0; end if;
				if cy>ly then sy:=1; elsif ly>cy then sy:=-1; else sy:=0; end if;
			when 8 =>
				 DACW<='1';
				if dx>=dy then maxd:=dx; e:=2*dy-dx; else maxd:=dy; e:=2*dx-dy; end if;
				if maxd=0 then mcnt:=mcnt+2; end if;
			when 9 =>  -- loop start
				if e>=0 then
					swait:='1';
					if dy>dx then 
						lx:=lx+sx;
						e:=e-2*dy;
					else 
						ly:=ly+sy;
						e:=e-2*dx;
					end if;
				else swait:='0'; end if;
			when 10 =>
				if dy>dx then
					ly:=ly+sy;
					e:=e+2*dx;
				else
					lx:=lx+sx;
					e:=e+2*dy;
				end if;
			when 11 =>
				cs<='0';
				spi_in<="10110"&std_logic_vector(to_unsigned(lx,8))&"000";
			when 12 =>
				spi_w<='1';
			when 13 =>
			when 14 =>
			when 15 =>
				spi_w<='0';
			when 16 =>
			when 17 =>
				swait:=spi_rdy;
			when 18 =>
				cs<='1';
			when 19 =>
				spi_in<="00110"&std_logic_vector(to_unsigned(ly,8))&"000";
			when 20 =>
				cs<='0';
			when 21 =>
				spi_w<='1';
			when 22 =>
			when 23 =>
			when 24 =>
				spi_w<='0'; 
			when 25 =>
			when 26 =>
				swait:=spi_rdy;
			when 27 =>
				cs<='1';
			when 28 =>
			when 29 =>
			when 30 =>
				LDAC<='0';
			when 31 =>
			when 32 =>
			when 33 =>
			when 34 =>
			when 35 =>
				cnt:=cnt+1;
			when 36 =>
				LDAC<='1';
				if cnt>=maxd then restart:=1; else restart:=2; end if;
			when others=>
			end case;

			if restart=1 then mcnt:=0; cnt:=0; restart:=0; 
				elsif restart=2 then mcnt:=9; restart:=0; 
				elsif swait='0' then mcnt:=mcnt+1; end if;
		end if; --reset
	end if;
end process;

end;

----------------------------------------------------------------------------------------
-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019  MCP4822

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all ;
USE ieee.numeric_std.all ;

entity XY_Display_MCP4822_i is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 1023;
		Q: IN std_logic_vector(15 downto 0);
		DACW: OUT std_logic;
		DACA: OUT std_logic_vector(1 downto 0);
		DACD: OUT std_logic_vector(7 downto 0);
		CS,SCK,SDI: OUT std_logic;
		LDAC: OUT std_logic:='1'
	);
end XY_Display_MCP4822_i;


Architecture Behavior of XY_Display_MCP4822_i is

Signal spi_rdy,spi_w: std_logic:='0';
Signal mcnt :  natural range 0 to 2047:=0;
Signal x,y,z: std_logic_vector(7 downto 0);
Signal spi_in: std_logic_vector(15 downto 0):="0000000000000000";
Shared variable caddr: natural range 0 to 1023:=0;
Shared variable WR: std_logic:='1';
Shared variable restart: natural range 0 to 3:=0;
Shared variable swait: std_logic:='0';

Component SPI16_fast is
	port
	(
		SCLK, MOSI: OUT std_logic ;
		clk, reset, w : IN std_logic ;
		ready : OUT std_logic;
		data_in : IN std_logic_vector (15 downto 0)
	);
end Component;
 

begin
FSPI: spi16_fast
	PORT MAP ( SCK,SDI,sclk,reset,spi_w,spi_rdy,spi_in);
	
addr<=caddr;

process (sclk,reset)

begin
	if  rising_edge(sclk) then
		if (reset='1') then
			mcnt<=0;	caddr:=0; swait:='0'; cs<='1';
			WR:='1'; x<="00000000"; y<="00000000";
			restart:=0; LDAC<='1'; spi_w<='0';
		else 
			if mcnt<49 then 
				if swait='0' then mcnt<=mcnt+1;  end if; 
			else 	mcnt<=0; end if; 
			case mcnt is
			when 0 =>
			when 1 =>
				z<=Q(7 downto 0);
				caddr:=caddr+1;
			when 2 =>
				DACA<="00"; DACD<=z; 
			when 3 =>
				y<=Q(7 downto 0); 
				x<=Q(15 downto 8);
			when 4 => 
				cs<='0';
			when 5 =>
				caddr:=caddr+1;
		   when 6 =>
				spi_in<="11110"&x&"000";
				spi_w<='1';
			when 7 =>
			when 8 =>
			when 9 =>
				spi_w<='0';
			when 10 =>
				swait:=spi_rdy;
			when 11 =>
			when 12 =>
				cs<='1';
			when 13 =>
			when 14 =>
			when 15 =>
				spi_in<="00110"&y&"000";
				cs<='0';
			when 16 =>
				spi_w<='1';
				DACW<='0';
			when 17 =>
			when 18 =>
			when 19 =>
				DACW<='1';
				spi_w<='0';
			when 20 =>
				swait:=spi_rdy;
			when 21 =>
			when 22 =>
				cs<='1';
			when 23 =>
			when 24 =>
			when 25 =>
				LDAC<='0';
			when 26 =>
			when 27 =>
			when 28 =>
			when 29 =>
			when 30 =>
			when 31 =>
				LDAC<='1';
			when others=>
			end case;
		end if; --reset
	end if;
end process;

end;

----------------------------------------------------------------------------------------

-- SPI interface
-- Theodoulos Liontakis (C) 2016,2019

Library ieee; 
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity SPI16_fast is
	port
	(
		SCLK, MOSI: OUT std_logic ;
		clk, reset, w : IN std_logic ;
		ready : OUT std_logic;
		data_in : IN std_logic_vector (15 downto 0)
	);
end SPI16_fast;
 
Architecture Behavior of SPI16_fast is

constant divider:natural :=1; 
Signal rcounter :natural range 0 to 127;
Signal state :natural range 0 to 15:=15;

begin

	process (clk,reset,w)
	begin
		if (reset='1') then 
			rcounter<=0; ready<='0';
			SCLK<='0'; state<=15;
		elsif  clk'EVENT  and clk = '1' then
			if rcounter=divider or (w='1' and ready='0') then
				rcounter<=0;
				MOSI<=data_in(state);
				if state=15 and SCLK='0' and w='1' then
					ready<='1'; SCLK<='1';
				elsif state=15 and SCLK='1' then
					state<=14; SCLK<='0';
				elsif state=14 and SCLK='0' then
					SCLK<='1';
				elsif state=14 and SCLK='1' then
					state<=13; SCLK<='0';
				elsif state=13 and SCLK='0' then
					SCLK<='1';
				elsif state=13 and SCLK='1' then
					state<=12; SCLK<='0';
				elsif state=12 and SCLK='0' then
					SCLK<='1';
				elsif state=12 and SCLK='1' then
					state<=11; SCLK<='0';
				elsif state=11 and SCLK='0' then
					SCLK<='1';
				elsif state=11 and SCLK='1' then
					state<=10; SCLK<='0';
				elsif state=10 and SCLK='0' then
					SCLK<='1';
				elsif state=10 and SCLK='1' then
					state<=9;	SCLK<='0';
				elsif state=9 and SCLK='0' then
					SCLK<='1';
				elsif state=9 and SCLK='1' then
					state<=8; SCLK<='0';
				elsif state=8 and SCLK='0' then
					SCLK<='1';
				elsif state=8 and SCLK='1' then
					state<=7; SCLK<='0';
				elsif state=7 and SCLK='0' then
					SCLK<='1';
				elsif state=7 and SCLK='1' then
					state<=6; SCLK<='0';
				elsif state=6 and SCLK='0' then
					SCLK<='1';
				elsif state=6 and SCLK='1' then
					state<=5; SCLK<='0';
				elsif state=5 and SCLK='0' then
					SCLK<='1';
				elsif state=5 and SCLK='1' then
					state<=4; SCLK<='0';
				elsif state=4 and SCLK='0' then
					SCLK<='1';
				elsif state=4 and SCLK='1' then
					state<=3; SCLK<='0';
				elsif state=3 and SCLK='0' then
					SCLK<='1';
				elsif state=3 and SCLK='1' then
					state<=2; SCLK<='0';
				elsif state=2 and SCLK='0' then
					SCLK<='1';
				elsif state=2 and SCLK='1' then
					state<=1; SCLK<='0';
				elsif state=1 and SCLK='0' then
					SCLK<='1';
				elsif state=1 and SCLK='1' then
					state<=0; SCLK<='0'; 
				elsif state=0 and SCLK='0' then
					SCLK<='1';
				elsif state=0 and SCLK='1' then
					state<=15; SCLK<='0'; ready<='0';
				else	
					SCLK<='0';
					ready<='0';
					state<=15;
				end if;
			else 
				rcounter<=rcounter+1; 
			end if;
		end if;
	end process;
end behavior;

-----------------------------------------------------------------------------
-- XY Display controller for Lion Computer 
-- Theodoulos Liontakis (C) 2019  MCP4822

--Library ieee;
--USE ieee.std_logic_1164.all;
--USE ieee.std_logic_signed.all ;
--USE ieee.numeric_std.all ;
--
--entity XY_Display_MCP4822_bak is
--	port
--	(
--		sclk: IN std_logic;
--		reset: IN std_logic;
--		addr: OUT natural range 0 to 1023;
--		Q: IN std_logic_vector(15 downto 0);
--		DACW: OUT std_logic;
--		DACA: OUT std_logic_vector(1 downto 0);
--		DACD: OUT std_logic_vector(7 downto 0);
--		CS,SCK,SDI: OUT std_logic;
--		LDAC: OUT std_logic:='1'
--	);
--end XY_Display_MCP4822_bak;
--
--
--Architecture Behavior of XY_Display_MCP4822_bak is
--
--Signal spi_rdy,spi_w: std_logic:='0';
--Signal mcnt :  natural range 0 to 2047:=0;
--Signal x,y,z: std_logic_vector(7 downto 0);
--Signal spi_in: std_logic_vector(15 downto 0);
--Shared variable caddr,step,cnt: natural range 0 to 255:=0;
--Shared variable e,lx,ly,cx,cy,dx,dy,maxd,sx,sy:integer range -2048 to 2047;
--Shared variable WR,WR2: std_logic:='1';
--Shared variable restart: natural range 0 to 3:=0;
--Shared variable swait: std_logic:='0';
--
--Component SPI16_fast is
--	port
--	(
--		SCLK, MOSI: OUT std_logic ;
--		clk, reset, w : IN std_logic ;
--		ready : OUT std_logic;
--		data_in : IN std_logic_vector (15 downto 0)
--	);
--end Component;
-- 
--
--begin
--FSPI: spi16_fast
--	PORT MAP ( SCK,SDI,sclk,reset,spi_w,spi_rdy,spi_in);
--addr<=caddr;
--DACW<=WR;
--
--process (sclk,reset)
--
--begin
--	if  rising_edge(sclk) then
--		if (reset='1') then
--			mcnt<=0; 
--			caddr:=0; swait:='0'; cs<='1';
--			WR:='1'; x<="00000000"; y<="00000000";
--			cnt:=1; restart:=0; LDAC<='0';
--		else 
--			case mcnt is
--			when 0 =>
--				lx:=to_integer(unsigned(x)); 
--				ly:=to_integer(unsigned(y));
--				 cnt:=1;
--			when 1 =>	
--				z<=Q(7 downto 0);
--				step:=0;
--			when 2 =>
--				caddr:=caddr+1;  
--			when 3 =>
--				DACA<="00"; DACD<=z;
--			when 4 =>
--				y<=Q(7 downto 0); 
--				x<=Q(15 downto 8);
--			when 5 =>
--				caddr:=caddr+1;
--				cx:=to_integer(unsigned(x)); cy:=to_integer(unsigned(y)); 
--				WR:='0';
--			when 6 =>
--				if cx>lx then dx:=cx-lx; else dx:=lx-cx;  end if;
--				if cy>ly then dy:=cy-ly; else dy:=ly-cy;  end if;
--			when 7 =>
--				if cx>lx then sx:=1; elsif lx>cx then sx:=-1; else sx:=0; end if;
--				if cy>ly then sy:=1; elsif ly>cy then sy:=-1; else sy:=0; end if;
--			when 8 =>
--				 WR:='1';
--				if dx>=dy then maxd:=dx; e:=2*dy-dx; else maxd:=dy; e:=2*dx-dy; end if;
--				if maxd>1 then restart:=2; elsif maxd=0 then restart:=1; end if; 
--			when 9 =>
--				cs<='0';
--			when 10 =>
--				spi_in<="10110"&x&"000";
--		   when 11 =>
--				spi_w<='1';
--			when 12 =>
--			when 13 =>
--			when 14 =>
--				spi_w<='0';
--			when 15 =>
--				swait:=spi_rdy;
--			when 16 =>
--				cs<='1';
--				spi_in<="00110"&y&"000";
--			when 17 =>
--				cs<='0';
--			when 18 =>
--				spi_w<='1';
--			when 19 =>
--			when 20 =>
--			when 21 =>
--				spi_w<='0';
--			when 22 =>
--				swait:=spi_rdy;
--			when 23 =>
--				cs<='1';
--			when 24 =>
--			when 25 =>
--			when 26 =>
--				LDAC<='0';
--			when 27 =>
--         when 28 =>
--			when 29 =>
--			when 30 =>
--			when 31 =>
--				LDAC<='1';
--				restart:=1;
--			when others=>
--				case step is
--			   when 0 =>
--					if e>=0 then 
--						if dy>dx then 
--							lx:=lx+sx;
--							e:=e-2*dy;
--						else 
--							ly:=ly+sy;
--							e:=e-2*dx;
--						end if;
--					else step:=step+1; end if;
--				when 1 =>
--					if dy>dx then
--						ly:=ly+sy;
--						e:=e+2*dx;
--					else
--						lx:=lx+sx;
--						e:=e+2*dy;
--					end if;
--					step:=step+1;
--					cs<='0';
--				when 2 =>
--					step:=step+1;
--					spi_in<="10110"&std_logic_vector(to_unsigned(lx,8))&"000";
--				when 3 =>
--					step:=step+1;
--					spi_w<='1';
--				when 4 =>
--					step:=step+1;
--				when 5 =>
--					step:=step+1;
--				when 6 =>
--					step:=step+1;
--					spi_w<='0';
--				when 7 =>
--					step:=step+1;
--				when 8 =>
--					if spi_rdy='0' then step:=step+1; end if;
--				when 9 =>
--					cs<='1';
--					step:=step+1;
--				when 10 =>
--					step:=step+1;
--					spi_in<="00110"&std_logic_vector(to_unsigned(ly,8))&"000";
--					cs<='0';
--				when 11 =>
--					step:=step+1;
--				when 12 =>
--					step:=step+1;
--					spi_w<='1';
--				when 13 =>
--					step:=step+1;
--				when 14 =>
--					step:=step+1; 
--				when 15 =>
--					step:=step+1;
--				when 16 =>
--					spi_w<='0'; 
--					step:=step+1;
--				when 17 =>
--					step:=step+1;
--				when 18 =>
--					if spi_rdy='0' then step:=step+1; end if;
--				when 19 =>
--					step:=step+1;
--					cs<='1';
--				when 20 =>
--					step:=step+1;
--				when 21 =>
--					step:=step+1;
--					LDAC<='0';
--				when 22 =>
--					step:=step+1;
--				when 23 =>
--					step:=step+1;
--				when 24 =>
--					step:=step+1;
--				when 25 =>
--					step:=step+1;
--				when 26 =>
--					cnt:=cnt+1;
--					step:=step+1;
--				when 27 =>
--					step:=0;	
--					LDAC<='1';
--					if cnt>maxd then restart:=1; end if;
--				when others=>
--				end case;
--			end case;
--			if restart=1 then mcnt<=0; cnt:=1; restart:=0; elsif restart=2 then mcnt<=34; cnt:=1; restart:=0; 
--				else if swait='0' then mcnt<=mcnt+1; end if; end if;
--		end if; --reset
--	end if;
--end process;
--
--end;
