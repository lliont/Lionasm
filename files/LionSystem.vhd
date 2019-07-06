-- Lion Computer 
-- Theodoulos Liontakis (C) 2015 

Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity LionSystem is
	port
	(
		D  : INOUT  Std_logic_vector(15 downto 0);
		ADo  : OUT  Std_logic_vector(15 downto 0); 
		RWo,ASo,DSo : OUT Std_logic;
		RD,Reset,iClock,HOLD: IN Std_Logic;
		Int: IN Std_Logic;
		IOo,A16o,A17o,Holdao : OUT std_logic;
		--I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		--IA : OUT std_logic_vector(1 downto 0);
		R,G,B,VSYN,HSYN, BRI : OUT std_Logic;
		Tx  : OUT std_logic ;
		Rx, Rx2  : IN std_logic ;
		Mdecod1: OUT std_logic;
		AUDIO,AUDIOB,NOIS: OUT std_logic;
		SCLK,MOSI,SPICS: OUT std_logic;
		MISO: IN std_logic;
		JOYST1,JOYST2: IN std_logic_vector(4 downto 0)
	);
end LionSystem;

Architecture Behavior of LionSystem is

Component LionCPU16 is
	port
	(
		Di   : IN  Std_logic_vector(15 downto 0);
		DOo  : OUT  Std_logic_vector(15 downto 0);
		ADo   : OUT  Std_logic_vector(15 downto 0); 
		RW, AS, DS: OUT Std_logic;
		RD, Reset, clock, Int,HOLD: IN Std_Logic;
		IO,HOLDA,A16o,A17o,A18o,A19o : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0)
	);
end Component;

Component LPLL2 IS
	PORT
	(
		inclk0: IN STD_LOGIC  := '0';
		c0,c1,c2	: OUT STD_LOGIC 
	);
END Component;


Component lfsr is
  port (
    cout   :out std_logic;      -- Output
    clk    :in  std_logic;      -- Input rlock
    reset  :in  std_logic       -- Input reset
  );
end Component;

Component VideoRGB80 is
	port
	(
		sclk, EN : IN std_logic;
		R,G,B,BRI0,VSYN,HSYN,VSINT : OUT std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(15 downto 0)
	);
end Component;

Component VideoRGB1 is
	port
	(
		sclk, EN : IN std_logic;
		R,G,B,BRI,VSYN,HSYN,VSINT : OUT std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(15 downto 0)
	);
end Component;


