.data
	data_mem: .word 0xdeadbeef
.text
	
	# Copy GPIO_In to GPIO_Out
start:
	lui t0, 0x10010
	addi t1, t0, 0x0028 # t1 = 0x1001_0028 (GPIO_In)
	addi t0, t0, 0x0024 # t0 = 0x1001_0024 (GPIO_Out)
loop:	
	lw s0, 0(t1) # s0 = GPIO_In
	sw s0, 0(t0) # GPIO_Out = s0
	jal ra loop # Loop forever