-- Color Video Controller + Sprites for Lion Computer
-- Theodoulos Liontakis (C) 2016 - 2017

-- 640x480 @60 Hz
-- Vertical refresh	31.46875 kHz
-- Pixel freq.	25.175 MHz  (25.1736 Mhz)

--Scanline part	Pixels	Time [µs]
--Visible area	640	25.422045680238
--Front porch	16	   0.63555114200596
--Sync pulse	96		3.8133068520357
--Back porch	48		1.9066534260179
--Whole line	800	31.777557100298

--Frame part	Lines	Time [ms]
--Visible area	480	15.253227408143
--Front porch	10		0.31777557100298
--Sync pulse	2		0.063555114200596
--Back porch	33		1.0486593843098
--Whole frame	525	16.683217477656

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoRGB80 is
	port
	(
		sclk, EN: IN std_logic;
		R,G,B,BRI0,VSYN,HSYN, VSINT: OUT std_logic;
		addr : OUT natural range 0 to 16383; 
		Q : IN std_logic_vector(15 downto 0)
	);
end VideoRGB80;

Architecture Behavior of VideoRGB80 is

constant vbase: natural:= 0;
constant ctbl: natural:= 12000+16384;
constant l1:natural:=35;
constant lno:natural:=240;
constant p1:natural :=142;
constant pno:natural:=640;
constant cxno:natural:=80;
constant p2:natural:=p1+pno;
constant l2:natural:=l1+lno*2;

Signal lines,pix: natural range 0 to 1023;
Signal pixel, prc : natural range 0 to 1023;
Signal addr2,addr3: natural range 0 to 16383;
signal m8,p6: natural range 0 to 127;
Signal vidc: boolean:=false;

begin

vidc<=not vidc when rising_edge(sclk);
--HSYN<='0' when (pixel<96) else '1'; 
--VSYN<='0' when lines<2 else '1';
--VSINT<='0' when (lines=0) and (pixel<4) else	'1';

process (sclk)
variable m78: natural range 0 to 31;
variable FG,BG: std_logic_vector(3 downto 0);
variable lin, p16, pd4, pm4: natural range 0 to 1023;

begin
	if  falling_edge(sclk) and EN='0' then
		if  vidc then 
			if pixel=799 then
				pixel<=0; pix<=0; p6<=0; prc<=0; 
				if lines=524 then	lines<=0; else lines<=lines+1; end if;
				if lines=l1-1 then m8<=0; addr2<=vbase/2; else
					if m8=15 then m8<=0; addr2<=addr2+pno/2; else m8<=m8+1; end if;
				end if;
			else
				pixel<=pixel+1;
			end if;
			if (p6=0) and (pixel>=p1-1) and (pixel<p2) then addr<=addr3+prc/2; end if;
			if (pixel<96) then HSYN<='0'; else HSYN<='1'; end if;
			
			if lines<2 then VSYN<='0';	else	VSYN<='1';	end if;
			if (lines=0) and (pixel<4) then 	VSINT<='0';	else	VSINT<='1';	end if;
			 
			if (lines>=l1 and lines<l2 and pixel>=p1 and pixel<p2) then
				if Q(m78)='1' then BRI0<=FG(3); R<=FG(2); G<=FG(1); B<=FG(0);
				else BRI0<=BG(3); R<=BG(2); G<=BG(1); B<=BG(0); end if;
--					end case;
			else  
				B<='0'; R<='0'; G<='0'; BRI0<='0';
			end if;
			
		else   ------ vidc false VIDEO 0---------------------------------------
			
			if (lines>=l1) and (lines<l2) and (pixel>=p1) and (pixel<p2) then
				pix<=pix+1;
				if pix mod 2=0 then	m78:=15-m8/2; else m78:=7-m8/2; end if;  -- m78<= not m8
				addr<= pix/2 + addr2; 
			end if;
			
			if pixel=799 then
				if lines<=l1 then 
					addr3<=(ctbl)/2;  --p8<=0;
				else
					if m8=15 then addr3<=addr3+cxno/2; end if;
				end if;
				prc<=0; p6<=0;
			else
				if pixel>=p1 and pixel<p2 then
					if p6=7 then p6<=0; prc<=prc+1; else p6<=p6+1;  end if;
				end if;
			end if;
			
			if p6=0 then 
				if prc mod 2=0 then
					FG:=Q(15 downto 12);
					BG:=Q(11 downto 8);
				else 
					FG:=Q(7 downto 4);
					BG:=Q(3 downto 0);
				end if;
			end if;
			
		end if;
	end if; --falling_edge
end process;

end;






-----------------------------------------------------------------------------
-- Color Video Controller + Multicolor Sprites for Lion Computer
-- Theodoulos Liontakis (C) 2018

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoRGB1 is
	port
	(
		sclk, EN: IN std_logic;
		R,G,B,BRI,VSYN,HSYN, VSINT: OUT std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(15 downto 0)
	);
