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
constant spno:natural:=10;
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

process (sclk)
variable m78: natural range 0 to 31;
variable FG,BG: std_logic_vector(2 downto 0);
variable sldata: sprite_line_data; 
variable d1,d2:dist;
variable	bl: bool;
variable pixi, lin, p16, pd4, pm4: natural range 0 to 1023;
--variable divp, modp: natural range 0 to 15;
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
					when "01010" =>	R<=SCOLORR(10); G<=SCOLORG(10); B<=SCOLORB(10);
					when others =>
						if Q(m78)='1' then R<=FG(2); G<=FG(1); B<=FG(0);
						else  R<=BG(2); G<=BG(1); B<=BG(0); end if;
					end case;
--				else
--					if Q(m78)='1' then R<=FG(2); G<=FG(1); B<=FG(0);
--					else  R<=BG(2); G<=BG(1); B<=BG(0); end if;
--				end if;
			else  -- vsync  0.01 us = 1 pixels
				B<='0'; R<='0'; G<='0';
				if lines<2 then VSYN<='0';	else	VSYN<='1';	end if;
				if (lines=0) and (pixel<4) then 	VSINT<='0';	else	VSINT<='1';	end if;
			end if;
			
		else   ------ vidc false VIDEO 0---------------------------------------
			
			if (lines>=l1) and (lines<l2) and (pixel>=p1) and (pixel<p2) then
				if (pixel mod 2)=0 then 
					pix<=pix+1;   -- (pixel-85) * 8
					if pix(0) = '0' then	m78:=15-m8/2; else m78:=7-m8/2; end if;  -- m78<= not m8
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
			d1(10):=pixi-to_integer(unsigned(SX(10))); 
			d2(10):=lin-to_integer(unsigned(SY(10)));
			--d1(11):=pixi-to_integer(unsigned(SX(11))); 
			--d2(11):=lin-to_integer(unsigned(SY(11)));
			
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
			if (d1(10)<maxd) and (d2(10)<maxd) and (SLData(10)(d1(10))='1') and (SEN(10)='1') then blvec:="01010"; end if;
			--if (d1(11)<maxd) and (d2(11)<maxd) and (SLData(11)(d1(11))='1') and (SEN(11)='1') then blvec:="01011"; end if;
		end if;
	end if; --reset
end process;

end;



-----------------------------------------------------------------------------
-- Color Video Controller + Sprites for Lion Computer
-- Theodoulos Liontakis (C) 2018

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity VideoRGB1 is
	port
	(
		sclk: IN std_logic;
		R,G,B,BRI,VSYN,HSYN, VSINT: OUT std_logic;
		reset, pbuffer, dbuffer : IN std_logic;
		addr : OUT natural range 0 to 16383; 
		Q : IN std_logic_vector(15 downto 0);
		spaddr: OUT natural range 0 to 16383;
		SPQ: IN std_logic_vector(15 downto 0)
	);
end VideoRGB1;

Architecture Behavior of VideoRGB1 is

constant vbase: natural:= 0;
constant sp1: natural:= 0; 
constant sp2: natural:= 256;
constant sd1: natural:= 512;
constant sd2: natural:= 4352;
constant l1:natural:=74;
constant lno:natural:=200;
constant p1:natural :=142;
constant pno:natural:=320;
constant maxd:natural:=16;
constant spno:natural:=9;
constant p2:natural:=p1+pno*2;
constant l2:natural:=l1+lno*2;

type sprite_dim is array (0 to spno*4) of std_logic_vector(8 downto 0);
type sprite_line_data is array ((spno*4)+3 downto 0) of std_logic_vector(15 downto 0);
type bool is array (0 to spno) of boolean;
type dist is array (0 to spno) of natural range 0 to 1023;
type sprite_color is array (0 to spno) of std_logic;
type sprite_enable is array (0 to spno) of std_logic;


Signal lines: natural range 0 to 1023;
Signal pixel : natural range 0 to 1023;
Signal addr2: natural range 0 to 16383;
signal m8,p6: natural range 0 to 31;
Signal vidc: boolean:=false;
Signal SX,SY: sprite_dim;
--Signal scolorR,scolorG,ScolorB: sprite_color;  -- ,sdx,sdy
Signal sen:sprite_enable;

begin

vidc<=not vidc when falling_edge(sclk);

