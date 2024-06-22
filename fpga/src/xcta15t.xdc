## This file is a general .xdc for the QMTECH XC7A15T_35T_50T_CSG325
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock Signal
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports ex_clk_50m]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports ex_clk_50m]

## LEDs
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

## Buttons
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports s1]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports s2]

## Header JP3
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { jp3[5] }]; #IO_L19N_T3_A21_VREF_15 Sch=IO_F18
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { jp3[7] }]; #IO_L24N_T3_RS0_15 Sch=IO_E18
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[5]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD TMDS_33} [get_ports clk_p]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD TMDS_33} [get_ports {data_p[0]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD TMDS_33} [get_ports {data_n[0]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD TMDS_33} [get_ports {data_p[1]}]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD TMDS_33} [get_ports {data_n[1]}]
#set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { jp3[21] }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=IO_A17
set_property -dict {PACKAGE_PIN C16 IOSTANDARD TMDS_33} [get_ports {data_p[2]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports sd_dat1]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports sd_dat0]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports sd_cmd]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports sd_sclk]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports sd_dat3]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports sd_dat2]
#set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { jp3[37] }]; #IO_L7P_T1_AD2P_15 Sch=IO_B12
#set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { jp3[39] }]; #IO_L4P_T0_15 Sch=IO_C11
#set_property -dict { PACKAGE_PIN D11   IOSTANDARD LVCMOS33 } [get_ports { display_select }]; #IO_L6P_T0_15 Sch=IO_D11
#set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { a }]; #IO_L2N_T0_AD8N_15 Sch=IO_C9
#set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { d }]; #IO_L5N_T0_AD9N_15 Sch=IO_A10
#set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { g }]; #IO_L3N_T0_DQS_AD1N_15 Sch=IO_A9

set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[7]}]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[6]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[4]}]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD TMDS_33} [get_ports clk_n]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[3]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[2]}]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[1]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {ex_bus_data[0]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD TMDS_33} [get_ports {data_n[2]}]
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { jp3[24] }]; #IO_L15P_T2_DQS_15 Sch=IO_B16
#set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports { jp3[26] }]; #IO_L9N_T1_DQS_AD3N_15 Sch=IO_B15
#set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { jp3[28] }]; #IO_L10P_T1_AD11P_15 Sch=IO_B14
#set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { jp3[30] }]; #IO_L12N_T1_MRCC_15 Sch=IO_D14
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports ex_bus_data_reverse_n]
#set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { jp3[34] }]; #IO_L6N_T0_VREF_15 Sch=IO_C12
#set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { jp3[36] }]; #IO_L12P_T1_MRCC_15 Sch=IO_E13
#set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS33 } [get_ports { jp3[38] }]; #IO_L7N_T1_AD2N_15 Sch=IO_A12
#set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { jp3[40] }]; #IO_L4N_T0_15 Sch=IO_B11
#set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { c }]; #IO_0_15 Sch=IO_D10
#set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { b }]; #IO_L2P_T0_AD8P_15 Sch=IO_D9
#set_property -dict { PACKAGE_PIN B10   IOSTANDARD LVCMOS33 } [get_ports { e }]; #IO_L5P_T0_AD9P_15 Sch=IO_B10
#set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { f }]; #IO_L3P_T0_DQS_AD1P_15 Sch=IO_B9

