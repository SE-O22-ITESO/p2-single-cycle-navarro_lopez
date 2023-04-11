.data
	data_mem: .word 0xdeadbeef

.text
start:
	
	lui t0, 0x10010
	addi t0, t0, 0x002c
	
	addi t1, t0, 0x0030 
	
	#la   t2, data_mem
	auipc t2, 0xfc10
	addi  t2, t2, -12

exit:
	addi t0, zero, 0x0
	addi t1, zero, 0x0
	addi t2, zero, 0x0
	addi t3, zero, 0x0