end VideoRGB1;

Architecture Behavior of VideoRGB1 is

constant vbase: natural:= 0;
constant l1:natural:=74;
constant lno:natural:=200;
constant p1:natural :=142;
constant pno:natural:=320;
constant p2:natural:=p1+pno*2;
constant l2:natural:=l1+lno*2;

Signal lines: natural range 0 to 1023;
Signal pixel : natural range 0 to 1023;
Signal addr2: natural range 0 to 16383;
signal m8: natural range 0 to 31;
Signal vidc: boolean:=false;


begin

vidc<=not vidc when rising_edge(sclk);
VSYN<='0' when lines<2 else '1';	
VSINT<='0' when (lines=0) and (pixel<4) else	'1';	
HSYN<='0' when (pixel<96) else '1'; 

process (sclk)

variable BRGB: std_logic_vector(3 downto 0);
variable pixm4: natural range 0 to 1023;
variable pix: natural range 0 to 1023;

begin
	if  falling_edge(sclk)  and EN='1' then
		if  vidc then 
		-- sprites  ---------------------
			if (lines>=l1 and lines<l2 and pixel>=p1 and pixel<p2) then
					BRI<=BRGB(3); R<=BRGB(2); G<=BRGB(1); B<=BRGB(0); 
			else  -- vsync  0.01 us = 1 pixels
				B<='0'; R<='0'; G<='0'; BRI<='0';
			end if;
			if pixel=799 then
				pixel<=0; pix:=0; pixm4:=0;
				if lines=524 then	lines<=0; else lines<=lines+1; end if;
				if lines=l1-1 then 
					m8<=0; addr2<=vbase/2; 
				else
					if m8=1 then m8<=0; addr2<=addr2+pno/4; else m8<=m8+1; end if;
				end if;
			else
				pixel<=pixel+1;
			end if;
			
		else   ------ vidc false ---------------------------------------
			
			if (lines>=l1) and (lines<l2) and (pixel>p1) and (pixel<p2) then
				if (pixel mod 2)=1 then 
					pix:=pix+1; 
				end if;
			end if;
			addr<= pix/4 + addr2;
			
			case pixm4 is
			when 0 => BRGB:=Q(15 downto 12);  --end if;  --Q(12)&Q(13)&Q(14)&Q(15);
			when 1 => BRGB:=Q(11 downto 8);  --end if; --Q(8)&Q(9)&Q(10)&Q(11);
			when 2 => BRGB:=Q(7 downto 4); --end if; -- Q(4)&Q(5)&Q(6)&Q(7);
			when 3 => BRGB:=Q(3 downto 0); --end if; --Q(0)&Q(1)&Q(2)&Q(3);
			when others=>
			end case;
			pixm4:=pix mod 4;
			-- sprites
		end if;
	end if; --falling
end process;


end;


-----------------------------------------------------------------------------
-- Multicolor Sprites for Lion Computer Set II & III
-- Theodoulos Liontakis (C) 2018

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoSp is
	port
	(
		sclk: IN std_logic;
		R,G,B,BRI,SPDET: OUT std_logic;
		reset, pbuffer, dbuffer : IN std_logic;
		spaddr: OUT natural range 0 to 2047;
		SPQ: IN std_logic_vector(15 downto 0)
	);
end VideoSp;

Architecture Behavior of VideoSp is

constant sp1: natural:= 0; 
constant sp2: natural:= 256;
constant sd1: natural:= 512;
constant sd2: natural:= 2304;
constant l1:natural:=74;
constant lno:natural:=240;
constant p1:natural :=142;
constant pno:natural:=320;
constant maxd:natural:=16;
constant spno:natural:=13;
constant p2:natural:=p1+pno*2;
constant l2:natural:=l1+lno*2;

type sprite_dim is array (0 to spno*4+3) of std_logic_vector(8 downto 0);
type sprite_line_data is array (spno downto 0) of std_logic_vector(63 downto 0);
type dist is array (0 to spno) of natural range 0 to 4095;
type sprite_enable is array (0 to spno) of std_logic;


Signal lines: natural range 0 to 1023;
Signal pixel : natural range 0 to 1023;
Signal addr2: natural range 0 to 16383;
Signal vidc: boolean:=false;
Signal SX,SY: sprite_dim;
Signal SEN:sprite_enable;


begin

vidc<=not vidc when rising_edge(sclk);
--pm4<=pixel mod 4;
--pd4<=pixel / 4;

process (sclk,reset)

variable BRGB: std_logic_vector(3 downto 0);
variable sldata: sprite_line_data; 
variable d1,d2:dist;
variable p16: natural range 0 to 2047;
variable pixi, lin, pm4,pd4: natural range 0 to 1023;
variable blvec:std_logic_vector(3 downto 0);
variable pix: natural range 0 to 1023;

