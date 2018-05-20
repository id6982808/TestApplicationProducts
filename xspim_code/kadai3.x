        .data
N:      .word 10    # The length of Array

A:      .word 8     # A[0] = 8
        .word 4     # A[1] = 4
        .word 7
        .word 12
        .word 13
        .word 19
        .word 23
        .word 43
        .word 56    # A[8] = 56
        .word 32    # A[9] = 32

B:      .space 40   # 配列B の格納先　大きさは40バイト

        .text
main: 	or $t0,$zero,$zero # counter
	lw $t1,N           # max length
	la $t2,A           # load the address of A[0]
	la $t3,B           # load the address of B[0]

loop:	beq $t0,$t1,loopend
	addi $t0,$t0,1
	lw $t4,0($t2)
	sw $t4,0($t3)
	addi $t2,$t2,4 # addressing A+4
	addi $t3,$t3,4 # addressing B+4
	j loop

loopend:

exit:	j exit
