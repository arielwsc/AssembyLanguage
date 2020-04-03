.macro	print_int (%x)			# Macro to print an integer to console
	la	$a0, (%x)
	li	$v0, 1
	syscall
.end_macro

.macro print_char (%c)			# Macro to print a char to console
	la	$a0, (%c)
	li	$v0, 11
	syscall
.end_macro

.macro print_string (%s)		# Macro to print a string to console
	li	$v0, 4
	la	$a0, %s
	syscall
.end_macro

.macro print_buffer (%b)		# Macro to point a string to console sing argument as reference to address of string
	li	$v0, 4
	la	$a0, (%b)
	syscall
.end_macro

.macro get_string (%s)			# Macro to get a string from user
	li	$v0, 8
	la	$a0, %s
	li	$a1, 40
	syscall
.end_macro

.macro newLine_remover (%s)		# Macro to remove newline char from a string
	la	$a0, %s
loop:	lb 	$t0, ($a0)		# Load byte into $t0
	beq 	$t0, 0, endString	# Check if byte has a end-of-string value
	addi 	$a0, $a0, 1		# Increment $a0 to next byte
	j	loop
	
endString:
	lb	$t0, ($a0)
	beq	$t0, 10, newLine	# Check if byte has a newline value
	sub	$a0, $a0, 1		# Decrement $a0 to previous byte
	j	endString
	
newLine:
	sb	$zero, ($a0)		# Overwrite newline with end-of-string value
.end_macro

.macro open_file (%file)		# Macro to open a file
	li	$v0, 13
	la	$a0, %file
	li	$a1, 0
	li	$a2, 0
	syscall
	move	$s6, $v0
.end_macro

.macro read_file
.data
buffer:	.space 1024
.text
	li	$v0, 14			# Read from file and save into buffer
	move	$a0, $s6
	la	$a1, buffer
	li	$a2, 1024
	syscall
	la	$s1, buffer
	move	$s2, $v0
.end_macro

.macro close_file			# Close file syscall
	li	$v0, 16
	move	$a0, $s6
	syscall
.end_macro

.macro exit				# Exit the program
	li	$v0, 10
	syscall
.end_macro

.macro allocate_heap (%h)
.data
p:	.word 	0
.text
	li	$v0, 9			#Allocate
	li	$a0, %h			#h bytes
	syscall
	sw	$v0, p			#Save pointer
.end_macro

.macro byte_recycler (%inBuffer, %numBytes)	# This macro separates only the bytes needed from the input buffer
	add	$t1, $zero, %numBytes
	la	$t2, (%inBuffer)
	add	$t2, $t2, $t1
	sb	$zero, ($t2)
.end_macro