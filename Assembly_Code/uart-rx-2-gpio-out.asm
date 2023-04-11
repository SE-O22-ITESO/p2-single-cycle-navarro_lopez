.text

start:
	# Byte_Rate = 0x1B2 (115,200 bauds)
	lui t0, 0x10010			#
	addi t0, t0, 0x002C 		# t0 = 0x1001_002C (UART_Setup)
	addi t1, zero, 0x1B2 		# t1 = 0x1B2
	sw t1, 16(t0) 			# Byte_Rate (UART_Setup+16) =  t1

pool_rx_flag:
	# Pool Flags.Rx_Flag
	lw t1, 4(t0)			# t1 = Flags
	andi t1, t1, 0x2	
	srli t1, t1, 0x1		# t1 = Flags.Rx_Flag
	beq zero, t1, pool_rx_flag	# (Flags.Rx_Flag==0)?PC-=12:PC+=4
	
	# Setup.Rx_Flag_Clr = 1; Setup.Rx_Flag_Clr = 0
	addi t1, zero, 0x08		# t1 = 0x8
	sw t1, 0(t0)			# Setup.Rx_Flag_Clr = 1
	addi t1, zero, 0x00		# t1 = 0x0
	sw t1, 0(t0)			# Setup.Rx_Flag_Clr = 0
	
	# GPIO_Out <= UART_RX_Data 
	lw s0, 12(t0)			# s0 = UART_Rx_Data
	lui t0, 0x10010			# 
	addi t0, t0, 0x24		# t0 = 1001_0024 (GPIO_Out)
	sw s0, 0(t0)			# GPIO_Out = s0 (UART_Rx_Data)
	
	# Return to start
	jal ra, start			# PC=start
