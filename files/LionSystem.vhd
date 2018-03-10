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
		RD,Reset,Clock,Int,HOLD: IN Std_Logic;
		IOo, Holdao : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0);
		R,G,B,VSYN,HSYN : OUT std_Logic;
		Tx  : OUT std_logic ;
		Rx, Rx2  : IN std_logic ;
		Mdecod1: OUT std_logic;
		AUDIO: OUT std_logic;
		SCLK,MOSI,SPICS: OUT std_logic;
		MISO: IN std_logic;
		LED: OUT std_logic_vector(7 downto 0);
		JOYST1: IN std_logic_vector(4 downto 0)
	);
end LionSystem;

Architecture Behavior of LionSystem is

Component LionCPU16 is
	port
	(
		Di   : IN  Std_logic_vector(15 downto 0);
		DOo  : OUT  Std_logic_vector(15 downto 0);
		AD   : OUT  Std_logic_vector(15 downto 0); 
		RWo, ASo, DSo : OUT Std_logic;
		RD, Reset, Clock, Int, HOLD: IN Std_Logic;
		IO, HOLDA : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0)
	);
end Component;

Component VideoRGB is
	port
	(
		sclk : IN std_logic;
		R,G,B,VSYN,HSYN,VSINT : OUT std_logic;
		reset, pbuffer, dbuffer, addxy : IN std_logic;
		addr : OUT natural range 0 to 8191;
		Q : IN std_logic_vector(15 downto 0)
	);
end Component;



Component true_dual_port_ram_single_clock is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 14
	);

	port 
	(
		clk		: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end Component;

Component mixed_width_true_dual_port_ram is
    
	generic (
		DATA_WIDTH1    : natural :=  8;
		ADDRESS_WIDTH1 : natural :=  14;                
		ADDRESS_WIDTH2 : natural :=  13);

	port (
	we1   : in std_logic;
	we2   : in std_logic;
	clk   : in std_logic;
	addr1 : in natural range 0 to (2 ** ADDRESS_WIDTH1 - 1);
	addr2 : in natural range 0 to (2 ** ADDRESS_WIDTH2 - 1);
	data_in1 : in  std_logic_vector(DATA_WIDTH1 - 1 downto 0);
	data_in2 : in  std_logic_vector(DATA_WIDTH1 * (2 ** (ADDRESS_WIDTH1 - ADDRESS_WIDTH2)) - 1 downto 0);                
	data_out1   : out std_logic_vector(DATA_WIDTH1 - 1 downto 0);
	data_out2   : out std_logic_vector(DATA_WIDTH1 * 2 ** (ADDRESS_WIDTH1 - ADDRESS_WIDTH2) - 1 downto 0));

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
		addr	: in natural range 0 to 65535;
		q		: out std_logic_vector(15 downto 0)
	);
end component;

COMPONENT single_port_ram is
	port 
	(
		clk		: in std_logic;
		addr	: in natural range 0 to 65535;
		data	: in std_logic_vector(15 downto 0);
		we,DS		: in std_logic := '1';
		q		: out std_logic_vector(15 downto 0)
	);
end COMPONENT;

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

Signal qi1,vq : std_logic_vector (15 downto 0);
Signal di,do,AD,qa,qro,aq,aq2 : std_logic_vector(15 downto 0);
Signal qi,q16,count : std_logic_vector(15 downto 0);
Signal w1, w2, Int_in, AS, DS, RW, IO, HOLDA, WAud, WAud2,inter,vint : std_logic;
Signal Ii : std_logic_vector(1 downto 0);
Signal qi2 : std_logic_vector(7 downto 0);
Signal ad1 :  natural range 0 to 16383;
Signal ad2 :  natural range 0 to 16383;
Signal sr,sw,sdready,sready,sr2,sdready2, vs, IAC: std_Logic;
Signal sdi,sdo,sdo2 : std_logic_vector (7 downto 0);
SIGNAL addr,addr1 : natural range 0 to 65535;
SIGNAL Spi_in,Spi_out: STD_LOGIC_VECTOR (7 downto 0);
Signal Spi_w,spi_rdy, play, play2, AUDIO1 ,AUDIO2, spb, sdb, adxy : std_logic;

begin
CPU: LionCPU16 
	PORT MAP ( Di, Do, AD, RW,AS,DS,RD,Reset,Clock,Int_in,Hold,IO,Holda,Ii,Iac,IA ) ; 
VRAM: true_dual_port_ram_single_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 13)
	PORT MAP ( clock, ad1, ad2, qi1, qi, w2, w1,    vq, q16  );
