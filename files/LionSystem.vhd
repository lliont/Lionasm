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
		RWo, AS, DS : OUT Std_logic;
		RD, Reset, clock, Int,HOLD: IN Std_Logic;
		IOo,A16,HOLDA : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0)
	);
end Component;

Component LPLL2 IS
	PORT
	(
		inclk0: IN STD_LOGIC  := '0';
		c0,c1,c2,c3,c4		: OUT STD_LOGIC 
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
		play: OUT  std_logic;
		Inter: OUT std_logic;
		IAC: IN std_logic
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
Signal Vmod,R0,B0,G0,BRI0,R1,G1,B1,BRI1,SR2,SG2,SB2,SBRI2,SPDET2,SR3,SG3,SB3,SBRI3,SPDET3,SR1,SB1,SG1,SBRI1,SPDET1: std_logic;
Signal clock0,clock1,clock2,clock3,clock4,hsyn0,vsyn0,hsyn1,vsyn1,vint0,vint1: std_logic;
Signal qi1,vq: std_logic_vector (15 downto 0);
Signal di,do,AD,qa,qro,aq,aq2 : std_logic_vector(15 downto 0);
Signal q16,count : std_logic_vector(15 downto 0);
Signal w1, Int_in, AS, DS, RW, IO, A16, HOLDA, WAud, WAud2,inter,vint: std_logic;
Signal nen, ne: std_logic:='0';
Signal rst: std_logic:='1';
Signal spw1, spw2,  spw3: std_logic;
Signal SPQ1,spvq1,SPQ2,spvq2,SPQ3,spvq3: std_logic_vector(15 downto 0);
Signal Ii,IA : std_logic_vector(1 downto 0);
Signal ad1,vad0,vad1,vad2,ad2 :  natural range 0 to 16383;
Signal spad2,spad4,spad6,spad1,spad3,spad5 :  natural range 0 to 2047;
Signal sr,sw,sdready,sready,ser2,sdready2, IAC, noise: std_Logic;
Signal sdi,sdo,sdo2 : std_logic_vector (7 downto 0);
SIGNAL addr : natural range 0 to 65535;
Signal addr1 : natural range 0 to 4095;
SIGNAL Spi_in,Spi_out: STD_LOGIC_VECTOR (7 downto 0);
Signal Spi_w, spi_rdy, play, play2, spb, sdb : std_logic;

shared variable Dii:std_logic_vector(15 downto 0);

begin
CPU: LionCPU16 
	PORT MAP ( Dii, Do, AD, RW,AS,DS,RD,rst,clock0,Int_in,Hold,IO,A16,Holda,Ii,Iac,IA ) ; 
VRAM: dual_port_ram_single_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 14)
	PORT MAP ( clock4, ad1, ad2, Do, w1,vq, q16  );
SPRAM: dual_port_ram_single_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock4, spad1, spad2, Do, spw1, spvq1, SPQ1  );
SPRAM2: dual_port_ram_single_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock4, spad3, spad4, Do,  spw2, spvq2, SPQ2  );
SPRAM3: dual_port_ram_single_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock4, spad5, spad6, Do, spw3, spvq3, SPQ3  );
VIDEO0: videoRGB80
	PORT MAP ( clock3, Vmod, R0,G0,B0,BRI0,VSYN0, HSYN0, vint0,vad0, vq);
VIDEO1: videoRGB1
	PORT MAP ( clock3, Vmod, R1,G1,B1,BRI1,VSYN1, HSYN1, vint1,vad1, vq);
SPRTG1: VideoSp
	PORT MAP ( clock3,SR1,SG1,SB1,SBRI1,SPDET1, vint, spb, sdb, spad1, spvq1);
SPRTG2: VideoSp
	PORT MAP ( clock3,SR2,SG2,SB2,SBRI2,SPDET2, vint, spb, sdb, spad3, spvq2);
SPRTG3: VideoSp
	PORT MAP ( clock3,SR3,SG3,SB3,SBRI3,SPDET3, vint, spb, sdb, spad5, spvq3);
Serial: UART
	PORT MAP ( Tx, Rx, clock1, reset, sr, sw, sdready, sready, sdi, sdo );
SERKEYB: SKEYB
	PORT MAP (Rx2, clock1, reset, ser2, sdready2, sdo2);
SoundIC: SoundI
	PORT MAP (AUDIO, rst, clock1, Waud, aq, count, play, Inter, IAC);