Component dual_port_ram_single_clock is

	generic 
	(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 11
	);

	port 
	(
		clk		: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_b	   : in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end Component;

Component dual_port_ram_dual_clock is

	generic 
	(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 11
	);

	port 
	(
		clka,clkb: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_b	   : in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end Component;

Component UART is
	port
	(
		Tx  : OUT std_logic ;
		Rx  : IN std_logic ;
		clk, reset, r, w : IN std_logic ;
		data_ready, ready : OUT std_logic;
		data_in : IN std_logic_vector (7 downto 0);
		data_out :OUT std_logic_vector (7 downto 0)
	);
end Component;

Component SKEYB is
	port
	(
		Rx  : IN std_logic ;
		clk, reset, r : IN std_logic ;
		data_ready : OUT std_logic;
		data_out :OUT std_logic_vector (7 downto 0)
	);
end Component;

Component SoundI is
	port
	(
		Aud: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		count: OUT std_logic_vector(15 downto 0);
		play: OUT  std_logic
	);
end Component;

Component Sound is
	port
	(
		Aud: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		play: OUT  std_logic
	);
end Component;

COMPONENT single_port_rom is
	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 4095;
		q		: out std_logic_vector(15 downto 0)
	);
end component;

--COMPONENT single_port_ram is
--	port 
--	(
--		clk		: in std_logic;
--		addr	: in natural range 0 to 32767;
--		data	: in std_logic_vector(15 downto 0);
--		we,DS		: in std_logic := '1';
--		q		: out std_logic_vector(15 downto 0)
--	);
--end COMPONENT;

COMPONENT SPI is
	port
	(
		SCLK, MOSI : OUT std_logic ;
		MISO  : IN std_logic ;
		clk, reset, w: IN std_logic ;
		ready : OUT std_logic;
		data_in : IN std_logic_vector (7 downto 0);
		data_out :OUT std_logic_vector (7 downto 0)
	);
end COMPONENT;

COMPONENT VideoSp is
	generic 
	(
		DATA_LINE : natural := 1
	);
	port
	(
		sclk: IN std_logic;
		R,G,B,BRI,SPDET: OUT std_logic;
		reset, pbuffer, dbuffer : IN std_logic;
		spaddr: OUT natural range 0 to 2047;
		SPQ: IN std_logic_vector(15 downto 0)
	);
end COMPONENT;

constant ZERO16 : std_logic_vector(15 downto 0):= (OTHERS => '0');

Signal rdelay: natural range 0 to 7 :=0;
Signal R0,B0,G0,BRI0,R1,G1,B1,BRI1,SR2,SG2,SB2,SBRI2,SPDET2,SR3,SG3,SB3,SBRI3,SPDET3,SR1,SB1,SG1,SBRI1,SPDET1: std_logic;
Signal clock0,clock1,clock2:std_logic;
Signal hsyn0,vsyn0,hsyn1,vsyn1: std_logic;
Signal vq: std_logic_vector (15 downto 0);
Signal di,do,AD,qa,qro,aq,aq2,q16,count : std_logic_vector(15 downto 0);
Signal w1,  WAud, WAud2: std_logic;
Signal HOLDA, A16, A17, A18, A19, IO, Vmod, nen, ne: std_logic:='0';
Signal AS, DS, RW, Int_in, rst, vint,vint0,vint1: std_logic:='1';
Signal spw1, spw2, spw3: std_logic;
Signal SPQ1,spvq1,SPQ2,spvq2,SPQ3,spvq3: std_logic_vector(15 downto 0);
Signal Ii,IA : std_logic_vector(1 downto 0);
Signal ad1,vad0,vad1 :  natural range 0 to 16383;
Signal spad1,spad3,spad5 :  natural range 0 to 2047;
Signal sr,sw,sdready,sready,ser2,sdready2, IAC, noise: std_Logic;
Signal sdi,sdo,sdo2 : std_logic_vector (7 downto 0);
SIGNAL addr : natural range 0 to 65535;
SIGNAL Spi_in,Spi_out: STD_LOGIC_VECTOR (7 downto 0);
Signal Spi_w, spi_rdy, play, play2, spb, sdb : std_logic;

shared variable Di1,Di2:std_logic_vector(15 downto 0);

begin
CPU: LionCPU16 
	PORT MAP ( Di,Do,AD,RW,AS,DS,RD,rst,clock0,Int_in,Hold,IO,Holda,A16,A17,A18,A19,Ii,Iac,IA ) ; 
VRAM: dual_port_ram_dual_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 14)
	PORT MAP ( clock0, clock1, ad1, to_integer(unsigned(AD(14 downto 1))), Do, w1, vq, q16 );
SPRAM: dual_port_ram_dual_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock0,clock1, spad1, to_integer(unsigned(AD(11 downto 1))), Do, spw1, spvq1, SPQ1 );
SPRAM2: dual_port_ram_dual_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock0,clock1, spad3, to_integer(unsigned(AD(11 downto 1))), Do,  spw2, spvq2, SPQ2 );
SPRAM3: dual_port_ram_dual_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock0,clock1, spad5, to_integer(unsigned(AD(11 downto 1))), Do, spw3, spvq3, SPQ3 );
VIDEO0: videoRGB80
	PORT MAP ( clock1, Vmod, R0,G0,B0,BRI0,VSYN0,HSYN0,vint0,vad0,vq);
VIDEO1: videoRGB1
	PORT MAP ( clock1, Vmod, R1,G1,B1,BRI1,VSYN1,HSYN1,vint1,vad1,vq);
SPRTG1: VideoSp
	GENERIC MAP (DATA_LINE  => 1)
	PORT MAP ( clock1,SR1,SG1,SB1,SBRI1,SPDET1,vint,spb,sdb,spad1,spvq1);
