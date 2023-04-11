.data
	data_mem: .word 0xdeadbeef

.text
start:

	addi t0, t0, 0x55
	addi a0, a0, 0xaa
	
	ori  t1, t0, 0xaa
	ori  a1, a0, 0x55
	
	and  t2, t0, t1
	and  a2, a0, a1
	
	add  t3, t2, t1
	add  a3, a2, a1
	
	slli t4, t3, 0x3
	slli a4, a3, 0x3
	
	srli t5, t4, 0x4
	srli a5, a4, 0x4
	
	addi t6, t6, -12
	addi a6, a6, -12
	
	addi sp, sp, 12
	addi sp, sp, -12
	
	addi gp, gp, 12
	addi gp, gp, -12

exit:
	addi t0, zero, 0x0
	addi t1, zero, 0x0
	addi t2, zero, 0x0
	addi t3, zero, 0x0
	addi t4, zero, 0x0
	addi t5, zero, 0x0
	addi t6, zero, 0x0
	addi a0, zero, 0x0
	addi a1, zero, 0x0
	addi a2, zero, 0x0
	addi a3, zero, 0x0
	addi a4, zero, 0x0
	addi a5, zero, 0x0
	addi a6, zero, 0x0
	addi sp, zero, 0x0
	addi gp, zero, 0x0