SoundC: Sound
	PORT MAP (AUDIOB, rst, clock1, Waud2, aq2, play2);
--IRAM: single_port_ram
--	PORT MAP ( clock0, addr1, Do, RW, DS, QA ) ;
IROM: single_port_rom
	PORT MAP ( clock1, addr1, QRO ) ;
MSPI: SPI 
	PORT MAP ( SCLK,MOSI,MISO,clock1,rst,spi_w,spi_rdy,spi_in,spi_out);
NOIZ:lfsr
	PORT MAP ( noise, clock1, reset);
CPLL:LPLL2
	PORT MAP (iClock,Clock0,Clock1,Clock2,clock3,clock4);

-- data out 
rst<=reset when rdelay=7 and rising_edge(clock0) else '1' when rising_edge(clock0);
rdelay<= rdelay+1 when rising_edge(clock0) and rdelay/=7 and reset='0' else 0 when rising_edge(clock0) and reset='1';
HOLDAo<=HOLDA;
A16o<=A16;
A17o<='Z';
--Di<=Dii;
ASo<=AS when HOLDA='0' else 'Z'; 
DSo<=DS when HOLDA='0' else 'Z'; 
IOo<=IO when HOLDA='0' else 'Z'; 
RWo<=RW when HOLDA='0' else 'Z';
D<= Do when (RW='0' and DS='0') AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
ADo<= AD when AS='0' AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
IACK<=IAC;

addr1<=to_integer(unsigned(AD(12 downto 1))) when AS='0' and IO='0';
ad2<=to_integer(unsigned(AD(14 downto 1))) when AS='0' and IO='1' and AD(15)='1';
spad2<=to_integer(unsigned(AD(11 downto 1))) when AS='0' and AD(15 downto 12)="0100";
spad4<=to_integer(unsigned(AD(11 downto 1))) when AS='0' and AD(15 downto 12)="0101";
spad6<=to_integer(unsigned(AD(11 downto 1))) when AS='0' and AD(15 downto 12)="0110";
ne<='1' when (nen='1') and (aq(11 downto 0)/="000000000000") else '0';
--AUDIO<= AUDIO1 ;
NOIS<=NOISE and (play or play2) and ne;
--audiob<=audio2;
R<= SR1 when  SPDET1='1' else SR2 when  SPDET2='1' else SR3 when SPDET3='1' else R1 when Vmod='1' else R0;
G<= SG1 when  SPDET1='1' else SG2 when  SPDET2='1' else SG3 when SPDET3='1' else G1 when Vmod='1' else G0;
B<= SB1 when  SPDET1='1' else SB2 when  SPDET2='1' else SB3 when SPDET3='1' else B1 when Vmod='1' else B0;
BRI<= SBRI1 when SPDET1='1' else SBRI2 when SPDET2='1' else SBRI3 when SPDET3='1' else BRI1 when Vmod='1' else BRI0;
																	  
ad1<=vad1 when Vmod='1' else vad0;
HSYN<=HSYN1 when Vmod='1' else HSYN0;
VSYN<=VSYN1 when Vmod='1' else VSYN0;
Vint<=Vint1 when Vmod='1' else Vint0;

w1<='1' when IO='0' else '0' when  AS='0' and DS='0' and IO='1' and AD(15)='1' and (RW='0') else '1'; 
spw1<='1' when IO='0' else '0' when AS='0' and DS='0' and IO='1' and AD(15 downto 12)="0100" and (RW='0')  else '1' ;
spw2<='1' when IO='0' else '0' when AS='0' and DS='0' and IO='1' and AD(15 downto 12)="0101" and (RW='0')  else '1' ;
spw3<='1' when IO='0' else '0' when AS='0' and DS='0' and IO='1' and AD(15 downto 12)="0110" and (RW='0')  else '1' ;

-- UART SKEYB SPI IO decoding
sdi<=Do(7 downto 0) when AD=0 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
sr<=Do(1) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
ser2<=Do(1) when AD=15 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1); 
sw<=Do(0) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spi_w<=Do(0) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
SPICS<=Do(1) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spi_in<=Do(7 downto 0) when AD=18 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spb<=Do(1) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
sdb<=Do(0) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);

Vmod<='0' when reset='1' and rising_edge(clock1) else Do(0) when AD=24 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
 --Sound IO decoding 