VIDEO: videoRGB
	PORT MAP ( Clock,R,G,B,VSYN, HSYN, vint, reset, spb, sdb, adxy, ad1, vq);
Serial: UART
	PORT MAP ( Tx, Rx, Clock, reset, sr, sw, sdready, sready, sdi, sdo );
SERKEYB: SKEYB
	PORT MAP (Rx2, Clock, reset, sr2, sdready2, sdo2);
SoundIC: SoundI
	PORT MAP (AUDIO1, reset, Clock, Waud, aq, count, play, Inter, IAC);
SoundC: Sound
	PORT MAP (AUDIO2, reset, Clock, Waud2, aq2, play2);
IRAM: single_port_ram
	PORT MAP ( clock, addr1, Do, RW, DS, QA ) ;
IROM: single_port_rom
	PORT MAP ( clock, addr1, QRO ) ;
MSPI: SPI 
	PORT MAP ( SCLK,MOSI,MISO,clock,reset,spi_w,spi_rdy,spi_in,spi_out);

-- data out 
HOLDAo<=HOLDA;
ASo<=AS when HOLDA='0' else 'Z'; 
DSo<=DS when HOLDA='0' else 'Z'; 
IOo<=IO when HOLDA='0' else 'Z'; 
RWo<=RW when HOLDA='0' else 'Z';
D<= Do when (RW='0' and DS='0') AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
ADo<= AD when AS='0' AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
addr<=to_integer(unsigned(AD)) when AS='0';
addr1<=to_integer(unsigned(AD(15 downto 1))) when AS='0';
ad2<=to_integer(unsigned(AD(13 downto 1))) when AS='0';
AUDIO<= AUDIO1 OR AUDIO2;
vs<=VSYN;
IACK<=IAC;
-- Video Ram 
process (clock,reset,AS,DS,RW)
begin 
if reset='1' then
	w1<='0'; w2<='0';
elsif clock'EVENT AND clock = '1' AND AS='0' and DS='0' then 
	if AD(15 downto 14)="11" then --61440
		w1<=not RW;
		qi<=Do(7 downto 0)&Do(15 downto 8);
	else	
	   w1<='0';
	end if;
else 
	if clock'EVENT AND clock = '1' then w1<='0'; end if;
end if;
end process ;

-- UART SKEYB SPI IO decoding
sdi<=Do(7 downto 0) when addr=0 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
sr<=Do(1) when addr=2 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
sr2<=Do(1) when addr=15 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
sw<=Do(0) when addr=2 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
spi_w<=Do(0) when addr=19 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
SPICS<=Do(1) when addr=19 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
spi_in<=Do(7 downto 0) when addr=18 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
spb<=Do(1) when addr=20 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
sdb<=Do(0) when addr=20 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
adxy<=Do(2) when addr=20 and IO='1' and AS='0' and DS='0' and RW='0' and falling_edge(clock) ;
--spb<=not spb when rising_edge(vs) ;
 --Sound IO decoding 
aq<=Do when IO='1' and AD="0000000000001000" and falling_edge(clock);
aq2<=Do when IO='1' and AD="0000000000001010" and falling_edge(clock);
Waud<='0' when AD="0000000000001000" and IO='1' and AS='0' and DS='0' and RW='0' and Clock='0' else '1';
Waud2<='0' when AD="0000000000001010" and IO='1' and AS='0' and DS='0' and RW='0' and Clock='0' else '1';

-- Read decoder
di<="00000000"&sdo when falling_edge(clock) AND AD="0000000000000100" and IO='1' -- serial 
                         and RW='1' and AS='0' else
	"00000000"&sdo2 when falling_edge(clock) AND AD="0000000000001110" and IO='1' -- serial keyboard
                         and RW='1' and AS='0' else
	"0000000000000" & sdready2 & sdready & sready  when falling_edge(clock)          -- serial status
								and RW='1' AND AD="0000000000000110" and IO='1' and AS='0' else
	"00000000"&spi_out when falling_edge(clock) AND AD="000000000010000" and IO='1'  --spi 
                         and RW='1' and AS='0' else	
	"000000000000000" & spi_rdy  when falling_edge(clock)          -- spi status
								and RW='1' AND AD="000000000010001" and IO='1' and AS='0' else   -- 17
	"00000000000000"& play2 & play  when falling_edge(clock)          -- spi status
								and RW='1' AND AD="000000000001001" and IO='1' and AS='0' else   -- 9
	"00000000000"& JOYST1  when falling_edge(clock)          -- spi status
								and RW='1' AND AD="000000000010110" and IO='1' and AS='0' else   -- 22
	count  when falling_edge(clock)          -- spi status
								and RW='1' AND AD="000000000010100" and IO='1' and AS='0' else   -- 20
	qro when addr<8192 and RW='1' and IO='0' and AS='0' and falling_edge(clock) else  --rom
	qa when addr>=8192 and addr<16384 and RW='1' and IO='0' and AS='0' and falling_edge(clock) else   --ram
	q16(7 downto 0)&q16(15 downto 8) when AD(15 downto 14)="11" and RW='1' and IO='0' and AS='0' and falling_edge(clock) else  --read video ram 
   D when falling_edge(clock) AND RW='1' and AS='0' AND IO='0';   -- external data bus read 
	
