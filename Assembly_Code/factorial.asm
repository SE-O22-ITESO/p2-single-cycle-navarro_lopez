.text
main:
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
	
