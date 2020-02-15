-- UART + Serial Keyboard 
-- (C) Theodoulos Liontakis 2015 

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity UART is
	port
	(
		Tx  : OUT std_logic ;
		Rx  : IN std_logic ;
		clk, reset, r, w : IN std_logic ;
		data_ready : OUT std_logic:='0';
		ready : OUT std_logic:='1';
		data_in : IN std_logic_vector (7 downto 0);
		data_out :OUT std_logic_vector (7 downto 0)
	);
end UART;

Architecture Behavior of UART is

constant rblen:natural:=16;
constant tblen:natural:=8;
constant divider:natural :=2603/2; -- 19200*2       650  25MHz/38400   1302 ; -- 50MHz to 34800
type FIFO_t is array (0 to tblen-1) of std_logic_vector(9 downto 2);
type FIFO_r is array (0 to rblen-1) of std_logic_vector(9 downto 2);
Signal tFIFO: FIFO_t;
	attribute ramstyle : string;
   attribute ramstyle of tFIFO : signal is "no_rw_check";
Signal rFIFO: FIFO_r;
	attribute ramstyle of rFIFO : signal is "logic";
Signal inb,outb: std_logic_vector(9 downto 2);
Signal rcounter,tcounter :natural range 0 to 4095:=1;
signal dr: boolean:=false;
signal rd:boolean :=true;
signal rptr1, rptr2: natural range 0 to rblen := 0; 
signal tptr1, tptr2: natural range 0 to tblen := 0; 
signal rstate,tstate: natural range 0 to 15 :=0 ;
signal rx0,rx1:std_logic:='1';

begin

	process (clk,reset)
	
   variable wa,ra:boolean :=false ;

	begin
		if (reset='1') then 
			rptr1<=0; rptr2<=0; data_ready<='0'; ready<='1'; rcounter<=1; rstate<=0; tstate<=0;
			tcounter<=1; tptr1<=0; tptr2<=0; dr<=false; rd<=true; wa:=false; ra:=false; 
			Tx<='1';  rx0<='1'; rx1<='1'; --rFIFO<=(OTHERS=>"00000000"); 
		elsif  clk'EVENT  and clk = '1' then
			rcounter<=rcounter+1; 
			tcounter<=tcounter+1;
			rx1<=Rx; rx0<=rx1;
			if rcounter=divider or (rstate=0 and rx1='0' and rx0='0' and Rx='0') then	
				if rstate=0 and Rx='0' and rx1='0' and rx0='0' then
					rcounter<=divider/2;	
					rstate<=1; 
				elsif rstate=1 then
					rstate<=rstate+1;
					rcounter<=1;
				elsif rstate>0 and rstate<10 then
					inb(rstate)<=Rx;
					rcounter<=1;
					rstate<=rstate+1;
				elsif rstate=10 then
					rcounter<=1;
					rstate<=0;
					rFIFO(rptr2)<=inb;
					if rptr2+1<rblen then 
						if rptr2+1 /= rptr1 then
							rptr2<=rptr2+1;
						end if;
					else
						if rptr1/=0 then
							rptr2<=0; 
						end if;
					end if;
					data_ready<='1'; dr<=true;
				else
					rcounter<=1;
				end if;
			end if;
			
			
			if tcounter=divider then
				
				if tstate=0 and ( tptr1/=tptr2 or rd=false) then
					tcounter<=1;
					Tx<='0';
					outb<=tFIFO(tptr1);
					tstate<=2;
				elsif tstate>1 and tstate<10 then
					TX<=outb(tstate);
					tcounter<=1;
					tstate<=tstate+1;
				elsif tstate=10 then
					Tx<='1';
					tcounter<=1;
					tstate<=0;
					if tptr1<tblen-1 then tptr1<=tptr1+1; else tptr1<=0; end if;
					ready<='1'; rd<=true;
				else
					tcounter<=1;
					Tx<='1';
				end if;
			end if;
			
			
			if r='1' and ra=false then 
				if dr then
					data_out<=rFIFO(rptr1);
					if rptr1+1<rblen then 
						rptr1<=rptr1+1;
						if rptr1+1 = rptr2 then data_ready<='0'; dr<=false; end if;
					else
						rptr1<=0; 
						if rptr2=0 then data_ready<='0'; dr<=false; end if;
					end if;
				end if;
				ra:=true;
			else
				if r='0' then ra:=false; end if;
				if dr=true then data_out<=rFIFO(rptr1); end if;
			end if;
			
			if w='1' and rd=true and wa=false then
				wa:=true;
				tFIFO(tptr2)<=data_in;
				if tptr2<tblen-1 then
					if tptr2+1=tptr1 then  ready<='0'; rd<=false; end if;
					tptr2<=tptr2+1;
				else
					tptr2<=0;
					if tptr1=0 then ready<='0'; rd<=false;	end if;
				end if;
			else
				if w='0' then wa:=false; end if;
			end if;
			
		end if;
	end process;
