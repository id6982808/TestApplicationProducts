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
S:      .word 0

        .text
main: 	or $t0,$zero,$zero # $t0 = i
	lw $t1,N           # $t1 = N(max length)
	or $t2,$zero,$zero # $t2 = sum
	la $t3,A # $t3 <- load the address of A[0]
	
loop:	beq $t0,$t1,loopend # i == n, -> loopend
	addi $t0,$t0,1      # i++
	lw $t4,0($t3) # このように記述しないとメモリとして扱えない？
	add $t2,$t2,$t4
	addi $t3,$t3,4      # addressing next..
	j loop

loopend: sw $t2,S

exit:	j exit