SPRTG2: VideoSp
	GENERIC MAP (DATA_LINE  => 2)
	PORT MAP ( clock1,SR2,SG2,SB2,SBRI2,SPDET2,vint,spb,sdb,spad3,spvq2);
SPRTG3: VideoSp
	GENERIC MAP (DATA_LINE  => 3)
	PORT MAP ( clock1,SR3,SG3,SB3,SBRI3,SPDET3,vint,spb,sdb,spad5,spvq3);
Serial: UART
	PORT MAP ( Tx,Rx,clock1,rst,sr,sw,sdready,sready,sdi,sdo );
SERKEYB: SKEYB
	PORT MAP (Rx2,clock1,reset,ser2,sdready2,sdo2);
SoundIC: SoundI
	PORT MAP (AUDIO,rst,clock1,Waud,aq,count,play);
SoundC: Sound
	PORT MAP (AUDIOB, rst, clock1, Waud2, aq2, play2);
--IRAM: single_port_ram
--	PORT MAP ( clock0, addr1, Do, RW, DS, QA ) ;
IROM: single_port_rom
	PORT MAP ( clock1, to_integer(unsigned(AD(12 downto 1))), QRO ) ;
MSPI: SPI 
	PORT MAP ( SCLK,MOSI,MISO,clock1,rst,spi_w,spi_rdy,spi_in,spi_out);
NOIZ:lfsr
	PORT MAP ( noise, clock1, rst);
CPLL:LPLL2
	PORT MAP (iClock,Clock0,Clock1,clock2);
--LCLK: Lclock
--	PORT MAP (iclock,giclock);
	
-- data out 
rst<=reset when rdelay=7 and rising_edge(clock0) else '1' when rising_edge(clock0);
rdelay<= rdelay+1 when rising_edge(clock0) and rdelay/=7 and reset='0' else 0 when rising_edge(clock0) and reset='1';
HOLDAo<=HOLDA;
Di<=Di1 when IO='1' else DI2;
A16o<=A16 when HOLDA='0' else 'Z';
A17o<=A17 when HOLDA='0' else 'Z';
ASo<=AS when HOLDA='0' else 'Z'; 
DSo<=DS when HOLDA='0' else 'Z'; 
IOo<=IO when HOLDA='0' else 'Z'; 
RWo<=RW when HOLDA='0' else 'Z';
D<= Do when (RW='0' and DS='0') AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
ADo<= AD when AS='0' AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
IACK<=IAC;

ne<='1' when (nen='1') and (aq(11 downto 0)/="000000000000") else '0';
NOIS<=NOISE and (play or play2) and ne;

R<= SR1 when  SPDET1='1' else SR2 when  SPDET2='1' else SR3 when SPDET3='1' else R1 when Vmod='1' else R0;
G<= SG1 when  SPDET1='1' else SG2 when  SPDET2='1' else SG3 when SPDET3='1' else G1 when Vmod='1' else G0;
B<= SB1 when  SPDET1='1' else SB2 when  SPDET2='1' else SB3 when SPDET3='1' else B1 when Vmod='1' else B0;
BRI<= SBRI1 when SPDET1='1' else SBRI2 when SPDET2='1' else SBRI3 when SPDET3='1' else BRI1 when Vmod='1' else BRI0;
																	  
ad1<=vad1 when Vmod='1' else vad0;
HSYN<=HSYN1 when Vmod='1' else HSYN0;
VSYN<=VSYN1 when Vmod='1' else VSYN0;
--Vint<=Vint1 when Vmod='1' else Vint0 when Vmod='0';

w1<=  '1' when DS='0' and AS='0' and IO='1' and AD(15)='1'              and RW='0' else '0'; 
spw1<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0100" and RW='0' else '0' ;
spw2<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0101" and RW='0' else '0' ;
spw3<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0110" and RW='0' else '0' ;

-- Interrupts 
process (clock1,INT)
begin
if rising_edge(clock1) then
	if Vmod='1' then Vint<=Vint1; else Vint<=Vint0; end if;
	if INT='0' then  II<="00"; else II<="11"; end if;
	Int_in<= INT and VINT;
end if;
end process;

