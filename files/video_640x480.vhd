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
		VClock,R,G,B,VSYN,HSYN: OUT std_logic;
		reset : IN std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(7 downto 0)
	);
end VideoRGB;

Architecture Behavior of VideoRGB is

Signal dcounter: std_logic_vector(1 downto 0);
Signal lines: natural range 0 to 1023;
Signal pixel, p6, prc : natural range 0 to 1023;
Signal addr2,addr3: natural range 0 to 16383;
Signal pix,l: natural range 0 to 16383;
signal l8: natural range 0 to 63;
signal m8: std_logic_vector(3 downto 0);

begin
process (reset, sclk)
variable pc: boolean;
--variable ad: natural range 0 to 65535;

variable FG,BG: std_logic_vector(2 downto 0);

begin
	if (reset='1') then
		dcounter<="00"; pixel<=0; Vclock<='0'; m8<="0000"; l8<=0; addr2<=0; p6<=0; prc<=0;
		lines<=0;  R<='0'; G<='0'; B<='0'; HSYN<='1'; VSYN<='1'; addr3<=12000;
	elsif  sClk'EVENT AND sClk = '0' then
		dcounter <= dcounter + 1;
		if dcounter = "01" then 
			Vclock<=not Vclock;
			dcounter<="00";
			pc:=true; 
		else
			pc:=false;
		end if; 
		
		if  pc=true then 
			if pixel=799 then
				pixel<=0; pix<=0; 
				if lines=524 then
					lines<=0; 
				else
					if lines=48 then 
						l8<=0; m8<="0000"; addr2<=0; l<=0;
					else
						if m8="0111" then l8<=l8+1; l<=l+8; m8<="0000"; addr2<=addr2+384; else m8<=m8+1; end if;
					end if;
					lines<=lines+1;
				end if;
			else
				pixel<=pixel+1;
			end if;

			if pixel<96 then HSYN<='0'; else HSYN<='1'; end if;
			-- picture lines 
			
			if p6=0 then addr<=addr3+prc; end if;

			if (lines>48 and lines<297 and pixel>=143 and pixel<=526) then
				if Q(to_integer(7-unsigned(m8(2 downto 0))))='1' then  
						R<=FG(2); G<=FG(1); B<=FG(0); 
				else  R<=BG(2); G<=BG(1); B<=BG(0); end if;
			else  -- vsync  0.01 us = 1 pixels
				B<='0'; R<='0'; G<='0';
				if lines<2 then
					VSYN<='0';
				else
					VSYN<='1';
				end if;
			end if;
		else   ------ pc false ------
		
			if pixel=799 then
				if lines<=48 then 
					addr3<=12000; p6<=0; prc<=0;
				else
					if m8="0111" then addr3<=addr3+64; end if;
				end if;
				prc<=0;
			else
				if pixel>=143 and pixel<=526 then
						if p6=5 then p6<=0; prc<=prc+1; else p6<=p6+1;  end if;
				end if;
			end if;
			 
			if p6=0 then 
				FG(2):=Q(5); 
				FG(1):=Q(4);
				FG(0):=Q(3);
				BG(2):=Q(2);
				BG(1):=Q(1);
				BG(0):=Q(0);
			end if;
			if (lines>48 and lines<297 and pixel>=143 and pixel<=526) then
				pix<=pix+1;  -- (pixel-85) * 8
				addr<= pix + addr2; 
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

entity Sound is
	port
	(
		Aud: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		Inter: OUT std_logic
	);
end Sound;


Architecture Behavior of Sound is

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
		   Aud<='0'; c3<=0;  inter<='0'; i<=0;
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
			if c1="1111100111" then  -- c1=999  50Khz
				c1<="0000000000";
				c3<=c3+1; c2<=c2+1; 
				if dur=0 then
					Aud<='0';	c2<=(others => '0'); c3<=0;
				else 
					if c2=f(11 downto 0) then
						Aud<=not Aud;
						c2<=(others => '0');			
					end if;
				end if;
				if i=49 then inter<='1'; i<=0; else i<=i+1; end if;
			else
				if c1="0000001101" then
					inter<='0';
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