begin
	if  falling_edge(sclk) then
		if (reset='0') then
			pixel<=4; lines<=0;
		elsif  vidc then 
		-- sprites  ---------------------
			if (lines>=l1 and lines<l2 and pixel>=p1 and pixel<p2) then
					case blvec is
					when "0000" => 	
						BRGB:='0'&SLData(0)(2+d1(0) downto d1(0));
						SPDET<='1';
					when "0001" => 
						BRGB:='0'&SLData(1)(2+d1(1) downto d1(1));
						SPDET<='1';
					when "0010" => 
						BRGB:='0'&SLData(2)(2+d1(2) downto d1(2));
						SPDET<='1';
					when "0011" => 
						BRGB:='0'&SLData(3)(2+d1(3) downto d1(3));
						SPDET<='1';
					when "0100" => 	
						BRGB:='0'&SLData(4)(2+d1(4) downto d1(4));
						SPDET<='1';
					when "0101" => 	
						BRGB:='0'&SLData(5)(2+d1(5) downto d1(5));
						SPDET<='1';
					when "0110" => 	
						BRGB:='0'&SLData(6)(2+d1(6) downto d1(6));
						SPDET<='1';
					when "0111" => 	
						BRGB:='0'&SLData(7)(2+d1(7) downto d1(7));
						SPDET<='1';
					when "1000" => 	
						BRGB:='0'&SLData(8)(2+d1(8) downto d1(8));
						SPDET<='1';
					when "1001" => 
						BRGB:='0'&SLData(9)(2+d1(9) downto d1(9));
						SPDET<='1';
					when "1010" => 
						BRGB:='0'&SLData(10)(2+d1(10) downto d1(10));
						SPDET<='1';
					when "1011" => 
						SPDET<='1';
						BRGB:='0'&SLData(11)(2+d1(11) downto d1(11));
					when "1100" => 
						SPDET<='1';
						BRGB:='0'&SLData(12)(2+d1(12) downto d1(12));
					when "1101" => 
						SPDET<='1';
						BRGB:='0'&SLData(13)(2+d1(13) downto d1(13));
					when others =>
						SPDET<='0'; BRGB:="0000";
					end case;
					BRI<=BRGB(3); R<=BRGB(2); G<=BRGB(1); B<=BRGB(0); 
			else  -- vsync  0.01 us = 1 pixels
				SPDET<='0';
			end if;
			
			if pixel=799 then
				pixel<=0; pix:=0; p16:=0;
				if lines=524 then	lines<=0; else lines<=lines+1; end if;
			else
				pixel<=pixel+1;
			end if;
			
			if (lines=1) and (pixel<spno*4+4)  then	
				pm4:= pixel mod 4; pd4:=pixel/4;
				if pm4 = 0 then SX(pd4)<=SPQ(8 downto 0); end if; 
				if pm4 = 1 then SY(pd4)<=SPQ(8 downto 0); end if;
				--if pm4=2 then SDX(pd4):=SPQ(15 downto 8); SDY(pd4):=SPQ(7 downto 0); end if;
				if pm4 = 3 then SEN(pd4)<=SPQ(0); end if;
			end if;
			
			if (lines>=l1 and lines<l2 and (pixel<(spno*4+4))) then
				SLData(pd4)(pm4*16+15 downto pm4*16):=SPQ(3 downto 0)&SPQ(7 downto 4)&SPQ(11 downto 8)&SPQ(15 downto 12);
			end if;
			blvec:="1111"; 
		else   ------ vidc false ---------------------------------------
			
			lin:=(lines-l1)/2; pixi:=(pixel-p1)/2;
			
			d1(0):=(pixi-to_integer(unsigned(SX(0))))*4; 
			d2(0):=lin-to_integer(unsigned(SY(0)));
			d1(1):=(pixi-to_integer(unsigned(SX(1))))*4; 
			d2(1):=lin-to_integer(unsigned(SY(1)));
			d1(2):=(pixi-to_integer(unsigned(SX(2))))*4; 
			d2(2):=lin-to_integer(unsigned(SY(2)));
			d1(3):=(pixi-to_integer(unsigned(SX(3))))*4; 
			d2(3):=lin-to_integer(unsigned(SY(3)));
			d1(4):=(pixi-to_integer(unsigned(SX(4))))*4; 
			d2(4):=lin-to_integer(unsigned(SY(4)));
			d1(5):=(pixi-to_integer(unsigned(SX(5))))*4; 
			d2(5):=lin-to_integer(unsigned(SY(5)));
			d1(6):=(pixi-to_integer(unsigned(SX(6))))*4; 
			d2(6):=lin-to_integer(unsigned(SY(6)));
			d1(7):=(pixi-to_integer(unsigned(SX(7))))*4; 
			d2(7):=lin-to_integer(unsigned(SY(7)));
			d1(8):=(pixi-to_integer(unsigned(SX(8))))*4; 
			d2(8):=lin-to_integer(unsigned(SY(8)));
			d1(9):=(pixi-to_integer(unsigned(SX(9))))*4; 
			d2(9):=lin-to_integer(unsigned(SY(9)));
			d1(10):=(pixi-to_integer(unsigned(SX(10))))*4; 
			d2(10):=lin-to_integer(unsigned(SY(10)));
			d1(11):=(pixi-to_integer(unsigned(SX(11))))*4; 
			d2(11):=lin-to_integer(unsigned(SY(11)));
			d1(12):=(pixi-to_integer(unsigned(SX(12))))*4; 
			d2(12):=lin-to_integer(unsigned(SY(12)));
			d1(13):=(pixi-to_integer(unsigned(SX(13))))*4; 
			d2(13):=lin-to_integer(unsigned(SY(13)));
			
			if (pixel<(spno*4+4)) then 
				if (lines=1) then
					if pbuffer='0' then spaddr<=(sp1/2+pixel); else spaddr<=(sp2/2+pixel); end if;
				end if;
				if (lines>=l1) and (lines<l2) then
					pm4:= pixel mod 4; pd4:=pixel/4;
					if dbuffer='0' then 
						spaddr<=(sd1/2+p16+d2(pd4)*4+pm4);
					 else 
						spaddr<=(sd2/2+p16+d2(pd4)*4+pm4);
					end if; 
					if pm4=3 then p16:=p16+64; end if;
				end if;
			end if;
			
			if (d1(0)<maxd*4) and (d2(0)<maxd) and (SEN(0)='1') and (SLData(0)(3+d1(0))='0') then blvec:="0000"; end if;
			if (d1(1)<maxd*4) and (d2(1)<maxd) and (SEN(1)='1') and (SLData(1)(3+d1(1))='0') then blvec:="0001"; end if;
			if (d1(2)<maxd*4) and (d2(2)<maxd) and (SEN(2)='1') and (SLData(2)(3+d1(2))='0') then blvec:="0010"; end if;
			if (d1(3)<maxd*4) and (d2(3)<maxd) and (SEN(3)='1') and (SLData(3)(3+d1(3))='0') then blvec:="0011"; end if;
			if (d1(4)<maxd*4) and (d2(4)<maxd) and (SEN(4)='1') and (SLData(4)(3+d1(4))='0') then blvec:="0100"; end if;
			if (d1(5)<maxd*4) and (d2(5)<maxd) and (SEN(5)='1') and (SLData(5)(3+d1(5))='0') then blvec:="0101"; end if;
			if (d1(6)<maxd*4) and (d2(6)<maxd) and (SEN(6)='1') and (SLData(6)(3+d1(6))='0') then blvec:="0110"; end if;
			if (d1(7)<maxd*4) and (d2(7)<maxd) and (SEN(7)='1') and (SLData(7)(3+d1(7))='0') then blvec:="0111"; end if;
			if (d1(8)<maxd*4) and (d2(8)<maxd) and (SEN(8)='1') and (SLData(8)(3+d1(8))='0') then blvec:="1000"; end if;
			if (d1(9)<maxd*4) and (d2(9)<maxd) and (SEN(9)='1') and (SLData(9)(3+d1(9))='0') then blvec:="1001"; end if;
			if (d1(10)<maxd*4) and (d2(10)<maxd) and (SEN(10)='1') and (SLData(10)(3+d1(10))='0') then blvec:="1010"; end if;
			if (d1(11)<maxd*4) and (d2(11)<maxd) and (SEN(11)='1') and (SLData(11)(3+d1(11))='0') then blvec:="1011"; end if;
			if (d1(12)<maxd*4) and (d2(12)<maxd) and (SEN(12)='1') and (SLData(12)(3+d1(12))='0') then blvec:="1100"; end if;
			if (d1(13)<maxd*4) and (d2(13)<maxd) and (SEN(13)='1') and (SLData(13)(3+d1(13))='0') then blvec:="1101"; end if;			
		end if;
	end if; --reset