Mdecod1 <= '0' when (AD(15 downto 14)="10" or AD(15 downto 14)="01") and AS='0' and IO='0' AND HOLDA='0' else '1';  -- External 32K ram chip select 

--Interupt when serial data_ready
--Int_in <= '1' whe n sdready='1' or Int='1' else '0'; 
--Ii <= "11" when sdready='1' else I;

--Int_in <= (Int or VINT) when rising_edge(clock) and reset='0' else '0' when rising_edge(clock) and reset='1';
Int_in <= (Int or Inter) when rising_edge(clock) and reset='0' else '0' when rising_edge(clock) and reset='1';
Ii<="00" when Inter='1' and rising_edge(clock) else 
		Ii	when int='1' and  rising_edge(clock) else
		"00" when rising_edge(clock);
		
--LED(7)<=Inter;
--LED(6)<=INT;
--LED(5)<=RD;
--LED(4)<=HOLD;
--LED(3)<=II(0);
--LED(2)<=II(1);
--LED(1)<=AUDIO;
--LED(0)<=Reset;
	
end Behavior;


-- Quartus II VHDL Template
-- True Dual-Port RAM with single clock
--
-- Read-during-write on port A or B returns newly written data
-- 
-- Read-during-write between A and B returns either new or old data depending
-- on the order in which the simulator executes the process statements.
-- Quartus II will consider this read-during-write scenario as a 
-- don't care condition to optimize the performance of the RAM.  If you
-- need a read-during-write between ports to return the old data, you
-- must instantiate the altsyncram Megafunction directly.

library ieee;
use ieee.std_logic_1164.all;

entity true_dual_port_ram_single_clock is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);

	port 
	(
		clk		: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end true_dual_port_ram_single_clock;

architecture rtl of true_dual_port_ram_single_clock is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM 
	shared variable ram : memory_t;

begin


	-- Port A
	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we_a = '1') then
			ram(addr_a) := data_a;
		end if;
		q_a <= ram(addr_a);
	end if;
	end process;

	-- Port B 
	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we_b = '1') then
			ram(addr_b) := data_b;
		end if;
  	    q_b <= ram(addr_b);
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
		addr	: in natural range 0 to 65535;
		data	: in std_logic_vector(15 downto 0);
		we,DS		: in std_logic := '1';
		q		: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(4095 downto 0) of word_t;

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
	--attribute ram_init_file of ram : signal is "C:\altera\LionSys_EP4_4 D\Lionasm\bin\Debug\liontinyb.asm.mif";
	-- Register to hold the address 
	signal addr_reg : natural range 0 to 4095;

begin

	process(clk)
		variable ad2: natural range 0 to 4095;
	begin
	if (Clk'EVENT AND Clk = '1') then
		if (addr>=4096) and (addr<8192) then
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
		addr	: in natural range 0 to 65535;
		q		: out std_logic_vector(15 downto 0)
	);

end entity;

architecture rtl of single_port_rom is

	-- Build a 2-D array type for the RoM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(2047+1024 downto 0) of word_t;

	function init_rom
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin
	
--  Rom 
	return tmp;
	end init_rom;	 

signal rom : memory_t; --:= init_rom;
	attribute ram_init_file : string;
	attribute ram_init_file of rom : signal is "C:\altera\LionSys_EP4_4 D\Lionasm\bin\Debug\lionrom.asm.mif";
	
begin
	process(clk,addr)
	variable add: natural range 0 to 2047+1024:=0;
	begin
		if(Clk'EVENT AND Clk = '1' ) then
			if addr<2048+1024 then
				--add:=addr;
				q <= rom(addr);
			end if;
		end if;
	end process;
end rtl;

