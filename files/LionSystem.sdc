## Generated SDC file "LionSystem.sdc"

## Copyright (C) 2019  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.1 Build 646 04/11/2019 SJ Lite Edition"

## DATE    "Wed Jun 05 00:48:06 2019"

##
## DEVICE  "5CEFA2F23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {iClock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {iClock}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {CPLL|altpll_component|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {CPLL|altpll_component|auto_generated|generic_pll1~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 12 -divide_by 2 -master_clock {iClock} [get_pins {CPLL|altpll_component|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 6 -master_clock {CPLL|altpll_component|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]} [get_pins {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 6 -phase 180/1 -master_clock {CPLL|altpll_component|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]} [get_pins {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {CPLL|altpll_component|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {iClock}] -rise_to [get_clocks {iClock}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {iClock}] -rise_to [get_clocks {iClock}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {iClock}] -fall_to [get_clocks {iClock}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {iClock}] -fall_to [get_clocks {iClock}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {iClock}] -rise_to [get_clocks {iClock}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {iClock}] -rise_to [get_clocks {iClock}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {iClock}] -fall_to [get_clocks {iClock}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {iClock}] -fall_to [get_clocks {iClock}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