end process;


end;

-----------------------------------------------------------------------------
Library ieee;
Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity SoundI is
	port
	(
		Aud: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		count: OUT std_logic_vector(15 downto 0);
		play: OUT  std_logic;
		Inter: OUT std_logic;
		IAC: IN std_logic
	);
end SoundI;


Architecture Behavior of SoundI is

Signal c3:natural range 0 to 255;
Signal f:std_logic_vector(15 downto 0);
Signal c2:std_logic_vector(11 downto 0);
Signal c1:std_logic_vector(9 downto 0);
Signal dur: natural range 0 to 65535*2+1;
signal i: natural range 0 to 511;
begin

f<=Q when wr='0' ;

process (clk,reset,wr)	
	begin
		if (reset='1') then
		   Aud<='0'; c3<=0;  inter<='1'; i<=0; count<=(others=>'0'); play<='0'; dur<=0;
		elsif  Clk'EVENT AND Clk = '1' then
			if wr='0' then 
			   play<='1';
				CASE f(15 downto 14) is
					when "00" =>
						dur<=100000;  -- 1 sec
					when "01" =>
						dur<=50000;  -- 0.5 sec
					when "10" =>    
						dur<=25000;  -- 0.25
					when others =>  
						dur<=12500;  -- 0.125
					end case;
				c1<=(others => '0'); 
			else 
				c1<=c1+1;
				if c3=0 and dur/=0 then dur<=dur-1; end if;
			end if;
			if c1="111110011" then  -- c1=502 100khz (clock =50.347.222) c1=499 100Khz was c1=999  50Khz
				c1<="0000000000";
				c3<=c3+1; c2<=c2+1; 
				if dur=0 then
					Aud<='0';	c2<=(others => '0'); c3<=0; play<='0';
				else 
					if c2=f(11 downto 0) then
						if c2/="000000000000" then Aud<=not Aud; end if;
						c2<=(others => '0');			
					end if;
					--play<='1';
				end if;
				if i=99 then inter<='0'; i<=0; count<=count+'1'; else i<=i+1; end if;
			else
				if IAC='1' or c1="0000001000" then
					inter<='1';
				end if;
			end if;
		end if;
	end process ;
