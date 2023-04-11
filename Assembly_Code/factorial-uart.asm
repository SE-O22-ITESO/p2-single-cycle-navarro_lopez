.text
main:

	lui t0, 0x10010
	addi t0, t0, 0x002C # t0 = 0x1001_002C (UART_Setup, "UART base address")
	
	# Set Byte Rate
	# 0x0000_1458, (9,600 baudrate)
	# 0x0000_01B2, (115,200 baudrate)
	
	#lui t1, 0x1 # t1 = 0x1000
	#addi t1, t1, 0x458 # t1 = t1 + 0x458
	addi t1, zero, 0x1B2 	# t1 = 0x1B2
	sw t1, 16(t0) 		# Byte_Rate (UART_Setup+16) =  t1
	
	lui t0, 0x10010
	addi t1, t0, 0x0028 # t1 = 0x1001_0028 (GPIO_In)
	addi t0, t0, 0x0024 # t0 = 0x1001_0024 (GPIO_Out)
	lw s0, 0(t1) # s0 = GPIO_In
	sw s0, 0(t0) # GPIO_Out = s0
	jal ra GPIO # Loop forever


	li a2, 4 # Loading constant
	jal factorial # Call 
	j exit # Jump exit
	
factorial:
	slti t0, a2, 1 # If n<1
	beq t0, zero, loop # Branch to loop
	addi a0, zero, 1 # Loading 1
	jr ra # Return to caller
	
loop:	
	addi sp, sp, -8 # Decreasing the stack pointer
	sw ra, 4(sp) # Storing n
	sw a2, 0(sp) # Store the return address
	addi a2, a2, -1 # Decrease n
	jal factorial # Recursive function
	lw a2, 0(sp) # Loading values from stack
	lw ra, 4(sp) # Loading values from stack
	addi sp, sp, 8 # Increasing stack pointer
	mul a0, a2, a0 # Multiply n*Factorial(n-1)
	jr ra # Return address

exit:
	addi zero, zero, 0 # nop
	addi zero, zero, 0 # nop
	
