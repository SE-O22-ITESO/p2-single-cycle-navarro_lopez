quit -sim
#vsim work.P4_MIPs_TB
vsim -voptargs=+acc work.RISC_V_Multi_Cycle_TB
do RISC_V_Multi_Cycle.wave
run 512 ns