.data
	data_mem: .word 0xdeadbeef
.text
#main:
	# Copy content from 0x1001_0000 to 0x1001_0001
	#lui t0, 0x10010 # t0 = 0x1001_0000 (data memory base address)
	#lw s0, 0(t0) # Load word
	#sw s0, 4(t0) # Store word
	
	# Copy GPIO_In to GPIO_Out
#GPIO:
	#lui t0, 0x10010
	#addi t1, t0, 0x0028 # t1 = 0x1001_0028 (GPIO_In)
	#addi t0, t0, 0x0024 # t0 = 0x1001_0024 (GPIO_Out)
	#lw s0, 0(t1) # s0 = GPIO_In
	#sw s0, 0(t0) # GPIO_Out = s0
	#jal ra GPIO # Loop forever
	
UART:	
	lui t0, 0x10010
	addi t0, t0, 0x002C # t0 = 0x1001_002C (UART_Setup, "UART base address")
		
	# Set Byte Rate
	# 0x0000_1458, (9,600 baudrate)
	# 0x0000_01B2, (115,200 baudrate)  <-----
	
	#lui t1, 0x1 # t1 = 0x1000
	#addi t1, t1, 0x458 # t1 = t1 + 0x458
	addi t1, zero, 0x1B2 	# t1 = 0x1B2
	sw t1, 16(t0) 		# Byte_Rate (UART_Setup+16) =  t1
	
	
	# Set Tx_Data_0 = 'A'
	addi s0, zero, 'A' 	# s1 = 'A'
Tx_Loop:	
	sw s0, 8(t0) 		# UART_Data_0 (UART_Setup+8) = 'A'
	
	# Setup UART to send data.
	# Setup.Tx_Send = 0x1; Setup.Tx_Bytes=0x1
	addi t1, zero, 0x3	# t1 = 0x0 + 0x3
	sw t1, 0(t0)		# Setup = 0x3
	
	# Setup.Tx_Send = 0x0;
	addi t1, zero, 0x2 	# t1 = 0x0 + 0x2
	sw t1, 0(t0) 		# Setup = 0x2
	
	# Pool for Flags.Tx_Sent=0x1
Tx_Sent:
	lw t1, 4(t0)
	andi t1, t1, 0x01
	beq t1, zero, Tx_Sent
	
	addi s0, s0, 0x1	# s0++
	jal ra Tx_Loop		# Jump
	
	
	jal ra exit
	
	

exit:
	addi zero, zero, 0
	addi zero, zero, 0
	
# Exp stuff
	#auipc s0, 0xfc10
	#addi s0, s0, -20
