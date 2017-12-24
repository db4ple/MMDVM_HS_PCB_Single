# MMDVM_HS_PCB_Single
Single Sided PCB for MMDVM Hotspot with RF7021SE module and Blue Pill STM32DUINO

This project provides a simple, singled sided PCB for the [MMDVM_HS Hotspot main repo](https://github.com/juribeparada/MMDVM_HS). 
Can be easily made using toner transfer, has very few wires. Just order the components (RF7021SE from Aliexpress and Blue Pill 
STM32DUINO clone) and put on board. Do not forget to replace the RF7021SE standard oscillator with a supported TCXO.

The second pcb design called stick is much smaller, and has a more logical led layout. But it requires a few more via wires if made as a single sided board. 
Most connecting wires are only used if the optional connectors are used. 
The single pin connector in the middle of the board is in fact a bottom / top ground plane connection for a two sided design. No need to use it on a single sided pcb.

© DB4PLE
Licensed under CC-BY-SA 3.0

