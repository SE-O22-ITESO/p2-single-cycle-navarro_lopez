.text
start:
	#; Byte_Rate = 0x1B2 (115,200 bauds)
	lui t6, 0x10010				# t6 = 0x1001_002C (UART_Setup)
	addi t6, t6, 0x002C 		# 
	
loop:

	jal ra, rx_recv				# Call rx_recv
	jal ra, factorial 			# Call factorial
	jal ra, tx_send				# Call tx_send
	
	jal ra, loop				# Return to loop


#; Function: factorial ==========================
factorial:
	slti t0, a2, 1 				# if (n<1) then
	beq t0, zero, recursive		#   branch to recursive
	addi a0, zero, 1 			# Loading 1
	jalr ra						# Return to caller
	
recursive:	
	addi sp, sp, -8 			# Decreasing the stack pointer
	sw ra, 4(sp) 				# Storing n
	sw a2, 0(sp) 				# Store the return address
	addi a2, a2, -1 			# Decrease n
	jal factorial 				# Recursive function
	lw a2, 0(sp) 				# Loading values from stack
	lw ra, 4(sp) 				# Loading values from stack
	addi sp, sp, 8 				# Increasing stack pointer
	mul a0, a2, a0 				# Multiply n*Factorial(n-1)
	jr ra 						# Return address


#; Function: rx_recv ==========================
rx_recv:
	#; Byte_Rate = 0x1B2 (115,200 bauds)
	#; Byte_Rate = 0x1458 (9,600 bauds)
	#;lui t6, 0x10010				# t6 = 0x1001_002C (UART_Setup)
	#;addi t6, t6, 0x002C 		# 
	#;addi t1, t1, 0x1B2 			# t1 = 0x1B2
	lui t1, 0x00001
	addi t1, t1, 0x458 		# t1 = 0x1458
	sw t1, 16(t6) 				# UART_Setup.Byte_Rate =  t1
	
pool_rx_flag:
	#; Pool Flags.Rx_Flag
	lw t1, 4(t6)				# t1 = Flags
	andi t1, t1, 0x2	
	srli t1, t1, 0x1			# t1 = Flags.Rx_Flag
	beq zero, t1, pool_rx_flag	# (Flags.Rx_Flag==0)?PC-=12:PC+=4
	
	#; Setup.Rx_Flag_Clr = 1, then 0
	addi t1, zero, 0x08			# t1 = 0x8
	sw t1, 0(t6)				# Setup.Rx_Flag_Clr = 1
	addi t1, zero, 0x00			# t1 = 0x0
	sw t1, 0(t6)				# Setup.Rx_Flag_Clr = 0
	
	#; a2 = UART_RX_Data 
	lw a2, 12(t6)				# a2 = UART_Rx_Data
	
	jalr ra						# Return to caller

#; Function: tx_send ==========================
tx_send:
	
	#;lui t6, 0x10010				# t6 = 0x1001_002C (UART_Setup)
	#;addi t6, t6, 0x002C 			# 
	addi t2, zero, 24			# tx_index
	addi t4, zero, 4			# i
	
tx_iterate:

	addi t3, a0, 0				# t3 = n!
	#;Shift right
	srl t3, t3, t2				# t3 = n!>>i
	sw t3, 8(t6) 				# Tx_Data.Tx_Data_0 = t3
	
	
	#;Setup UART to send data.
	#; Setup.Tx_Send = 0x1; Setup.Tx_Bytes=0x1
	addi t1, zero, 0x3			# t1 = 0x3
	sw t1, 0(t6)				# Setup = 0x3
	
	#; Setup.Tx_Send = 0x0;
	addi t1, zero, 0x2 			# t1 = 0x2
	sw t1, 0(t6) 				# Setup = 0x2
	
	#; Pool for Flags.Tx_Sent=0x1
pool_tx_sent:
	lw t1, 4(t6)
	andi t1, t1, 0x01
	beq t1, zero, pool_tx_sent
	
	addi t2, t2, -8				# tx_index-=8
	addi t4, t4, -1				# i-=1
	#;slti t4, t2, 24 			# if (i<24) then
	bne t4, zero, tx_iterate	# if(i!=0)  PC=tx_iterate
	
	jalr ra						# Return to caller

#; Function: exit =============================
exit:
	addi zero, zero, 0 			# nop
	addi zero, zero, 0 			# nop
	
