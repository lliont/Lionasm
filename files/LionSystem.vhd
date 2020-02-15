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
		IOo,Holdao,A16o,A17o,A18o : OUT std_logic;
		Iv  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0);
		R,G,B,VSYN,HSYN,VSYN2,HSYN2,BRI : OUT std_Logic;
		PB, PG, PR : OUT std_Logic;
		Tx  : OUT std_logic ;
		Rx : IN std_logic ;
		AUDIOA,AUDIOB,AUDIOC,NOISEO: OUT std_logic;
		SCLK,MOSI,SPICS: OUT std_logic;
		MISO: IN std_logic;
		JOYST1,JOYST2: IN std_logic_vector(4 downto 0);
		KCLK,KDATA:INOUT std_logic;
		RTC_CE,RTC_CLK:OUT std_logic;
		RTC_DATA:INOUT std_logic;
		XY_DECODE,XY_MUX: OUT std_logic;
		DACA: OUT std_logic_vector(1 downto 0);
		DACD: OUT std_logic_vector(7 downto 0);
		SCLK2,MOSI2,MOSI3,MOSI4,SPICS2,LDAC: OUT std_logic
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
		IO,HOLDA,A16o,A17o,A18o : OUT std_logic;
		I  : IN std_logic_vector(1 downto 0);
		IACK: OUT std_logic;
		IA : OUT std_logic_vector(1 downto 0);
		BACS: OUT std_logic
	);
end Component;

Component LPLL2 IS
	PORT
	(
		inclk0 : IN STD_LOGIC  := '0';
		c0		 : OUT STD_LOGIC ;
		c1		 : OUT STD_LOGIC 
		--c2		 : OUT STD_LOGIC 
	);
END Component;

Component lfsr is
  port (
    cout   :out std_logic;      -- Output
    clk    :in  std_logic;      -- Input rlock
    reset  :in  std_logic;       -- Input reset
	 Vol    :in std_logic_vector(7 downto 0);
	 bw     :in std_logic_vector(15 downto 0) --band width
  );
end Component;

Component VideoRGB80 is
	port
	(
		sclk, vclk, EN : IN std_logic;
		R,G,B,BRI0,VSYN,HSYN,VSINT : OUT std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(15 downto 0)
	);
end Component;

Component VideoRGB1 is
	port
	(
		sclk,vclk, EN : IN std_logic;
		R,G,B,BRI,VSYN,HSYN,VSINT : OUT std_logic;
		addr : OUT natural range 0 to 16383;
		Q : IN std_logic_vector(15 downto 0)
	);
end Component;

Component dual_port_ram_dual_clock is

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

Component SoundI is
	port
	(
		Audio: OUT std_logic;
		reset, clk, wr : IN std_logic;
		Q : IN std_logic_vector(15 downto 0);
		Vol : IN std_logic_vector(7 downto 0);
		count: OUT std_logic_vector(31 downto 0);
		play: OUT  std_logic
	);
end Component;