process (sclk)
variable m78: natural range 0 to 31;
variable PCOL,BRGB: std_logic_vector(3 downto 0);
variable sldata: sprite_line_data; 
variable d1,d2,d1pd4,d1pm4:dist;
variable	bl: bool;
variable p16: natural range 0 to 4095;
variable pixi, lin, pd4, pm4, d2pm4, pixm4, pixd4: natural range 0 to 1023;
--variable divp, modp: natural range 0 to 15;
variable blvec:std_logic_vector(4 downto 0);
Variable pix: natural range 0 to 1023;

begin
	if  falling_edge(sclk) then
		--p2:=p1+pno*2; l2:=l1+lno*2;
		if  vidc then 
			if pixel=799 then
				pixel<=0; pix:=0; p16:=0; 
				if lines=524 then	lines<=0; else lines<=lines+1; end if;
				if lines=l1-1 then 
					m8<=0; addr2<=vbase/2; 
				else
					if m8=1 then m8<=0; addr2<=addr2+pno/4; else m8<=m8+1; end if;
				end if;
			else
				pixel<=pixel+1;
			end if;
			if (pixel<96) then HSYN<='0'; else HSYN<='1'; end if;

			-- sprites  ---------------------
			
			if (lines=0) and (pixel<spno*4+4)  then	
				pm4:= pixel mod 4; pd4:=pixel/4;
				if pm4 = 0 then SX(pd4)<=SPQ(8 downto 0); end if; 
				if pm4 = 1 then SY(pd4)<=SPQ(8 downto 0); end if;
				--if pm4=2 then SDX(pd4):=SPQ(15 downto 8); SDY(pd4):=SPQ(7 downto 0); end if;
				if pm4 = 3 then SEN(pd4)<=SPQ(0); end if;
			end if;
			
			if (lines>=l1 and lines<l2 and pixel<=(spno*4)+3) then
				SLData(pixel):=SPQ;
			end if;
			 
			if (lines>=l1 and lines<l2 and pixel>=p1 and pixel<p2) then
					case blvec is
					when "00000" => 	
						BRGB:='0'&SLData(d1pd4(0))(2+d1pm4(0) downto d1pm4(0));
					when "00001" => 
						BRGB:='0'&SLData(4+d1pd4(1))(2+d1pm4(1) downto d1pm4(1));
					when "00010" => 
						BRGB:='0'&SLData(8+d1pd4(2))(2+d1pm4(2) downto d1pm4(2));
					when "00011" => 
						BRGB:='0'&SLData(12+d1pd4(3))(2+d1pm4(3) downto d1pm4(3));
					when "00100" => 	
						BRGB:='0'&SLData(16+d1pd4(4))(2+d1pm4(4) downto d1pm4(4));
					when "00101" => 	
						BRGB:='0'&SLData(20+d1pd4(5))(2+d1pm4(5) downto d1pm4(5));
					when "00110" => 	
						BRGB:='0'&SLData(24+d1pd4(6))(2+d1pm4(6) downto d1pm4(6));
					when "00111" => 	
						BRGB:='0'&SLData(28+d1pd4(7))(2+d1pm4(7) downto d1pm4(7));
					when "01000" => 	
						BRGB:='0'&SLData(32+d1pd4(8))(2+d1pm4(8) downto d1pm4(8));
					when "01001" => 
						BRGB:='0'&SLData(36+d1pd4(9))(2+d1pm4(9) downto d1pm4(9));
--					when "01010" => 
--						R<=SLData(40+d1pd4(10))(2+d1pm4(10)); G<=SLData(40+d1pd4(10))(1+d1pm4(10)); B<=SLData(40+d1pd4(10))(d1pm4(10)); BRI<='0';
					when others =>
						 BRGB:=PCOL;  --B<=PCOL(2); G<=PCOL(1); B<=PCOL(0);
					end case;
					BRI<=BRGB(3); R<=BRGB(2); G<=BRGB(1); B<=BRGB(0); 
			else  -- vsync  0.01 us = 1 pixels
				B<='0'; R<='0'; G<='0'; BRI<='0';
				if lines<2 then VSYN<='0';	else	VSYN<='1';	end if;
				if (lines=0) and (pixel<4) then 	VSINT<='0';	else	VSINT<='1';	end if;
			end if;
			
		else   ------ vidc false ---------------------------------------
			
			if (lines>=l1) and (lines<l2) and (pixel>=p1) and (pixel<p2) then
				if (pixel mod 2)=0 then 
					addr<= pix/4 + addr2;
					pix:=pix+1;   -- (pixel-85) * 8
				end if;
			end if;
			
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
			--d1(10):=pixi-to_integer(unsigned(SX(10))); 
			--d2(10):=lin-to_integer(unsigned(SY(10)));
			
			d1pd4(0):=d1(0)/4; d1pm4(0):=(3-d1(0) mod 4)*4;
			d1pd4(1):=d1(1)/4; d1pm4(1):=(3-d1(1) mod 4)*4;
			d1pd4(2):=d1(2)/4; d1pm4(2):=(3-d1(2) mod 4)*4;
			d1pd4(3):=d1(3)/4; d1pm4(3):=(3-d1(3) mod 4)*4;
			d1pd4(4):=d1(4)/4; d1pm4(4):=(3-d1(4) mod 4)*4;
			d1pd4(5):=d1(5)/4; d1pm4(5):=(3-d1(5) mod 4)*4;
			d1pd4(6):=d1(6)/4; d1pm4(6):=(3-d1(6) mod 4)*4;
			d1pd4(7):=d1(7)/4; d1pm4(7):=(3-d1(7) mod 4)*4;
			d1pd4(8):=d1(8)/4; d1pm4(8):=(3-d1(8) mod 4)*4;
			d1pd4(9):=d1(9)/4; d1pm4(9):=(3-d1(9) mod 4)*4;
