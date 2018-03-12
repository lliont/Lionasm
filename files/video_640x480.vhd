-- Color Video Controller for Lion Computer
-- Theodoulos Liontakis (C) 2016 - 2017

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;
USE ieee.std_logic_unsigned."+" ;

entity VideoRGB is
	port
	(
		sclk: IN std_logic;
		R,G,B,VSYN,HSYN, VSINT: OUT std_logic;
		reset, pbuffer, dbuffer, addxy : IN std_logic;
		addr : OUT natural range 0 to 8191;
		Q : IN std_logic_vector(15 downto 0)
	);
end VideoRGB;

Architecture Behavior of VideoRGB is

Signal dcounter: std_logic_vector(1 downto 0);
Signal lines: natural range 0 to 1023;
Signal pixel, p6, prc : natural range 0 to 1023;
Signal addr2,addr3,pix: natural range 0 to 16383;
signal m8: natural range 0 to 15;

constant sp1: natural:= 14000;
constant sp2: natural:= 14064;
constant sd1: natural:= 14200;
constant sd2: natural:= 14456;
constant l1:natural range 0 to 1023:=49;
constant l2:natural range 0 to 1023:=296;
constant p1:natural range 0 to 1023:=143;
constant p2:natural range 0 to 1023:=526;
constant maxd:natural range 0 to 1023:=16;

begin

process (reset, sclk, addxy)
variable pc: boolean;
--variable ad: natural range 0 to 65535;

type sprite_line_data is array (0 to 7) of std_logic_vector(15 downto 0);
type sprite_dim is array (0 to 7) of std_logic_vector(8 downto 0);
type bool is array (0 to 7) of boolean;
type dist is array (0 to 7) of natural range 0 to 1023;
type col is array (0 to 7) of natural range 0 to 7;
type sprite_param is array (0 to 7) of std_logic_vector(7 downto 0);

variable FG,BG: std_logic_vector(2 downto 0);
variable SX,SY: sprite_dim;
variable sldata: sprite_line_data; 
variable sen,scolor,sdx,sdy: sprite_param;
variable QQQ:boolean;
variable d1,d2:dist;
variable	bl,QQ: bool;
variable pixi,lin: natural range 0 to 1023;
variable lastadxy: std_logic;

begin
	if (reset='1') then
		dcounter<="00"; pixel<=0; m8<=0; addr2<=0; p6<=0; prc<=0; --p8<=0;
		lines<=0;  R<='0'; G<='0'; B<='0'; HSYN<='1'; VSYN<='1'; VSINT<='0'; addr3<=12000; 
	elsif  sClk'EVENT AND sClk = '0' then
		dcounter <= dcounter + 1;
		if dcounter = "01" then 
			dcounter<="00";
			pc:=true; 
		else
			pc:=false;
		end if; 
		