COMPONENT single_port_ram is
	port 
	(
		clk		: in std_logic;
		addr	: in natural range 0 to 65535;
		data	: in std_logic_vector(15 downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector(15 downto 0)
	);
end COMPONENT;


COMPONENT byte_enabled_simple_dual_port_ram is
	port (
		clk     : in  std_logic;
		addr    : in  integer range 0 to 65535 ;
		data    : in  std_logic_vector(15 downto 0);
		we      : in  std_logic;
		q       : out std_logic_vector(15 downto 0);
		be      : in  std_logic_vector (1 downto 0)
		);
end COMPONENT;

COMPONENT SPI is
	port
	(
		SCLK, MOSI : OUT std_logic ;
		MISO  : IN std_logic ;
		clk, reset, w: IN std_logic ;
		ready : OUT std_logic;
		data_in  : IN std_logic_vector (7 downto 0);
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
		sclk, vclk: IN std_logic;
		R,G,B,BRI,SPDET: OUT std_logic;
		reset, pbuffer, dbuffer : IN std_logic;
		spaddr: OUT natural range 0 to 2047;
		SPQ: IN std_logic_vector(15 downto 0)
	);
end COMPONENT;

COMPONENT PS2KEYB is
	port
	(
		Rx , kclk : IN std_logic ;
		clk, reset, r : IN std_logic ;
		data_ready : OUT std_logic;
		data_out :OUT std_logic_vector (7 downto 0)
	);
end COMPONENT;

COMPONENT XY_Display_MCP4822 is
	port
	(
		sclk: IN std_logic;
		reset: IN std_logic;
		addr: OUT natural range 0 to 2047;
		Q: IN std_logic_vector(15 downto 0);
		CS,SCK,SDI,SDI2,SDI3: OUT std_logic;
		LDAC: OUT std_logic:='1';
		MODE: IN std_logic:='0'
	);
end COMPONENT;

--
--COMPONENT XY_Display_MCP is
--	port
--	(
--		sclk: IN std_logic;
--		reset: IN std_logic;
--		addr: OUT natural range 0 to 1023;
--		Q: IN std_logic_vector(15 downto 0);
--		I2CC: OUT std_logic:='1';
--		I2CD1,I2CD2,I2CD3: INOUT std_logic:='1'
--	);
--end COMPONENT;

constant ZERO16 : std_logic_vector(15 downto 0):= (OTHERS => '0');

Signal pdelay: natural range 0 to 2047 :=0;
Signal R0,B0,G0,BRI0,R1,G1,B1,BRI1,SR2,SG2,SB2,SBRI2,SPDET2,SR3,SG3,SB3,SBRI3,SPDET3,SR1,SB1,SG1,SBRI1,SPDET1: std_logic:='0';
Signal clock0,clock1:std_logic;
Signal hsyn0,vsyn0,hsyn1,vsyn1,Vmod: std_logic:='0';
Signal vq: std_logic_vector (15 downto 0);
Signal di,do,AD,qa,qro,aq,aq2,aq3,q16 : std_logic_vector(15 downto 0);
Signal count,count2,count3 : std_logic_vector(31 downto 0);
Signal lfsr_bw : std_logic_vector(15 downto 0):="0010000000000000";
Signal WAud, WAud2,WAud3: std_logic:='1';
Signal HOLDA, A16,A17,A18,IO,nen1,nen2,nen3,ne1,ne2,ne3: std_logic:='0';
Signal rst, rst2, AS, DS, RW, Int_in, vint,vint0,vint1,xyd: std_logic:='1';
Signal w1,spw1, spw2, spw3,xyw,xyen: std_logic:='0';
Signal SPQ1,spvq1,SPQ2,spvq2,SPQ3,spvq3,xyq1,xyq2: std_logic_vector(15 downto 0);
Signal Ii : std_logic_vector(1 downto 0);
Signal ad1,vad0,vad1 :  natural range 0 to 16383;
Signal spad1,spad3,spad5:  natural range 0 to 2047;
Signal xyadr :  natural range 0 to 1023;
Signal sr,sw,sdready,sready,kr,kready,ser2,sdready2, noise: std_Logic;
Signal sdi,sdo,sdo2,kdo : std_logic_vector (7 downto 0);
Signal Vol1,Vol2,Vol3,Voln : std_logic_vector (7 downto 0):="11111111";
SIGNAL Spi_in,Spi_out: STD_LOGIC_VECTOR (7 downto 0);
Signal Spi_w, spi_rdy, play,play2,play3 : std_logic;
Signal PB0, PG0, PR0, XYmode, BACS :std_Logic:='0';
Signal BSEL: std_logic_vector (1 downto 0);
Signal spb, sdb: std_logic_vector (7 downto 0):="00000000";

shared variable Di1:std_logic_vector(15 downto 0);

begin
CPU: LionCPU16
	PORT MAP ( Di,Do,AD,RW,AS,DS,RD,rst,clock0,Int_in,Hold,IO,Holda,A16,A17,A18,Ii,Iack,IA,BACS ) ; 
IRAM: byte_enabled_simple_dual_port_ram
	PORT MAP ( clock1, to_integer(unsigned(A16&AD(15 downto 1))), Do, RW or IO or DS, QA, BSEL ) ;
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
XYRAM: dual_port_ram_dual_clock
	GENERIC MAP (DATA_WIDTH  => 16,	ADDR_WIDTH => 11)
	PORT MAP ( clock0,clock1, xyadr, to_integer(unsigned(AD(11 downto 1))), Do, xyw, xyq1, xyq2 );
VIDEO0: videoRGB80
	PORT MAP ( clock1,clock0,Vmod,R0,G0,B0,BRI0,VSYN0,HSYN0,vint0,vad0,vq);
VIDEO1: videoRGB1
	PORT MAP ( clock1,clock0,Vmod,R1,G1,B1,BRI1,VSYN1,HSYN1,vint1,vad1,vq);
SPRTG1: VideoSp
	GENERIC MAP (DATA_LINE  => 3)
	PORT MAP ( clock1, clock0,SR1,SG1,SB1,SBRI1,SPDET1,vint,spb(0),sdb(0),spad1,spvq1);
SPRTG2: VideoSp
	GENERIC MAP (DATA_LINE  => 2)
	PORT MAP ( clock1, clock0,SR2,SG2,SB2,SBRI2,SPDET2,vint,spb(1),sdb(1),spad3,spvq2);
SPRTG3: VideoSp
	GENERIC MAP (DATA_LINE  => 1)
	PORT MAP ( clock1, clock0,SR3,SG3,SB3,SBRI3,SPDET3,vint,spb(2),sdb(2),spad5,spvq3);
Serial: UART
	PORT MAP ( Tx,Rx,clock0,rst,sr,sw,sdready,sready,sdi,sdo );
SoundC1: SoundI
	PORT MAP (AUDIOA,rst,clock1,Waud,aq,Vol1,count,play);
SoundC2: SoundI
	PORT MAP (AUDIOB,rst,clock1,Waud2,aq2,Vol2,count2,play2);     
SoundC3: SoundI
	PORT MAP (AUDIOC,rst,clock1,Waud3,aq3,Vol3,count3,play3); 
MSPI: SPI 
	PORT MAP ( SCLK,MOSI,MISO,clock1,rst,spi_w,spi_rdy,spi_in,spi_out);
NOIZ:lfsr
	PORT MAP ( noise, clock1, rst, Voln, lfsr_bw);
CPLL:LPLL2
	PORT MAP (iClock,Clock0,Clock1);
PS2:PS2KEYB
	PORT MAP (KDATA,KCLK,clock1,rst,kr,kready,kdo);
--XYC:XY_Display_TLC
--	PORT MAP (clock1,rst,xyadr,xyq1,XY_decode,XY_MUX,DACA,DACD);
XYC:XY_Display_MCP4822
	PORT MAP (clock1,rst,xyadr,xyq1,SPICS2,SCLK2,MOSI2,MOSI3,MOSI4,LDAC,XYmode);
--XYC:XY_Display_MCP
--	PORT MAP (clock1,rst,xyadr,xyq1,I2CC,I2CD1,I2CD2,I2CD3);
rst2<=not reset when rising_edge(clock0);
rst<=rst2 when rising_edge(clock0);

HOLDAo<=HOLDA;
Di<=Di1 when IO='1' else qa;
A16o<=A16 when HOLDA='0' else 'Z';
A17o<=A17 when HOLDA='0' else 'Z';
A18o<=A18 when HOLDA='0' else 'Z';
ASo<=AS when HOLDA='0' else 'Z'; 
DSo<=DS when HOLDA='0' else 'Z'; 
IOo<=IO when HOLDA='0' else 'Z'; 
RWo<=RW when HOLDA='0' else 'Z';
D<= Do when RW='0' and DS='0' AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
ADo<= AD when AS='0' AND HOLDA='0' else "ZZZZZZZZZZZZZZZZ";
--IACK<=IAC;

BSEL<= "01" when BACS='1' and AD(0)='1' else "10" when BACS='1' and AD(0)='0' else "11";


nen1<='1' when (ne1='1') and (play='1') and (aq(12 downto 0)/="0000000000000") else '0';
nen2<='1' when (ne2='1') and (play2='1') and (aq2(12 downto 0)/="0000000000000") else '0';
nen3<='1' when (ne3='1') and (play3='1') and (aq3(12 downto 0)/="0000000000000") else '0';
NOISEO<=NOISE and (nen1 or nen2 or nen3);

R<= SR1 when  SPDET1='1' else SR2 when  SPDET2='1' else SR3 when SPDET3='1' else R1 when Vmod='1' else R0;
G<= SG1 when  SPDET1='1' else SG2 when  SPDET2='1' else SG3 when SPDET3='1' else G1 when Vmod='1' else G0;
B<= SB1 when  SPDET1='1' else SB2 when  SPDET2='1' else SB3 when SPDET3='1' else B1 when Vmod='1' else B0;
BRI<= SBRI1 when SPDET1='1' else SBRI2 when SPDET2='1' else SBRI3 when SPDET3='1' else BRI1 when Vmod='1' else BRI0;

ad1<=vad1 when Vmod='1'  else vad0;
HSYN<=HSYN1 when Vmod='1' else HSYN0;
VSYN<=VSYN1 when Vmod='1' else VSYN0;
HSYN2<=HSYN1 when Vmod='1' else HSYN0;
VSYN2<=VSYN1 when Vmod='1' else VSYN0;
VINT<=Vint1 when Vmod='1' else Vint0;

pdelay<=0 when hsyn='0' and rising_edge(clock1) else pdelay+1 when  rising_edge(clock1);
PB<=PB0 when pdelay>47*2 and vsyn='1' and hsyn='1' else '0';
PG<=PG0 when pdelay>47*2 and vsyn='1' and hsyn='1' else '0';
PR<=PR0 when pdelay>47*2 and vsyn='1' and hsyn='1' else '0';

RTC_DATA<='Z';
RTC_CLK<='0';
RTC_CE<='0';

w1<='1'   when DS='0' and AS='0' and IO='1' and AD(15)='1' and RW='0' else '0'; 
spw1<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0100" and RW='0' else '0';
spw2<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0101" and RW='0' else '0';
spw3<='1' when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0110" and RW='0' else '0';
xyw<='1'  when DS='0' and AS='0' and IO='1' and AD(15 downto 12)="0111" and RW='0' else '0';

-- Interrupts 
process (clock1,INT)
begin
if rising_edge(clock1) then
	--if AD="0000000000011000" and IO='1' and AS='0' and DS='0' and RW='0' then Vmod<=Do(0); end if; 
	--if Vmod='1' then ad1<=vad1; else ad1<=vad0; end if;
	--if Vmod='1' then Vint<=Vint1; else Vint<=Vint0; end if;
	if INT='0' then  II<=Iv; else II<="11"; end if;
	Int_in<= INT and VINT;
end if;
end process;

Vmod<='0' when rst='1' and rising_edge(clock1) else Do(0) when AD=24 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);