end behavior;



Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity SKEYB is
	port
	(
		Rx  : IN std_logic ;
		clk, reset, r : IN std_logic ;
		data_ready : OUT std_logic;
		data_out :OUT std_logic_vector (7 downto 0)
	);
end SKEYB;

Architecture Behavior of SKEYB is

constant rblen:natural:=8;
constant divider:natural :=2604; -- 19200       650  25MHz/38400   1302 ; -- 50MHz to 34800
type FIFO_r is array (0 to rblen-1) of std_logic_vector(9 downto 2);
Signal rFIFO: FIFO_r;
Signal inb: std_logic_vector(9 downto 2);
Signal rcounter:natural range 0 to 4095:=1;
signal dr: boolean:=false;
signal rptr1, rptr2: natural range 0 to rblen := 0; 
signal rstate: natural range 0 to 15 :=0 ;
Signal rx1,Rx2: std_logic;

begin

rx1<=Rx when clk'EVENT  and clk = '1';
Rx2<=rx1 when clk'EVENT  and clk = '1';

	process (clk,reset)
	
   variable ra:boolean :=false ;

	begin
		if (reset='1') then 
			rptr1<=0; rptr2<=0; data_ready<='0'; rcounter<=1; rstate<=0;
			 dr<=false; ra:=false; 
		elsif  clk'EVENT  and clk = '1' then
			rcounter<=rcounter+1;
			
			if rcounter=divider or (rstate=0 and Rx2='0') then	
				if rstate=0 and Rx2='0' then
					rcounter<=divider/4;	
					rstate<=1; 
				elsif rstate=1 then
					rstate<=rstate+1;
					rcounter<=1;
				elsif rstate>0 and rstate<10 then
					inb(rstate)<=Rx2;
					rcounter<=1;
					rstate<=rstate+1;
				elsif rstate=10 then
					rcounter<=1;
					rstate<=0;
					rFIFO(rptr2)<=inb;
					if rptr2+1<rblen then 
						if rptr2+1 /= rptr1 then
							rptr2<=rptr2+1;
						end if;
					else
						if rptr1/=0 then
							rptr2<=0; 
						end if;
					end if;
					data_ready<='1'; dr<=true;
				else
					rcounter<=1;
				end if;
			end if;
			
			
			if r='1' and ra=false then 
				if dr then
					data_out<=rFIFO(rptr1);
					if rptr1+1<rblen then 
						rptr1<=rptr1+1;
						if rptr1+1 = rptr2 then data_ready<='0'; dr<=false; end if;
					else
						rptr1<=0; 
						if rptr2=0 then data_ready<='0'; dr<=false; end if;
					end if;
				end if;
				ra:=true;
			else
				if r='0' then ra:=false; end if;
				if dr=true then data_out<=rFIFO(rptr1); end if;
			end if;
			
		end if;
	end process;
end behavior;