end;

-----------------------------------------------------------------------------
Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity Sound is
	port
	(
		Aud: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		play: OUT  std_logic
	);
end Sound;


Architecture Behavior of Sound is

Signal c3:natural range 0 to 255;
Signal f:std_logic_vector(15 downto 0);
Signal c2:std_logic_vector(11 downto 0);
Signal c1:std_logic_vector(9 downto 0);
Signal dur: natural range 0 to 65535*2+1;
begin

f<=Q when wr='0' ;

process (clk,reset,wr)	
	begin
		if (reset='1') then
		   Aud<='0'; c3<=0;  play<='0'; dur<=0;
		elsif  Clk'EVENT AND Clk = '1' then
			if wr='0' then 
				play<='1';
				CASE f(15 downto 14) is
					when "00" =>
						dur<=100000;  -- 1 sec
					when "01" =>
						dur<=50000;  -- 0.5 sec
					when "10" =>
						dur<=25000;
					when others =>
						dur<=12500;
					end case;
				c1<=(others => '0'); 
			else 
				c1<=c1+1;
				if c3=0 and dur/=0 then dur<=dur-1; end if;
			end if;
			if c1="000111110011" then  -- c1=499 100Khz was c1=999  50Khz
				c1<="0000000000";
				c3<=c3+1; c2<=c2+1; 
				if dur=0 then
					Aud<='0';	c2<=(others => '0'); c3<=0; play<='0';
				else 
					if c2=f(11 downto 0) then
						if c2/="000000000000" then Aud<=not Aud; end if;
						c2<=(others => '0');			
					end if;
				end if;
			end if;
		end if;
	end process ;
end;

-------------------------------------------------------
-- Design Name : lfsr
-- File Name   : lfsr.vhd
-- Function    : Linear feedback shift register
-- Coder       : Deepak Kumar Tala (Verilog)
-- Translator  : Alexander H Pham (VHDL)
-- adapted to 1bit stream, 18bit counter, by Theodoulos Liontakis
-------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity lfsr is
  port (
    cout   :out std_logic;		-- Output of the counter
    clk    :in  std_logic;    -- Input rlock
    reset  :in  std_logic     -- Input reset
  );
end entity;

architecture rtl of lfsr is
    signal count           :std_logic_vector (17 downto 0);
    signal linear_feedback :std_logic;
    
begin
    linear_feedback <= not(count(17) xor count(6));

	 process (clk, reset) 
	 variable cnt: natural range 0 to 65535;
	 begin
				
		  if (reset = '1') then
				count <= (others=>'0'); cnt:=0;
		  elsif (rising_edge(clk)) then
				cnt:=cnt+1;
				if cnt=32000 then
					count <= ( count(16) & count(15)&
								count(14) & count(13) & count(12) & count(11)&
								count(10) & count(9) & count(8) & count(7)&
								count(6) & count(5) & count(4) & count(3) 
							  & count(2) & count(1) & count(0) & linear_feedback);
					cnt:=0;
				end if;
		  end if;
	 end process;
	cout <= count(17);
end architecture;

-----------------------------------------------------------------------------

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoRGB is
	port
	(
		sclk: IN std_logic;
		R,G,B,VSYN,HSYN, VSINT: OUT std_logic;
		reset, pbuffer, dbuffer : IN std_logic;
		addr : OUT natural range 0 to 16383; 
		Q : IN std_logic_vector(15 downto 0)
	);
end VideoRGB;

Architecture Behavior of VideoRGB is

constant vbase: natural:= 16384;
constant sp1: natural:= 14000+16384; 
constant sp2: natural:= 14128+16384;
constant sd1: natural:= 14400+16384;
constant sd2: natural:= 14912+16384;
constant ctbl: natural:= 12000+16384;
constant l1:natural:=34;
constant lno:natural:=240;
constant p1:natural :=142;
constant pno:natural:=320;
constant maxd:natural:=16;
constant spno:natural:=9;
constant cxno:natural:=54;
constant p2:natural:=p1+pno*2;
constant l2:natural:=l1+lno*2;