-- UART SKEYB SPI IO decoding
sdi<=Do(7 downto 0) when AD=0 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
sr<=Do(1) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
kr<=Do(1) when AD=15 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1); 
sw<=Do(0) when AD=2 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spi_w<=Do(0) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
SPICS<=Do(1) when AD=19 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spi_in<=Do(7 downto 0) when AD=18 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
spb(2 downto 0)<=Do(2 downto 0) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);
sdb(2 downto 0)<=Do(5 downto 3) when AD=20 and IO='1' and AS='0' and DS='0' and RW='0' and rising_edge(clock1);

 --Sound IO decoding 
aq<=Do when AD=8 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);   -- port 8
aq2<=Do when  AD=10 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 10
aq3<=Do when  AD=12 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 12
Vol1<=Do(7 downto 0) when AD=25 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);   -- port 25
Vol2<=Do(7 downto 0) when  AD=26 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 26
Vol3<=Do(7 downto 0) when  AD=27 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 27
Voln<=Do(7 downto 0) when  AD=28 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  -- port 28
ne1<=Do(0) when  AD=11 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);    -- noise enable
ne2<=Do(1) when  AD=11 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);    -- noise enable
ne3<=Do(2) when  AD=11 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);    -- noise enable
Waud<='0' when AD=8  and IO='1' and AS='0'  and RW='0' and rising_edge(clock1) else '1' when rising_edge(clock1);
Waud2<='0' when AD=10 and IO='1' and AS='0' and RW='0' and rising_edge(clock1) else '1' when rising_edge(clock1);
Waud3<='0' when AD=12 and IO='1' and AS='0' and RW='0' and rising_edge(clock1) else '1' when rising_edge(clock1);
lfsr_bw<=Do when AD=13 and IO='1' and AS='0' and RW='0' and rising_edge(clock1);
PR0<=Do(0) when  AD=30 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);   
PG0<=Do(1) when  AD=30 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);   
PB0<=Do(2) when  AD=30 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1); 
XYmode<=Do(0) when  AD=31 and IO='1' and RW='0' and AS='0' and DS='0' and rising_edge(clock1);  