## Header JP2
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[7]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[6]}]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[5]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[4]}]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[3]}]
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[2]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[1]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[0]}]
#set_property -dict { PACKAGE_PIN U2    IOSTANDARD LVCMOS33 } [get_ports { jp2[21] }]; #IO_L15P_T2_DQS_34 Sch=IO_U2
#set_property -dict { PACKAGE_PIN P4    IOSTANDARD LVCMOS33 } [get_ports { jp2[23] }]; #IO_L12P_T1_MRCC_34 Sch=IO_P4
#set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports { jp2[25] }]; #IO_L14P_T2_SRCC_34 Sch=IO_R3
#set_property -dict { PACKAGE_PIN N4    IOSTANDARD LVCMOS33 } [get_ports { jp2[27] }]; #IO_L10N_T1_34 Sch=IO_N4
#set_property -dict { PACKAGE_PIN M6    IOSTANDARD LVCMOS33 } [get_ports { jp2[29] }]; #IO_L8P_T1_34 Sch=IO_M6
#set_property -dict { PACKAGE_PIN L5    IOSTANDARD LVCMOS33 } [get_ports { jp2[31] }]; #IO_L6P_T0_34 Sch=IO_L5
#set_property -dict { PACKAGE_PIN K3    IOSTANDARD LVCMOS33 } [get_ports { jp2[33] }]; #IO_L4P_T0_34 Sch=IO_K3
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports { jp2[35] }]; #IO_L9N_T1_DQS_34 Sch=IO_P1
#set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { jp2[37] }]; #IO_L9P_T1_DQS_34 Sch=IO_N1
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports ex_bus_wait_n]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports ex_bus_int_n]
set_property -dict {PACKAGE_PIN J6 IOSTANDARD LVCMOS33} [get_ports ex_bus_m1_n]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports ex_bus_rfsh_n]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports ex_bus_iorq_n]

set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[15]}]
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[14]}]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[13]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[12]}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[11]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[10]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[9]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {ex_bus_addr[8]}]
#set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports { jp2[22] }]; #IO_L15N_T2_DQS_34 Sch=IO_U1
#set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports { jp2[24] }]; #IO_L17N_T2_34 Sch=IO_T3
#set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { jp2[26] }]; #IO_L14N_T2_SRCC_34 Sch=IO_T2
#set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports { jp2[28] }]; #IO_L12N_T1_MRCC_34 Sch=IO_P3
#set_property -dict { PACKAGE_PIN M5    IOSTANDARD LVCMOS33 } [get_ports { jp2[30] }]; #IO_L6N_T0_VREF_34 Sch=IO_M5
#set_property -dict { PACKAGE_PIN L4    IOSTANDARD LVCMOS33 } [get_ports { jp2[32] }]; #IO_L5P_T0_34 Sch=IO_L4
#set_property -dict { PACKAGE_PIN K5    IOSTANDARD LVCMOS33 } [get_ports { jp2[34] }]; #IO_L1N_T0_34 Sch=IO_K5
#set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { jp2[36] }]; #IO_L13N_T2_MRCC_34 Sch=IO_R1
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports ex_bus_clk_3m6]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports ex_bus_reset_n]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports ex_bus_wr_n]
#set_property -dict { PACKAGE_PIN K6    IOSTANDARD LVCMOS33 } [get_ports { jp2[44] }]; #IO_L2P_T0_AD8P_15 Sch=IO_K6
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports ex_bus_rd_n]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports ex_bus_mreq_n]


## SDRAM
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports O_sdram_clk]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports O_sdram_cke]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {O_sdram_dqm[1]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {O_sdram_dqm[0]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports O_sdram_cas_n]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports O_sdram_ras_n]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports O_sdram_wen_n]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports O_sdram_cs_n]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {O_sdram_ba[1]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {O_sdram_ba[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[12]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[11]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[10]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[9]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[8]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[7]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[6]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[5]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[4]}]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[3]}]
set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[2]}]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[1]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {O_sdram_addr[0]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[0]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[1]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[2]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[3]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[4]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[5]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[6]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[7]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[8]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[9]}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[10]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[11]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[12]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[13]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[14]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {IO_sdram_dq[15]}]

## SPI Flash
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports mspi_mosi]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports mspi_miso]
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { spi_dq2  }]; #IO_L2P_T0_D02_14        Sch=FPGA_DQ2
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { spi_dq3  }]; #IO_L2N_T0_D03_14        Sch=FPGA_DQ3
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports mspi_cs]
#set_property -dict { PACKAGE_PIN E8    IOSTANDARD LVCMOS33 } [get_ports { mspi_sclk }]; #CCLK_0                  Sch=FPGA_CCLK


set_property BITSTREAM.CONFIG.CONFIGRATE 22 [current_design]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {ex_bus_clk_3m6_IBUF}]