type sprite_dim is array (0 to spno) of std_logic_vector(8 downto 0);
type sprite_line_data is array (0 to spno) of std_logic_vector(15 downto 0);
type bool is array (0 to spno) of boolean;
type dist is array (0 to spno) of natural range 0 to 1023;
type sprite_color is array (0 to spno) of std_logic;
type sprite_enable is array (0 to spno) of std_logic;

Signal pix: std_logic_vector(10 downto 0);
Signal lines: natural range 0 to 1023;
Signal pixel, prc : natural range 0 to 1023;
Signal addr2,addr3: natural range 0 to 16383;
signal m8,p6: natural range 0 to 31;
Signal vidc: boolean:=false;
Signal SX,SY: sprite_dim;
Signal scolorR,scolorG,ScolorB: sprite_color;  -- ,sdx,sdy
Signal sen:sprite_enable;

begin

vidc<=not vidc when falling_edge(sclk);
--HSYN<='0' when (pixel<96) else '1'; 
--VSYN<='0' when lines<2 else '1';
--VSINT<='0' when (lines=0) and (pixel<4) else	'1';

process (sclk)
variable m78: natural range 0 to 31;
variable FG,BG: std_logic_vector(2 downto 0);
variable sldata: sprite_line_data; 
variable d1,d2:dist;
variable	bl: bool;
variable pixi, lin, p16, pd4, pm4: natural range 0 to 1023;
variable ldata: std_logic_vector(7 downto 0);
variable blvec:std_logic_vector(4 downto 0);

begin
	if  falling_edge(sclk) then
		--p2:=p1+pno*2; l2:=l1+lno*2;
		if  vidc then 
			if pixel=799 then
				pixel<=0; pix<="00000000000"; p16:=0; p6<=0; prc<=0; 
				if lines=524 then	lines<=0; else lines<=lines+1; end if;
				if lines=l1-1 then m8<=0; addr2<=vbase/2; else
					if m8=15 then m8<=0; addr2<=addr2+pno/2; else m8<=m8+1; end if;
				end if;
			else
				pixel<=pixel+1;
			end if;
			if (p6=0) and (pixel>=p1-1) and (pixel<p2) then addr<=addr3+prc/2; end if;
			if (pixel<96) then HSYN<='0'; else HSYN<='1'; end if;

			-- sprite parameters ---------------------
			if (lines=0) and (pixel<44)  then	
				pm4:= pixel mod 4; pd4:=pixel/4;
				if pm4 = 0 then SX(pd4)<=Q(8 downto 0); end if; 
				if pm4 = 1 then SY(pd4)<=Q(8 downto 0); end if;
				--if pm4=2 then SDX(pd4):=Q(15 downto 8); SDY(pd4):=Q(7 downto 0); end if;
				if pm4 = 3 then SCOLORR(pd4)<=Q(10); SCOLORG(pd4)<=Q(9); SCOLORB(pd4)<=Q(8); SEN(pd4)<=Q(0); end if;
			end if;
			-- sprite data ---------------------
			if (lines>=l1 and lines<l2 and pixel<=spno) then
				SLData(pixel):=Q;
			end if;
			 
			if (lines>=l1 and lines<l2 and pixel>=p1 and pixel<p2) then
					case blvec is
					when "00000" =>	R<=SCOLORR(0); G<=SCOLORG(0); B<=SCOLORB(0); 
					when "00001" =>	R<=SCOLORR(1); G<=SCOLORG(1); B<=SCOLORB(1); 
					when "00010" =>	R<=SCOLORR(2); G<=SCOLORG(2); B<=SCOLORB(2); 
					when "00011" =>	R<=SCOLORR(3); G<=SCOLORG(3); B<=SCOLORB(3); 
					when "00100" =>	R<=SCOLORR(4); G<=SCOLORG(4); B<=SCOLORB(4); 
					when "00101" =>	R<=SCOLORR(5); G<=SCOLORG(5); B<=SCOLORB(5); 
					when "00110" =>	R<=SCOLORR(6); G<=SCOLORG(6); B<=SCOLORB(6); 
					when "00111" =>	R<=SCOLORR(7); G<=SCOLORG(7); B<=SCOLORB(7); 
					when "01000" =>	R<=SCOLORR(8); G<=SCOLORG(8); B<=SCOLORB(8); 
					when "01001" =>	R<=SCOLORR(9); G<=SCOLORG(9); B<=SCOLORB(9); 
