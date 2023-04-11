.text

UART:	
	#; Byte_Rate = 0x1B2 (115,200 bauds)
	lui t0, 0x10010			#
	addi t0, t0, 0x002C 	# t0 = 0x1001_002C (UART_Setup)
	addi t1, zero, 0x1B2 	# t1 = 0x1B2
	sw t1, 16(t0) 			# Byte_Rate (UART_Setup+16) =  t1
		
	#; Set Tx_Data_0 = 'A'
	addi s0, zero, 'A' 		# s1 = 'A'
Tx_Loop:	
	sw s0, 8(t0) 			# Tx_Data.Tx_Data_0 = s0
	
	#; Setup UART to send data.
	#; Setup.Tx_Send = 0x1; Setup.Tx_Bytes=0x1
	addi t1, zero, 0x3		# t1 = 0x3
	sw t1, 0(t0)			# Setup = 0x3
	
	#; Setup.Tx_Send = 0x0;
	addi t1, zero, 0x2 		# t1 = 0x2
	sw t1, 0(t0) 			# Setup = 0x2
	
	#; Pool for Flags.Tx_Sent=0x1
Tx_Sent:
	lw t1, 4(t0)
	andi t1, t1, 0x01
	beq t1, zero, Tx_Sent
	
	addi s0, s0, 0x1		# s0++
	#jal ra Tx_Loop			# Jump
		
	jal ra exit
		
exit:
	addi zero, zero, 0
	addi zero, zero, 0