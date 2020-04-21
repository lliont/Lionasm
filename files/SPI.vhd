-- SPI interface
-- Theodoulos Liontakis (C) 2016

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity SPI is
	port
	(
		SCLK, MOSI: OUT std_logic ;
		MISO  : IN std_logic ;
		clk, reset, w : IN std_logic ;
		ready : OUT std_logic;
		data_in : IN std_logic_vector (7 downto 0);
		data_out :OUT std_logic_vector (7 downto 0)
	);
end SPI;

Architecture Behavior of SPI is

constant divider:natural :=74; --  124=200Khz
Signal inb,outb: std_logic_vector(7 downto 0);
Signal rcounter :natural range 0 to 127;
Signal state :natural range 0 to 7:=7;

begin
	process (clk,reset)
	begin
		if (reset='1') then 
			rcounter<=0; ready<='0';
			SCLK<='0'; MOSI<='0'; state<=7;
		elsif  clk'EVENT  and clk = '1' then
			rcounter<=rcounter+1; 
			MOSI<=data_in(state);
			if rcounter=divider or (w='1' and ready='0') then
				rcounter<=0;
				if state=7 and SCLK='0' and w='1' then
					ready<='1'; 
					SCLK<='1';
				elsif state=7 and SCLK='1' then
					state<=6;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=6 and SCLK='0' then
					SCLK<='1';
				elsif state=6 and SCLK='1' then
					state<=5;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=5 and SCLK='0' then
					SCLK<='1';
				elsif state=5 and SCLK='1' then
					state<=4;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=4 and SCLK='0' then
					SCLK<='1';
				elsif state=4 and SCLK='1' then
					state<=3;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=3 and SCLK='0' then
					SCLK<='1';
				elsif state=3 and SCLK='1' then
					state<=2;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=2 and SCLK='0' then
					SCLK<='1';
				elsif state=2 and SCLK='1' then
					state<=1;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=1 and SCLK='0' then
					SCLK<='1';
				elsif state=1 and SCLK='1' then
					state<=0;
					data_out(state)<=MISO;
					SCLK<='0';
				elsif state=0 and SCLK='0' then
					SCLK<='1';
				elsif state=0 and SCLK='1' then
					data_out(state)<=MISO;
					SCLK<='0';
					state<=7;
					ready<='0';
					--ww:='0';
				else	
					SCLK<='0';
					ready<='0';
				end if;
			end if;
		end if;
	end process;
end behavior;

