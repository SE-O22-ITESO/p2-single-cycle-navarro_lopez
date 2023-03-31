.text
main:
	addi t0, zero, 0xa
	jal ra func1 # Call 
	jal ra func2 # Call 
	jal ra exit # Jump exit
	
func1:
	addi t0, zero, 0xb
	jalr ra # Return to caller

func2:
	addi t0, zero, 0xc
	jalr ra # Return to caller

exit:
	addi zero, zero, 0 # nop
	addi zero, zero, 0 # nop