--		if lastadxy/=addxy then 
--			lastadxy:=addxy;
--			for i in 0 to 7 loop
--				SX(i):=SX(i)+SDX(i);	if SX(i)>"101111111" then SX(i):="000000000"; end if;
--				SY(i):=SY(i)+SDY(i); if SY(i)>"11110111" then SY(i):="000000000"; end if;
--			end loop;
--		end if;
		
		if  pc=true then 
			if pixel=799 then
				pixel<=0; pix<=0; 
				if lines=524 then
					lines<=0; 
					m8<=0;
				else
					if lines=l1-1 then 
						m8<=0; addr2<=0; 
					else
						if m8=7 then m8<=0; addr2<=addr2+384/2; else m8<=m8+1; end if;
					end if;
					lines<=lines+1;
				end if;
			else
				pixel<=pixel+1;
			end if;

			if p6=0 and pixel>141 then addr<=addr3+prc/2; end if;
			if pixel<96 then HSYN<='0'; else HSYN<='1'; end if;
			
			-- sprites  ---------------------
			if lines=1 then
				if pixel=0 then SX(0):=Q(0)&Q(15 downto 8); end if;
				if pixel=1 then SY(0):=Q(0)&Q(15 downto 8); end if;
				if pixel=2 then SDX(0):=Q(7 downto 0); SDY(0):=Q(15 downto 8); end if;
				if pixel=3 then SCOLOR(0):=Q(7 downto 0); SEN(0):=Q(15 downto 8); end if;
				if pixel=4 then SX(1):=Q(0)&Q(15 downto 8); end if;
				if pixel=5 then SY(1):=Q(0)&Q(15 downto 8); end if;
				if pixel=6 then SDX(1):=Q(7 downto 0); SDY(1):=Q(15 downto 8); end if;
				if pixel=7 then SCOLOR(1):=Q(7 downto 0); SEN(1):=Q(15 downto 8);  end if;
				if pixel=8 then SX(2):=Q(0)&Q(15 downto 8); end if;
				if pixel=9 then SY(2):=Q(0)&Q(15 downto 8); end if;
				if pixel=10 then SDX(2):=Q(7 downto 0); SDY(2):=Q(15 downto 8); end if;
				if pixel=11 then SCOLOR(2):=Q(7 downto 0); SEN(2):=Q(15 downto 8);  end if;
				if pixel=12 then SX(3):=Q(0)&Q(15 downto 8); end if;
				if pixel=13 then SY(3):=Q(0)&Q(15 downto 8); end if;
				if pixel=14 then SDX(3):=Q(7 downto 0); SDY(3):=Q(15 downto 8); end if;
				if pixel=15 then SCOLOR(3):=Q(7 downto 0); SEN(3):=Q(15 downto 8);  end if;
				if pixel=16 then SX(4):=Q(0)&Q(15 downto 8); end if;
				if pixel=17 then SY(4):=Q(0)&Q(15 downto 8); end if;
				if pixel=18 then SDX(4):=Q(7 downto 0); SDY(4):=Q(15 downto 8); end if;
				if pixel=19 then SCOLOR(4):=Q(7 downto 0); SEN(4):=Q(15 downto 8);  end if;
				if pixel=20 then SX(5):=Q(0)&Q(15 downto 8); end if;
				if pixel=21 then SY(5):=Q(0)&Q(15 downto 8); end if;
				if pixel=22 then SDX(5):=Q(7 downto 0); SDY(5):=Q(15 downto 8); end if;
				if pixel=23 then SCOLOR(5):=Q(7 downto 0); SEN(5):=Q(15 downto 8);  end if;
				if pixel=24 then SX(6):=Q(0)&Q(15 downto 8); end if;
				if pixel=25 then SY(6):=Q(0)&Q(15 downto 8); end if;
				if pixel=26 then SDX(6):=Q(7 downto 0); SDY(6):=Q(15 downto 8); end if;
				if pixel=27 then SCOLOR(6):=Q(7 downto 0); SEN(6):=Q(15 downto 8);  end if;
				if pixel=28 then SX(7):=Q(0)&Q(15 downto 8); end if;
				if pixel=29 then SY(7):=Q(0)&Q(15 downto 8); end if;
				if pixel=30 then SDX(7):=Q(7 downto 0); SDY(7):=Q(15 downto 8); end if;
				if pixel=31 then SCOLOR(7):=Q(7 downto 0); SEN(7):=Q(15 downto 8);  end if;
			end if;
			
			if (lines>=l1 and lines<=l2) then
				if pixel=d2(0) then SLData(0):=Q; end if;
				if pixel=d2(1)+16 then SLData(1):=Q; end if;
				if pixel=d2(2)+32 then SLData(2):=Q; end if;
				if pixel=d2(3)+48 then SLData(3):=Q; end if;
				if pixel=d2(4)+64 then SLData(4):=Q; end if;
				if pixel=d2(5)+80 then SLData(5):=Q; end if;
				if pixel=d2(6)+96 then SLData(6):=Q; end if;
				if pixel=d2(7)+112 then SLData(7):=Q; end if;
			end if;
			
			-- sprites -----------------------
		
			 
			if (lines>=l1 and lines<=l2 and pixel>=p1 and pixel<=p2) then
				if pix mod 2 =0 then
					if Q(15-m8)='1' then QQQ:=true; else QQQ:=false; end if;
				else 
					if Q(7-m8)='1' then QQQ:=true; else QQQ:=false; end if;
				end if;

				QQ:=(others=>false);
				if (SEN(0)(0)='1') then
					if bl(0) and (SLData(0)(d1(0))='1') then QQ(0):=true; end if;
				end if;
				if (SEN(1)(0)='1') then
					if bl(1) and (SLData(1)(d1(1))='1') then QQ(1):=true; end if; 
				end if;
				if (SEN(2)(0)='1') then
					if bl(2) and (SLData(2)(d1(2))='1') then QQ(2):=true; end if;
				end if;
				if (SEN(3)(0)='1') then
					if bl(3) and (SLData(3)(d1(3))='1') then QQ(3):=true; end if;
				end if;
				if (SEN(4)(0)='1') then
					if bl(4) and (SLData(4)(d1(4))='1') then QQ(4):=true; end if;
				end if;
				if (SEN(5)(0)='1') then
					if bl(5) and (SLData(5)(d1(5))='1') then QQ(5):=true; end if;
				end if;
				if (SEN(6)(0)='1') then
					if bl(6) and (SLData(6)(d1(6))='1') then QQ(6):=true; end if;
				end if;
				if (SEN(7)(0)='1') then
					if bl(7) and (SLData(7)(d1(7))='1') then QQ(7):=true; end if;
				end if;

				if    QQ(0) then R<=SCOLOR(0)(2); G<=SCOLOR(0)(1); B<=SCOLOR(0)(0); 
				elsif QQ(1) then R<=SCOLOR(1)(2); G<=SCOLOR(1)(1); B<=SCOLOR(1)(0); 
				elsif QQ(2) then R<=SCOLOR(2)(2); G<=SCOLOR(2)(1); B<=SCOLOR(2)(0);
				elsif QQ(3) then R<=SCOLOR(3)(2); G<=SCOLOR(3)(1); B<=SCOLOR(3)(0); 
				elsif QQ(4) then R<=SCOLOR(4)(2); G<=SCOLOR(4)(1); B<=SCOLOR(4)(0); 
				elsif QQ(5) then R<=SCOLOR(5)(2); G<=SCOLOR(5)(1); B<=SCOLOR(5)(0);
				elsif QQ(6) then R<=SCOLOR(6)(2); G<=SCOLOR(6)(1); B<=SCOLOR(6)(0); 
				elsif QQ(7) then R<=SCOLOR(7)(2); G<=SCOLOR(7)(1); B<=SCOLOR(7)(0); 
				elsif QQQ then R<=FG(2); G<=FG(1); B<=FG(0);
				else  R<=BG(2); G<=BG(1); B<=BG(0); end if;

			else  -- vsync  0.01 us = 1 pixels
				B<='0'; R<='0'; G<='0';
				if lines<2 then
					VSYN<='0';
					if pixel<2 then 
						VSINT<='1';
					else	
						VSINT<='0';
					end if;
				else
					VSYN<='1';
				end if;
			end if;
		else   ------ pc false ---------------------------------------

			if (lines>=l1) and (lines<=l2) and (pixel>=p1) and (pixel<=p2) then
				pix<=pix+1;  -- (pixel-85) * 8
				addr<= pix/2 + addr2; 
			end if;

			-- sprites
			if (lines=1) and (pixel<p1) then 
				if pbuffer='0' then addr<=(sp1/2+pixel); else addr<=(sp2/2+pixel); end if;
			elsif (pixel<128) then 
				if dbuffer='0' then addr<=(sd1/2+pixel); else addr<=(sd2/2+pixel); end if; 
			end if;
			lin:=lines-l1; pixi:=pixel-p1;
			if (pixi>0) and (lin>0) then
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
				
				bl(0):=(d1(0)<maxd) and (d2(0)<maxd);
				bl(1):=(d1(1)<maxd) and (d2(1)<maxd);
				bl(2):=(d1(2)<maxd) and (d2(2)<maxd);
				bl(3):=(d1(3)<maxd) and (d2(3)<maxd);
				bl(4):=(d1(4)<maxd) and (d2(4)<maxd);
				bl(5):=(d1(5)<maxd) and (d2(5)<maxd);
				bl(6):=(d1(6)<maxd) and (d2(6)<maxd);
				bl(7):=(d1(7)<maxd) and (d2(7)<maxd);
			end if;
			-- sprites 

			if pixel=799 then
				if lines<=l1 then 
					addr3<=12000/2; p6<=0; prc<=0; --p8<=0;
				else
					if m8=7 then addr3<=addr3+64/2; end if;
				end if;
				prc<=0;
			else
				if pixel>=p1 and pixel<=p2 then
						if p6=5 then p6<=0; prc<=prc+1; else p6<=p6+1;  end if;
