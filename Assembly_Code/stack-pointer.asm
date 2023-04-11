.data
	data_mem: .word 0xdeadbeef
.text
	
start:
	
	addi t0, t0, 0x1b3
	addi t1, t1, 0x1b0
	addi t2, t2, 0x0

loop:
	slti t3, t2, 5				# t3=(t2<5)?1:0
	bne t3, zero, stkptr
	
	jal ra exit
	
stkptr:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	
	jal ra function
	
	lw ra, 0(sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	addi sp, sp, +12
	
	addi t2, t2, 1
	
	jal ra start
	
function:
	addi zero, zero, 0		# nop
	addi zero, zero, 0		# nop
	jalr ra					# Return
	
	

exit:
	addi zero, zero, 0
	addi zero, zero, 0
	