--					when "01010" =>	R<=SCOLORR(10); G<=SCOLORG(10); B<=SCOLORB(10);
					when others =>
						if Q(m78)='1' then R<=FG(2); G<=FG(1); B<=FG(0);
						else  R<=BG(2); G<=BG(1); B<=BG(0); end if;
					end case;
			else  
				if lines<2 then VSYN<='0';	else	VSYN<='1';	end if;
				if (lines=0) and (pixel<4) then 	VSINT<='0';	else	VSINT<='1';	end if;
				B<='0'; R<='0'; G<='0';
			end if;
			
		else   ------ vidc false VIDEO 0---------------------------------------
			
			if (lines>=l1) and (lines<l2) and (pixel>=p1) and (pixel<p2) then
				if (pixel mod 2)=0 then 
					pix<=pix+1;   -- (pixel-85) * 8
					if pix(0)='0' then	m78:=15-m8/2; else m78:=7-m8/2; end if;  -- m78<= not m8
					addr<= to_integer(unsigned(pix(10 downto 1))) + addr2; 
				end if;
			end if;
			
			if (pixel<p1) then 
				if (lines=0) then
					if pbuffer='0' then addr<=(sp1/2+pixel); else addr<=(sp2/2+pixel); end if;
				else 
					if pixel<12 then
						if dbuffer='0' then addr<=(sd1/2+p16+d2(pixel)); else addr<=(sd2/2+p16+d2(pixel)); end if; 
					end if;
				end if;
				p16:=p16+16;
			end if;
			
			if pixel=799 then
				if lines<=l1 then 
					addr3<=(ctbl)/2;  --p8<=0;
				else
					if m8=15 then addr3<=addr3+cxno/2; end if;
				end if;
				prc<=0; p6<=0;
			else
				if pixel>=p1 then
					if p6=11 then p6<=0; prc<=prc+1; else p6<=p6+1;  end if;
				end if;
			end if;
			
			if p6=0 then 
				if prc mod 2=0 then
					FG(2):=Q(13); FG(1):=Q(12); FG(0):=Q(11);
					BG(2):=Q(10); BG(1):=Q(9);  BG(0):=Q(8);
				else 
					FG(2):=Q(5); FG(1):=Q(4); FG(0):=Q(3);
					BG(2):=Q(2); BG(1):=Q(1); BG(0):=Q(0);
				end if;
			end if;

			-- sprites
			lin:=(lines-l1)/2; pixi:=(pixel-p1)/2;
			d1(0):=pixi-to_integer(unsigned(SX(0))); 
			d2(0):=lin-to_integer(unsigned(SY(0)));
			d1(1):=pixi-to_integer(unsigned(SX(1))); 
			d2(1):=lin-to_integer(unsigned(SY(1)));
			d1(2):=pixi-to_integer(unsigned(SX(2))); 
			d2(2):=lin-to_integer(unsigned(SY(2)));
			d1(3):=pixi-to_integer(unsigned(SX(3))); 
			d2(3):=lin-to_integer(unsigned(SY(3)));
			d1(4):=pixi-to_integer(unsigned(SX(4))); 
			d2(4):=lin-to_integer(unsigned(SY(4)));
			d1(5):=pixi-to_integer(unsigned(SX(5))); 
			d2(5):=lin-to_integer(unsigned(SY(5)));
			d1(6):=pixi-to_integer(unsigned(SX(6))); 
			d2(6):=lin-to_integer(unsigned(SY(6)));
			d1(7):=pixi-to_integer(unsigned(SX(7))); 
			d2(7):=lin-to_integer(unsigned(SY(7)));
			d1(8):=pixi-to_integer(unsigned(SX(8))); 
			d2(8):=lin-to_integer(unsigned(SY(8)));
			d1(9):=pixi-to_integer(unsigned(SX(9))); 
			d2(9):=lin-to_integer(unsigned(SY(9)));
--			d1(10):=pixi-to_integer(unsigned(SX(10))); 
--			d2(10):=lin-to_integer(unsigned(SY(10)));
			
			blvec:="11111";
			if (d1(0)<maxd) and (d2(0)<maxd) and (SLData(0)(d1(0))='1') and (SEN(0)='1') then blvec:="00000"; end if;
			if (d1(1)<maxd) and (d2(1)<maxd) and (SLData(1)(d1(1))='1') and (SEN(1)='1') then blvec:="00001"; end if;
			if (d1(2)<maxd) and (d2(2)<maxd) and (SLData(2)(d1(2))='1') and (SEN(2)='1') then blvec:="00010"; end if;
			if (d1(3)<maxd) and (d2(3)<maxd) and (SLData(3)(d1(3))='1') and (SEN(3)='1') then blvec:="00011"; end if;
			if (d1(4)<maxd) and (d2(4)<maxd) and (SLData(4)(d1(4))='1') and (SEN(4)='1') then blvec:="00100"; end if;
			if (d1(5)<maxd) and (d2(5)<maxd) and (SLData(5)(d1(5))='1') and (SEN(5)='1') then blvec:="00101"; end if;
			if (d1(6)<maxd) and (d2(6)<maxd) and (SLData(6)(d1(6))='1') and (SEN(6)='1') then blvec:="00110"; end if;
			if (d1(7)<maxd) and (d2(7)<maxd) and (SLData(7)(d1(7))='1') and (SEN(7)='1') then blvec:="00111"; end if;
			if (d1(8)<maxd) and (d2(8)<maxd) and (SLData(8)(d1(8))='1') and (SEN(8)='1') then blvec:="01000"; end if;
			if (d1(9)<maxd) and (d2(9)<maxd) and (SLData(9)(d1(9))='1') and (SEN(9)='1') then blvec:="01001"; end if;