-- Read decoder
process (clock0,RW,AS,IO)
begin
	if rising_edge(clock0) and RW='1' and AS='0' AND IO='1'  then
		if AD(15)='1' then Di1:=q16; --video
		elsif AD(14 downto 12)="100" then Di1:=SPQ1;
	   elsif AD(14 downto 12)="101" then Di1:=SPQ2;
		elsif AD(14 downto 12)="110" then Di1:=SPQ3;
		elsif AD(14 downto 12)="111" then Di1:=xyq2;
		end if;
		if AD=4 then Di1:="00000000"&sdo; end if; -- serial1
		if AD=14 then Di1:="00000000"&kdo; end if; -- serial2 keyboard
		if AD=6 then Di1:="0000000000000" & kready & sdready & sready; end if; -- serial status
		if AD=16 then Di1:="00000000"&spi_out; end if; --spi 
		if AD=17 then Di1:="000000000000000" & spi_rdy; end if; --spi 
		if AD=9 then Di1:="0000000000000"& play3 & play2 & play; end if; -- audio status
		if AD=22 then Di1:="000"&JOYST2&"000"& JOYST1; end if;     -- joysticks
		if AD=20 then Di1:=count(15 downto 0); end if;
		if AD=21 then Di1:=count(31 downto 16); end if;
		if AD=23 then Di1:="00000000000000"&Vsyn&hsyn; end if;  -- VSYNCH HSYNCH STATUS
		if AD=24 then Di1:="000000000000000"&Vmod; end if;
	end if;
