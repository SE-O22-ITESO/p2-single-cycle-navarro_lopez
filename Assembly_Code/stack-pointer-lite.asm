.data
	data_mem: .word 0xdeadbeef
.text
	
start:

	addi sp, sp, -12
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	
	jal ra function
	
	lw ra, 0(sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	addi sp, sp, +12
		
	jal ra exit
	
function:
	addi zero, zero, 0		# nop
	addi zero, zero, 0		# nop
	jalr ra					# Return
	
	

exit:
	addi zero, zero, 0
	addi zero, zero, 0
	

