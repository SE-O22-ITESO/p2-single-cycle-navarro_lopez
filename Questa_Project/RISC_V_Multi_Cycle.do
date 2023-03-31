quit -sim
#vsim work.P4_MIPs_TB
vsim -voptargs=+acc work.RISC_V_Multi_Cycle_TB
do RISC_V_Multi_Cycle.wave
#do RISC_V_Multi_Cycle_UART.wave
run 120 us
#run 2 us