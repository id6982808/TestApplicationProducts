	.data
A:	.word 19
B:	.word 75
C:	.word 10
S:	.word 0

	.text
main:	lw $t0,A
	lw $t1,B
	lw $t2,C
	add $t3,$t0,$t1
	sub $t4,$t3,$t2
	ori $t5,$t4,3
	sw $t5,S
exit:	j exit
