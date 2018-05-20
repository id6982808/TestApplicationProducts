        .data
A:      .word 13
B:      .word 37
C:      .word 0
N:	.word 32

	.text

main:	
	j start


prod:	
	lw $t0,A           # multiplier :A
	lw $t1,B           # multiplicand :B
	or $t2,$zero,$zero # product :C
	addi $t4,$zero,1   # tmp left shift 1,2,4,8....
	lw $t9,N           # max num for end loop

	andi $t0,$t0,1       # get multiplier.0
step1: 	beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
	add $t2,$t2,$t1      # add product :C

step2:	addu $t1,$t1,$t1 # shift left

                         
	addu $t4,$t4,$t4 # shift right 1 (shift left)
	lw $t0,A         # shift right 2 (reload A)
	and $t0,$t0,$t4  # shift right 3 (get next multiplier)

	slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
	beq $t5,$zero,loopend  # if $t4 > A, loopend
	j step1                # otherwise, goto step1

loopend: sw $t2,C        # store product in C
	jr $ra


start:	
	jal prod
	lw $s0,C

	addi $s1,$zero,3
	addi $s2,$zero,2
	sw $s1,A
	sw $s2,B
	jal prod
	lw $s3,C

exit:	j exit

