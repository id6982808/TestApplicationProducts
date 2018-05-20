        .data
A:      .word 0
        .word 1
        .word 0
        .word 0 
	.word 2
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 3
	.word 0
	.word 0
	.word 4
	.word 0

B:	.word 1
        .word 2
        .word 3
        .word 4 
	.word 5
	.word 6
	.word 7
	.word 8
	.word 9
	.word 10
	.word 11
	.word 12
	.word 13
	.word 14
	.word 15
	.word 16
	
C:	.space 64

tA:	.space 4
tB:	.space 4
tC:	.space 4
N:	.word 32   # max length for loop of product

	.text
main:	
	j start

	# --------------- multiply ---------------------- #
prod:	
	# $t0,$t1,$t2,$4,$t5,$t9 is used.
	lw $t0,tA           # multiplier :A
	lw $t1,tB           # multiplicand :B
	or $t2,$zero,$zero # product :C
	addi $t4,$zero,1   # tmp left shift 1,2,4,8....
	lw $t9,N          # max num for end loop

	andi $t0,$t0,1       # get multiplier.0
step1: 	beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
	add $t2,$t2,$t1      # add product :C

step2:	addu $t1,$t1,$t1 # shift left

                         
	addu $t4,$t4,$t4 # shift right 1 (shift left)
	lw $t0,tA         # shift right 2 (reload A)
	and $t0,$t0,$t4  # shift right 3 (get next multiplier)

	slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
	beq $t5,$zero,loopend  # if $t4 > A, loopend
	j step1                # otherwise, goto step1

loopend: sw $t2,tC        # store product in C
	jr $ra
	# ----------------------------------------------- #



start:
	# C[i][j] += A[i][k] * B[k][j]
	la $s0,A	# address of A[0]
	la $s1,B	# address of B[0]
	la $s2,C	# address of C[0]

	or $a0,$zero,$zero # for Iloop. (counter I address)
	or $a1,$zero,$zero # for Iloop. (counter i)
Iloop:	
	# i loop
	add $k0,$zero,$s0 # load address of A[0]
	add $k1,$zero,$s2 # load address of C[0]

	add $k0,$k0,$a0    # next A[i][]
	add $k1,$k1,$a0    # next C[i][]
	
	slti $s5,$a1,4      # counter i < 4
	beq $s5,$zero,exit # if counter i >= 4, goto exit
	addi $a0,$a0,16    # 0,16,32,48
	addi $a1,$a1,1     # counter++

	or $v0,$zero,$zero # for Jloop. (counter J address)
	or $v1,$zero,$zero # for Jloop. (counter j)
Jloop:	
	# j loop ( $s5 is tmp )
	add $t3,$zero,$k0 # load address of A[0]
	add $t6,$zero,$s1 # load address of B[0]
	add $t7,$zero,$k1 # load address of C[0]

	add $t6,$t6,$v0 # next B[][j]
	add $t7,$t7,$v0 # next C[][j]
	
	slti $s5,$v1,4       # counter j < 4
	beq $s5,$zero,Iloop # if counter j >= 4, goto i
	addi $v0,$v0,4      # 0,4,8,12
	addi $v1,$v1,1      # counter++

	or $s6,$zero,$zero # for Kloop. (sum)
	or $s7,$zero,$zero # for Kloop. (counter k)
Kloop:	
	# k loop ( $s5 is tmp )
	lw $s3,0($t3) # A ( $a0 in ex. page )
	lw $s4,0($t6) # B ( $a1 in ex. page )
	sw $s3,tA
	sw $s4,tB
	jal prod
	lw $s5,tC     # C ( $v0 in ex. page )
        add $s6,$s6,$s5
	sw $s6,0($t7)
	
	addi $s7,$s7,1  # counter++
	slti $s5,$s7,4       # counter k < 4
	beq $s5,$zero,Jloop # if counter k >= 4, goto j
	addi $t3,$t3,4  # next A[][k]
	addi $t6,$t6,16 # next B[k][]
	j Kloop
		
exit:	j exit