end process;
	
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
type memory_t is array(0 to 2**ADDR_WIDTH-1) of word_t;
    
signal ram : memory_t;
attribute ramstyle : string;
attribute ramstyle of ram : signal is "no_rw_check";
begin
	process(clkb, we_b)
	begin
		if(rising_edge(clkb)) then 
			if we_b='1' then	
				ram(addr_b)<= data_b; 
				q_b<=data_b;
			else
				q_b <= ram(addr_b);
			end if;
		end if;
	end process;

	process(clka)
	begin
		if(rising_edge(clka)) then 
			q_a <= ram(addr_a);
		end if;
	end process;
end rtl;
----------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity single_port_ram is

	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 65535;
		data	: in std_logic_vector(15 downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(0 to 65535) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t; --:=init_ram;
	attribute ram_init_file : string;
	attribute ram_init_file of ram : signal is "C:\intelFPGA_lite\LionSys_EP5_A2\Lionasm\bin\Debug\lionrom.mif";
	attribute ramstyle : string;
   attribute ramstyle of ram : signal is "no_rw_check";

begin

	process(clk)
	begin
	if (Clk'EVENT AND Clk = '1') then
			if (WE = '0') then
				if addr>4095 then ram(addr) <= data; end if;
			else 
				q<=ram(addr);
			end if;
	end if;
	end process;
	
end rtl;

--------------------------------------------------------------------------------------------
-- changed for Lion 
-- Simple Dual-Port RAM with different read/write addresses and single read/write clock
-- and with a control for writing single bytes into the memory word; byte enable

library ieee;
use ieee.std_logic_1164.all;
library work;

entity byte_enabled_simple_dual_port_ram is
  
	port (
		clk     : in  std_logic;
		addr    : in  integer range 0 to 65535 ;
		data    : in  std_logic_vector(15 downto 0);
		we      : in  std_logic;
		q       : out std_logic_vector(15 downto 0);
		be      : in  std_logic_vector (1 downto 0)
		);
end byte_enabled_simple_dual_port_ram;

architecture rtl of byte_enabled_simple_dual_port_ram is
	--  build up 2D array to hold the memory
	type word_t is array (0 to 1) of std_logic_vector(7 downto 0);
	type ram_t is array (65535 downto 0) of word_t;
	-- declare the RAM
	signal ram : ram_t;
	attribute ram_init_file : string;
	attribute ram_init_file of ram : signal is "C:\intelFPGA_lite\LionSys_EP5_A2\Lionasm\bin\Debug\lionrom.mif";
	attribute ramstyle : string;
   attribute ramstyle of ram : signal is "no_rw_check";
	signal q_local : word_t;

begin  -- rtl
        
	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '0') and (addr>4095) then
				if (be = "11") then
					ram(addr)(0) <= data(15 downto 8);
					ram(addr)(1) <= data(7 downto 0);
				elsif  be = "10" then 
					ram(addr)(0) <= data(7 downto 0);
				elsif  be = "01" then 
					ram(addr)(1) <= data(7 downto 0);
				end if;
			end if;
			q <= ram(addr)(0)&ram(addr)(1);
		end if;
	end process;  
end rtl;




-------------------------------------------------------
Library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.numeric_std.all ;

entity PS2KEYB is
	port
	(
		Rx,Kclk : IN std_logic ;
		clk, reset, r : IN std_logic ;
		data_ready : OUT std_logic:='0';
		data_out :OUT std_logic_vector (7 downto 0)
	);
end PS2KEYB;


Architecture Behavior of PS2KEYB is

constant rblen:natural:=16;
type FIFO_r is array (0 to rblen-1) of std_logic_vector(9 downto 2);
Signal rFIFO: FIFO_r;
	attribute ramstyle : string;
	attribute ramstyle of rFIFO : signal is "logic";
Signal inb: std_logic_vector(9 downto 1);
Signal lastkey: std_logic_vector(7 downto 0);
--Signal delay:natural range 0 to 65535:=0;
signal dr: boolean:=false;
signal rptr1, rptr2: natural range 0 to rblen := 0; 
signal rstate: natural range 0 to 15 :=0 ;
Signal kl,k1,k2,k3: std_logic:='0';
begin

	process (clk,kclk,reset)
	
   variable ra:boolean :=false ;

	begin
		if (reset='1') then 
			rptr1<=0; rptr2<=0; data_ready<='0'; rstate<=0;
			 dr<=false; ra:=false; lastkey<="00000000";
		elsif  clk'EVENT  and clk = '1' then
			if (kl='1') and (k1='0') then	
				if rstate=0 and Rx='0' then
					rstate<=1; 
				elsif rstate>0 and rstate<10 then
					inb(rstate)<=Rx;
					rstate<=rstate+1;
				elsif rstate=10 and Rx='1' then
					rstate<=0;
					if (lastkey/="11110000") and (inb(8 downto 1)/="11110000") and (inb(8 downto 1)/="11100000") then
						if  (lastkey="11100000") then
							rFIFO(rptr2)<="1010"&inb(4 downto 1);
						else
							rFIFO(rptr2)<=inb(8 downto 1);
						end if;
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
					end if;
					lastkey<=inb(8 downto 1);
				else
					rstate<=0;
				end if;
			end if;
			
			K3<=kclk;
			k2<=k3;
			k1<=k2;
			kl<=k1;
			
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