--			d1pd4(10):=d1(10)/4; d1pm4(10):=(3-d1(10) mod 4)*4;
			
			pm4:= pixel mod 4; pd4:=pixel/4;
			if (pixel<=(1+spno)*4) then 
				if (lines=0) then
					if pbuffer='0' then spaddr<=(sp1/2+pixel); else spaddr<=(sp2/2+pixel); end if;
				else 
					if dbuffer='0' then 
						spaddr<=(sd1/2+p16+d2(pd4)*4+pm4);
					 else 
						spaddr<=(sd2/2+p16+d2(pd4)*4+pm4);
					end if; 
					if pm4=3 then p16:=p16+64; end if;
				end if;
			end if;
			
			
			if pixm4=1 then PCOL:=Q(15 downto 12); end if;  --Q(12)&Q(13)&Q(14)&Q(15);
			if pixm4=2 then PCOL:=Q(11 downto 8); end if; --Q(8)&Q(9)&Q(10)&Q(11);
			if pixm4=3 then PCOL:=Q(7 downto 4); end if; -- Q(4)&Q(5)&Q(6)&Q(7);
			if pixm4=0 then PCOL:=Q(3 downto 0); end if; --Q(0)&Q(1)&Q(2)&Q(3);
			pixm4:=pix mod 4;
			-- sprites
			
			blvec:="11111";
			if (d1(0)<maxd) and (d2(0)<maxd) and (SEN(0)='1') and (SLData(d1pd4(0))(3+d1pm4(0))='0') then blvec:="00000"; end if;
			if (d1(1)<maxd) and (d2(1)<maxd) and (SEN(1)='1') and (SLData(4+d1pd4(1))(3+d1pm4(1))='0') then blvec:="00001"; end if;
			if (d1(2)<maxd) and (d2(2)<maxd) and (SEN(2)='1') and (SLData(8+d1pd4(2))(3+d1pm4(2))='0') then blvec:="00010"; end if;
			if (d1(3)<maxd) and (d2(3)<maxd) and (SEN(3)='1') and (SLData(12+d1pd4(3))(3+d1pm4(3))='0') then blvec:="00011"; end if;
			if (d1(4)<maxd) and (d2(4)<maxd) and (SEN(4)='1') and (SLData(16+d1pd4(4))(3+d1pm4(4))='0') then blvec:="00100"; end if;
			if (d1(5)<maxd) and (d2(5)<maxd) and (SEN(5)='1') and (SLData(20+d1pd4(5))(3+d1pm4(5))='0') then blvec:="00101"; end if;
			if (d1(6)<maxd) and (d2(6)<maxd) and (SEN(6)='1') and (SLData(24+d1pd4(6))(3+d1pm4(6))='0') then blvec:="00110"; end if;
			if (d1(7)<maxd) and (d2(7)<maxd) and (SEN(7)='1') and (SLData(28+d1pd4(7))(3+d1pm4(7))='0') then blvec:="00111"; end if;
			if (d1(8)<maxd) and (d2(8)<maxd) and (SEN(8)='1') and (SLData(32+d1pd4(8))(3+d1pm4(8))='0') then blvec:="01000"; end if;
			if (d1(9)<maxd) and (d2(9)<maxd) and (SEN(9)='1') and (SLData(36+d1pd4(9))(3+d1pm4(9))='0') then blvec:="01001"; end if;
--			if (d1(10)<maxd) and (d2(10)<maxd) and (SEN(10)='1') and (SLData(40+d1pd4(10))(3+d1pm4(10))='0') then blvec:="01010"; end if;
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
