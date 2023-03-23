quit -sim
vsim -voptargs=+acc work.Memory_Map_Decoder_TB
do Memory_Map_Decoder.wave
run 16 ns