--						if p8=7 then p8<=0; else p8<=p8+1;  end if;
				end if;
			end if;
			 
			if p6=0 then 
				if prc mod 2=1 then
					FG(2):=Q(13); 
					FG(1):=Q(12);
					FG(0):=Q(11);
					BG(2):=Q(10);
					BG(1):=Q(9);
					BG(0):=Q(8);
				else 
					FG(2):=Q(5); 
					FG(1):=Q(4);
					FG(0):=Q(3);
					BG(2):=Q(2);
					BG(1):=Q(1);
					BG(0):=Q(0);
				end if;
			end if;
			
		end if;
	end if; --reset
end process;

end;



-----------------------------------------------------------------------------
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
		   Aud<='0'; c3<=0;  inter<='0'; i<=0; count<=(others=>'0'); play<='0'; dur<=0;
		elsif  Clk'EVENT AND Clk = '1' then
			if wr='0' then 
				CASE f(15 downto 14) is
					when "00" =>
						dur<=100000;  -- 2 sec
					when "01" =>
						dur<=50000;  -- 1 sec
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
						Aud<=not Aud;
						c2<=(others => '0');			
					end if;
					play<='1';
				end if;
				if i=99 then inter<='1'; i<=0; count<=count+'1'; else i<=i+1; end if;
			else
				if IAC='1' or c1="0000001000" then
					inter<='0';
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
				CASE f(15 downto 14) is
					when "00" =>
						dur<=100000;  -- 2 sec
					when "01" =>
						dur<=50000;  -- 1 sec
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
						Aud<=not Aud;
						c2<=(others => '0');			
					end if;
					play<='1';
				end if;
			end if;
		end if;
	end process ;
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