--			if (d1(10)<maxd) and (d2(10)<maxd) and (SLData(10)(d1(10))='1') and (SEN(10)='1') then blvec:="01010"; end if;
		end if;
	end if; --reset
end process;

end;


--------------------------------------------------------------------
-- Composite Video Controller for Lion Computer
-- Theodoulos Liontakis 2015 

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoC is
	port
	(
		V  : OUT std_logic_vector(1 downto 0);
		sclk: IN std_logic;
		VClock,R,G,B,VSYN,HSYN: OUT std_logic;
		reset : IN std_logic;
		addr : OUT natural range 0 to 65535;
		Q : IN std_logic_vector(0 downto 0)
	);
end VideoC;

Architecture Behavior of VideoC is

Signal pclk : std_logic;
Signal dcounter: std_logic_vector(3 downto 0);
Signal lines: natural range 0 to 1023;
Signal pixel: natural range 0 to 511;

begin

process (reset, sclk)
variable pc: boolean;
variable ad: natural range 0 to 65535;
variable l8: natural range 0 to 63 :=0;
variable m8: natural range 0 to 7 :=0;

begin
	if (reset='1') then
		dcounter<="0000"; pixel<=0; pclk<='0';
		lines<=0;  V<="00";  R<='0'; G<='0'; B<='0'; HSYN<='1'; VSYN<='1';
	elsif  sClk'EVENT AND sClk = '1' then
		dcounter <= dcounter + 1;
		if dcounter = "0111" then 
			pclk<= not pclk; 
			Vclock<=pclk;
			dcounter<="0000";
			pc:=true; 
		else
			pc:=false;
		end if; 
		
		if  pc=true then 
			if pixel=399 then
				pixel<=0;
				if lines=624 then
					lines<=0;
				else
					lines<=lines+1;
					if lines=65 or lines=312+65 then l8:=0; m8:=0; end if;
					if m8=7 then l8:=l8+1; end if;
					m8:=m8+1;
				end if;
			else
				pixel<=pixel+1;
			end if;
		end if;
		
		if pc=true then
		if pixel<24 then HSYN<='0'; else HSYN<='1'; end if;
		if (lines >4 and lines<310) or (lines>316 and lines<622) then
			VSYN<='1';
			if pixel<24 then -- hsync
				V<="00"; B<='0';
			elsif pixel<49 then
			
				V<="10";
			else  -- picture lines 
				if (lines>64 and lines<274 and pixel>77 and pixel<378) or
					(lines>312+64 and lines<274+312 and pixel>77 and pixel<378) then
					ad:=(pixel-78)*8+l8*8*300+m8;
					addr<=ad;
					if Q="1" then V<="11"; B<='1'; else V<="10"; B<='0'; end if;
				--elsif lines>312+64 and lines<274+312 and pixel>77 and pixel<378 then
				--	ad:=(pixel-78)*8+l8*8*300+m8;
				--	addr<=ad;
				--	if Q="1" then V<="11"; else V<="10"; end if;
				else
					V<="01"; B<='0';
				end if;
			end if;
		else  -- vsync 30us = 187.5 pixels, 2us =12.5 pixels
			B<='0'; R<='0'; G<='0';
			if lines<2 then
				VSYN<='0';
				if pixel<187 then V<="00"; 
				elsif pixel<200 then V<="10";
				elsif pixel<387 then V<="00";
				else v<="10"; end if;
			elsif lines=2 then
				VSYN<='0';
				if pixel<187 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<213 then V<="00";
				else v<="10"; end if;
			elsif lines<5 then
				VSYN<='1';
				if pixel<13 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<213 then V<="00";
				else v<="10"; end if;
			elsif lines>309 and lines<312 then
				VSYN<='1';
				if pixel<13 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<213 then V<="00";
				else v<="10"; end if;
			elsif lines=312 then
				VSYN<='0';
				if pixel<13 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<387 then V<="00";
				else v<="10"; end if;
			elsif lines>312 and lines<315 then
				VSYN<='0';
				if pixel<187 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<387 then V<="00";
				else v<="10"; end if;
			elsif lines<317 then
				VSYN<='1';
				if pixel<13 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<213 then V<="00";
				else v<="10"; end if;
			elsif lines>621 then
				VSYN<='1';
				if pixel<13 then V<="00";
				elsif pixel<200 then V<="10";
				elsif pixel<213 then V<="00";
				else v<="10"; end if;
			end if;
		end if;
		end if;
	end if;
end process;

end;
--------------------------------------------------------------------------------