-- UART SKEYB SPI IO decoding
sdi<=Do(7 downto 0) when AD=0 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
sr<=Do(1) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
ser2<=Do(1) when AD=15 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0); 
sw<=Do(0) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
spi_w<=Do(0) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
SPICS<=Do(1) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
spi_in<=Do(7 downto 0) when AD=18 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
spb<=Do(1) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);
sdb<=Do(0) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);

Vmod<='0' when rst='1' and rising_edge(clock0) else Do(0) when AD=24 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock0);

 --Sound IO decoding 
aq<=Do when AD=8 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock0);   -- port 8
aq2<=Do when  AD=10 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock0);  -- port 10
nen<=Do(0) when  AD=11 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock0);    -- noise enable
Waud<='0' when AD=8  and IO='1' and AS='0'  and RW='0' and rising_edge(clock0) else '1' when rising_edge(clock0);
Waud2<='0' when AD=10 and IO='1' and AS='0' and RW='0' and rising_edge(clock0) else '1' when rising_edge(clock0);

-- Read decoder
process (clock1,RW,AS,IO)
begin
	if rising_edge(clock1) and RW='1' and AS='0' AND IO='1'  then
		if AD(15)='1' then Di1:=q16; end if; --video
		if AD(15 downto 12)="0100" then Di1:=SPQ1; end if;
		if AD(15 downto 12)="0101" then Di1:=SPQ2; end if;
		if AD(15 downto 12)="0110" then Di1:=SPQ3; end if;
		if AD=4 then Di1:="00000000"&sdo; end if;  -- serial1
		if AD=14 then Di1:="00000000"&sdo2; end if;  -- serial2 keyboard
		if AD=6 then Di1:="0000000000000" & sdready2 & sdready & sready; end if; -- serial status
		if AD=16 then Di1:="00000000"&spi_out; end if;  --spi 
		if AD=17 then Di1:="000000000000000" & spi_rdy; end if; --spi 
		if AD=9 then Di1:="00000000000000"& play2 & play; end if; -- audio status
		if AD=22 then Di1:="000"&JOYST2&"000"& JOYST1; end if;     -- joysticks
		if AD=20 then Di1:=count; end if;
		if AD=21 then Di1:="00000000000000"&Vsyn&hsyn; end if;   -- VSYNCH HSYNCH STATUS
		if AD=24 then Di1:="000000000000000"&Vmod; end if;
	end if;
end process;

process (clock1,RW,AS,IO)
begin
	if rising_edge(clock1) and RW='1' and AS='0' AND IO='0'  then
		if (AD<8192) and A16='0' and A17='0' then Di2:=qro; else Di2:=D; end if;
	end if;
end process ;
	
Mdecod1 <= '0' when (AS='0') and (IO='0') AND (HOLDA='0') else '1';  --  External  ram chip select 
	
end Behavior;

----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dual_port_ram_dual_clock is

	generic 
	(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 14
	);

	port 
	(
		clka,clkb: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_b	: in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end dual_port_ram_dual_clock;

architecture rtl of dual_port_ram_dual_clock is

subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;
    
signal ram : memory_t;
attribute ramstyle : string;
attribute ramstyle of ram : signal is "no_rw_check";
begin
	process(clkb)
	begin
		if(rising_edge(clkb)) then 
			if we_b='1' then	ram(addr_b) <= data_b; q_b<=data_b; 
			else q_b <= ram(addr_b); end if;
		end if;
	end process;

	process(clka)
	begin
		if(rising_edge(clka)) then 
			q_a <= ram(addr_a);
		end if;
	end process;
end rtl;

------------------------------------------------------
-- Quartus II VHDL Template
-- Single-Port ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_rom is

	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 4095;
		q		: out std_logic_vector(15 downto 0)
	);

end entity;

architecture rtl of single_port_rom is

	-- Build a 2-D array type for the RoM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(4095 downto 0) of word_t;

signal rom : memory_t;
	attribute ram_init_file : string;
	attribute ram_init_file of rom : signal is "C:\intelFPGA_lite\LionSys_EP4_15\Lionasm\bin\Debug\lionrom.mif";
	
begin
	process(clk)
	begin
		if(Clk'EVENT AND Clk = '1' ) then
				q <= rom(addr);
		end if;
	end process;
end rtl;

