.include	"MacroFile.asm"
.data
msg:		.asciiz "\nPlease enter the filename to compress or <enter> to exit: "
msg2:		.asciiz "Error opening file. Program terminating."
msg4:		.asciiz "Original data:\n"
msg5:		.asciiz "\nCompressed data:\n"
msg6:		.asciiz	"\nUncompressed data:\n"
msg7:		.asciiz "\nOriginal file size: "
msg8:		.asciiz "\nCompressed file size: "
fileName:	.space	40
compBuffer:	.space 1024
uncompBuffer:	.space 1024

.text
main:
		allocate_heap(1024)
loop1:		print_string(msg)
		get_string(fileName)
		lb	$t0, fileName			# Check if user insert <enter> so program can terminate
		beq	$t0, 10, exit
		newLine_remover(fileName)
		open_file(fileName)
		blt	$s6, $zero, fileError
		read_file				# Return number of chars read into $s2 and $s1 holds address of input buffer
		close_file
		print_string(msg4)
		byte_recycler($s1, $s2)
		print_buffer($s1)
		
		la	$a0, ($s1)			# Set $a0 to the address of input buffer
		la	$a1, compBuffer			# Set $a1 to the address of compression buffer
		add	$a2, $zero, $s2			# Set $a2 to the size of original file
		jal	compressionFunction
		add	$s0, $zero, $v0			# Set $s0 to the size of compressed file
		jal	printCompressedData
		jal	uncompressionFunction
		jal	printUncompressedData
		
		print_string(msg7)
		print_int($a2)
		print_string(msg8)
		print_int($s0)
		j	loop1
		
fileError:	print_string(msg2)
		exit	
			
compressionFunction:
		add	$t1, $zero, $zero		# $t1 = 0
		addi	$t3, $zero, 49			# $t3 = 49 (1's ASCII value)
		add	$t4, $zero, $zero		# $t4 = 0
loop2:		lb	$t0, ($a0)			# Load byte of input buffer
		beq	$t0, 0, endOfString		# Check if byte has end-of-string value
		beq	$t0, $t1, equalChar		# Check if two consecutive chars have the same ASCII value
		beq	$t1, $zero, firstByte		# Check if it is the first byte being analyzed
		sb	$t1, ($a1)			# Save byte into the compressed buffer
		addi	$a1, $a1, 1			# Increment $a1 value for next byte of compressed buffer
		sb	$t3, ($a1)			# Save num of times that char repeats to compressed buffer
		addi	$t3, $zero, 49			# Reset counter for num of repetive chars
		addi	$a1, $a1, 1			# Increment $a1 value for next byte of compressed buffer
		addi	$t4, $t4, 2			# Counter for size of compressed data
firstByte:	add	$t1, $zero, $t0			# Copy byte into $t1 to compare to next one
		addi	$a0, $a0, 1			# Increment $a0 value for next byte
		j	loop2
		
equalChar:	addi	$t3, $t3, 1			# Increment num of same consecutive chars
		addi	$a0, $a0, 1			# Increment $a0 value for next byte
		j	loop2
		
endOfString:	sb	$t1, ($a1)			# Save byte into the compressed buffer
		addi	$a1, $a1, 1			# Increment $a1 value for next byte of compressed buffer
		sb	$t3, ($a1)			# Save num of times that char repeats to compressed buffer
		addi	$t4, $t4, 2			# Counter for size of compressed data
		addi	$a1, $a1, 1			# Increment $a1 value for next byte of compressed buffer
		sb	$zero, ($a1)			# Save null as last byte of the compressed buffer
		add	$v0, $zero, $t4			# Return size of compressed data in $v0
		jr	$ra
		
		
printCompressedData:	
		sub	$a1, $a1, $s0			# Set pointer to beginning of compressed buffer
		print_string(msg5)
loop3:		lb	$t0, ($a1)
		beq	$t0, 0, endOfString2
		print_char($t0)
		addi	$a1, $a1, 1			# Increment $a1 value for next byte of compressed buffer
		j	loop3
endOfString2:	jr	$ra

uncompressionFunction:
		sub	$a1, $a1, $s0			# Set pointer to beginning of compressed buffer
		la	$a3, uncompBuffer			
loop4:		lb	$t0, ($a1)
		beq	$t0, 0, endOfString3
		blt	$t0, 49, notValidNumber
		bgt	$t0, 57, notValidNumber
		bne	$t0, 49, moreThanOne
		addi	$a1, $a1, 1			# Increment $a1 to point for next byte of compressed buffer		
		j	loop4
moreThanOne:	sub	$t0, $t0, 48			# $t0 = decimal num
		addi	$t2, $zero, 1			# t2 = 1
inLoop:		beq	$t2, $t0, endLoop
		sb	$t1, ($a3)			# Save repetitive byte to uncompressed buffer
		addi	$t2, $t2, 1			# $t2++
		addi	$a3, $a3, 1			# Increment $a2 to next repetitive byte to be stored to uncompressed buffer
		j	inLoop
endLoop:	addi	$a1, $a1, 1			# Increment $a1 to point for next byte of compressed buffer
		j	loop4
notValidNumber:	sb	$t0, ($a3)
		add	$t1, $zero, $t0			# Copy byte from compressed buffer into $t1
		addi	$a3, $a3, 1			# Increment $a3 to store next byte to uncompressed buffer
		addi	$a1, $a1, 1			# Increment $a1 to point for next byte of compressed buffer
		j	loop4
endOfString3:	sb	$zero, ($a3)			# Save null as last byte of the uncompressed buffer
		jr	$ra
		
printUncompressedData:
		la 	$a3, uncompBuffer			
		print_string(msg6)
loop5:		lb	$t0, ($a3)
		beq	$t0, 0, endOfString4
		print_char($t0)
		addi	$a3, $a3, 1			# Increment $a3 value for next byte of uncompressed buffer
		j	loop5
endOfString4:	jr	$ra
		
exit:		exit
	
	
