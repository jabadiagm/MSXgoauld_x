# MSXgoauld_x
MSX Goa'uld board with Xilinx XC7A35T

![goauld_x](/goauld_x.jpg)

MSX2+ engine in Z80 socket. It turns one MSX into an MSX2+ by replacing Z80 processor. FPGA in board contains: 
* Z80
* V9958 with hdmi output
* MSX2+ BIOS
* 4MB mapper
* RTC
* PSG through hdmi
* SCC (audio only) through hdmi
* OPLL through hdmi
* SD card interface with Nextor

## How it works:
Logic acts on bus control signals so that internal devices inside fpga take priority over external devices. 

![Esquema](/esquema.png)

## Slot map

![Slot map](/mapa_slots_x.png)

Place SCC cartridges in slot 1 to get SCC sound through HDMI

## Revision 1 Board
PCB version 1 uses through hole components for ease of assembly

![goauld_x](/pcb_v1.png)

## Revision 2 Board

Revision 2 uses SOIC-20, TSSOP-20 for 74LS245 and 74LVC245 ICs, which are smaller:

![Revision 2](/pcb_v2.png)

## Bill of materials
Main elements:
* [QMTECH Xilinx FPGA Artix7 Artix-7 XC7A35T SDRAM Core Board](https://a.aliexpress.com/_EIR63QR)
* [(PCB V1) SD SPI or SDIO Card Breakout Board - 3V](https://a.aliexpress.com/_EJ8GIw7)
* [(PCB V1) HDMI female socket/plug 19P female mount 3-row pins](https://a.aliexpress.com/_Eub6hh9)
* [40Pin Connector Header Round Needle Gold Plated 1x40 Golden Pin Single Row Male 2.54mm Breakable Pin Connector Strip](https://a.aliexpress.com/_ExPDv4F)
* [dip 2*40/ PIN double row PIN HEADER 2.54MM PITCH MALE Strip Connector 2X](https://a.aliexpress.com/_EJbEXl9)
* [2.54mm Double Row Straight Female Pin Header Socket Connector 2x25Pin](https://a.aliexpress.com/_EvLvXL1)
* 2xSN74LVC245AN
* 3x74LS245
* Platform Cable USB II / DLC10 (programmer)

## Tips/Warnings
* HDMI circuitry is unprotected in V1 board, use at your own risk
* Turn on monitor after turning on MSX, otherwise fpga may not start
* When possible, use a linear power supply to keep electrical noises low
* Get integrated circuits from trusted sources
* Use turned pins in header to avoid damages in Z80 socket
* Board is sensitive to dirty electrical contacts, way more than Z80. Keep cartridge & Z80 socket contacts clean