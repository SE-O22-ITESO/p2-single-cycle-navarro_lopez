#//////////////////////////////////////////////////////////////////////////////////
#// Company: ITESO
#// Engineer: Angel Ramses Navarro Lopez
#// File Description:
#//   Vector dot product. Accessing arrays, memory access, loops.
#// Date: February 19, 2023
#//////////////////////////////////////////////////////////////////////////////////
.data
	Vector_1: .word  1, 2, 3, 4, 5, 6, 7, 8, 9 # Vector_1[9]
	Vector_2: .word -1, 2,-3, 4,-5, 6,-7, 8,-9 # Vector_2[9]
	
.text
	addi s0, zero, 0 	# int i = 0
	addi s1, zero, 0 	# int result = 0

main: # int main(void) {

	addi s0, zero, 0	# i = 0 (Not really needed)
for_loop: # for begin
	slti t0, s0, 9		# t0 = (i < 9)? 1:0
	beq t0, zero, exit	# Branch exit if (i < 9)
	# for body
	
	#la s2, Vector_1
	auipc s2, 0xfc10	# s2 = Vector_1_address
	addi s2, s2, -20
	
	#la s3, Vector_2
	auipc s3, 0xfc10	# s3 = Vector_2_address
	addi s3, s3, 8
	
	slli t0, s0, 2		# t0 = (i << 2)
	add t0, s2, t0		# t0 = Vector_1_address + t0
	lw a0, 0(t0)		# Load a0 = Vector_1[t0]
	
	slli t1, s0, 2		# t1 = (i << 2)
	add t1, s3, t1		# t1 = Vector_2_address + t1
	lw a1, 0(t1)		# Load a1 = Vector_1[t1]
	
	jal ra product		# Call product 
	add s1, s1, a2		# result += product(a0, a1)
		
	addi s0, s0, 1		# i++
	jal ra for_loop		# Jump for_loop
	# for end
	
	#jal ra exit		# Jump exit (dead line)
	
product: # int Producto(int a, int b)
	mul a2, a0, a1		# a2 = a0 * a1
	jalr zero, ra, 0	# Return to caller

exit: # Program end
	addi zero, zero, 0 	# nop
	addi zero, zero, 0 	# nop
