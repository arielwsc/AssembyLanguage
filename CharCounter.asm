.data

msg:	.asciiz "Enter some text"
msg1:	.asciiz "Num of char(s): "
msg2:	.asciiz "Num of word(s): "
msg3:	.asciiz "Thank you for using my program. "
msg4:	.asciiz "Bye!"
str:	.space 100
numChar:.word 0
numWord:.word 0
space1:	.word '\n'

.text

main:
	li	$v0, 54			# Pop up input dialog string from the user
	la	$a0, msg
	la	$a1, str
	la	$a2, 100
	syscall
	
	la	$a0, str		# Save string from user into $a0	
	jal	charWordCounter		# Function call
	
	sw	$v0, numChar		# Load $v0 into memory
	sw	$v1, numWord		# Load $v1 into memory
	
	
	li 	$v0, 4			# Display results of number of chars and words
	la 	$a0, str
	syscall
	la 	$a0, msg1
	li 	$v0, 4
	syscall
	lw 	$a0, numChar
	li 	$v0, 1
	syscall
	la 	$a0, space1
	li 	$v0, 4
	syscall
	la 	$a0, msg2
	li 	$v0, 4
	syscall
	lw 	$a0, numWord
	li 	$v0, 1
	syscall
	
	li	$v0, 59			# Prompt a final message to user before exiting the program
	la	$a0, msg3
	la	$a1, msg4
	syscall
	
exit:	li $v0, 10			# Program exit out
	syscall
	
charWordCounter:
	addi 	$sp, $sp, -4		# Adjust stack for 4 bytes
	sw	$s1, 0($sp)		# Push $s1 into stack
	
	add 	$t1, $zero, $zero	# charCounter = 0
	add	$t2, $zero, $zero	# wordCounter = 0
	
loop:	lb 	$t0, ($a0)		# Load byte into $t0
	beq 	$t0, '\0', endString	# Check if byte has a end-of-string value
	beq 	$t0, '\n', endString	# Check if byte has a newline value
	beq	$t0, ' ', space		# Check if byte has a space value
	addi 	$t1, $t1, 1		# charCounter++
	addi 	$a0, $a0, 1		# Increment $a0 to next byte
	j	loop			# Loop terminates when byte has a end-of-string or new-line value
	
space:	addi 	$t2, $t2, 1		# wordCounter++
	addi 	$a0, $a0, 1		# Increment $a0 to next byte
	j	loop			# Loop terminates when byte has a end-of-string or new-line value
	
endString:
	bge	$t2, 1, totalChar	# wordCounter >= 1
	beq	$t1, 0, result		# charCounter == 1
	addi	$t2, $t2, 1		# wordCounter++ as there is only one word
	j	result
	
totalChar:
	addi	$t1, $t1, 1		# charCounter++ as space counts as one char	
	addi	$t2, $t2, 1		# wordCounter++ as if numChar >= 1 && numSpace = 0, then numWord = 1
	
result:
	add	$v0, $t1, $zero		# Save $t1 (num of chars) into $v0
	add	$v1, $t2, $zero		# Save $t2 (num of words) into $v1
	
	lw	$s1, 0($sp)		# Set pointer to where $s1 was pushed in stack
	addi	$sp, $sp, 4		# Pop $s1 from stack
	jr	$ra			# PC to resume where it was left off in main
		
	