aq<=Do when AD=8 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);   -- port 8
aq2<=Do when  AD=10 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 10
nen<=Do(0) when  AD=11 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);    -- noise enable
Waud<='0' when AD=8  and IO='1' and AS='0'  and RW='0' and rising_edge(clock1) else '1' when rising_edge(clock1);
Waud2<='0' when AD=10 and IO='1' and AS='0' and RW='0' and rising_edge(clock1) else '1' when rising_edge(clock1);

-- Read decoder

process (clock1)
begin
	if rising_edge(clock1) and RW='1' and AS='0' AND IO='1'  then
		if AD(15)='1' then Dii:=q16;  --video
		elsif AD(15 downto 12)="0100" then Dii:=SPQ1;
		elsif AD(15 downto 12)="0101" then Dii:=SPQ2;
		elsif AD(15 downto 12)="0110" then Dii:=SPQ3;
		elsif AD=4 then Dii:="00000000"&sdo;  -- serial1
		elsif AD=14 then Dii:="00000000"&sdo2;  -- serial2 keyboard
		elsif AD=6 then Dii:="0000000000000" & sdready2 & sdready & sready;  -- serial status
		elsif AD=16 then Dii:="00000000"&spi_out;   --spi 
		elsif AD=17 then Dii:="000000000000000" & spi_rdy;  --spi 
		elsif AD=9 then Dii:="00000000000000"& play2 & play; -- audio status
		elsif AD=22 then Dii:="000"&JOYST2&"000"& JOYST1;     -- joysticks
		elsif AD=20 then Dii:=count;
		elsif AD=21 then Dii:="00000000000000"&Vsyn&hsyn;    -- VSYNCH HSYNCH STATUS
		elsif AD=24 then Dii:="000000000000000"&Vmod;
		end if;
	end if;
	if rising_edge(clock1) and RW='1' and AS='0' AND IO='0'  then
		if (AD<8192) then Dii:=qro; else Dii:=D; end if;
	end if;
end process ;
	
Mdecod1 <= '0' when (AS='0') and (IO='0') AND (HOLDA='0') else '1';  -- (AD(15 downto 13)/="000") External 56K ram chip select 

Int_in <= (Int and VINT) when   reset='0' else '1' when reset='1' ;
Ii<="11" when VINT='0' else 
	 "00"	when int='0'  else
		"11";
	
end Behavior;
----------------------------------------------




library ieee;
use ieee.std_logic_1164.all;

entity dual_port_ram_single_clock is

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
		--data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		--we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end dual_port_ram_single_clock;

architecture rtl of dual_port_ram_single_clock is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM 
	Signal ram : memory_t;

begin
	process(clk)
	begin
	if(rising_edge(clk)) then 
		q_b <= ram(addr_b);
		q_a <= ram(addr_a);
		if(we_b = '0') then
			ram(addr_b) <= data_b;
		end if;
	end if;
	end process;

end rtl;



-- Quartus II VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity single_port_ram is

	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 32767;
		data	: in std_logic_vector(15 downto 0);
		we,DS		: in std_logic := '1';
		q		: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(8191+8192 downto 0) of word_t;

	function init_ram
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
	--Ram
	return tmp; -- ram
	end init_ram;
	
	-- Declare the RAM signal.	
	signal ram : memory_t; --:=init_ram;
	--attribute ram_init_file : string;
	--attribute ram_init_file of ram : signal is "Lionasm\bin\Debug\liontinyb.asm.mif";
	-- Register to hold the address 
	signal addr_reg : natural range 0 to 32767;

begin

	process(clk)
		variable ad2: natural range 0 to 32767;
	begin
	if (Clk'EVENT AND Clk = '1') then
		if (addr>=4096)  then
			ad2:=addr-4096;
			if (WE = '0') and (DS='0') then
				ram(ad2) <= data;
			end if;
			-- Register the address for reading
			addr_reg <= ad2;
		end if;
	end if;
	end process;
	
	q <= ram(addr_reg);

end rtl;


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

	function init_rom
		return memory_t is 
		variable tmp : memory_t; -- := (others => (others => '0'));
	begin
	
--  Rom 
	return tmp;
	end init_rom;	 

signal rom : memory_t:= init_rom;
	attribute ram_init_file : string;
	attribute ram_init_file of rom : signal is "C:\intelFPGA_lite\LionSys_EP4_15\Lionasm\bin\Debug\lionrom.asm.mif";
	
begin
	process(clk)
	begin
		if(Clk'EVENT AND Clk = '1' ) then
				q <= rom(addr);
		end if;
	end process;
end rtl;

