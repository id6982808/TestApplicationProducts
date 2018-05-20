	.data
A:	.space 10000 # 4Byte * 2500
B:	.space 10000 # 4Byte * 2500


	.text
main:
	la $a0,A
	la $a1,B
	addi $a2,$zero,2500
	addi $a3,$zero,2500

	sll $a2,$a2,2
	sll $a3,$a3,2
	add $v0,$zero,$zero
	add $t0,$zero,$zero
outer:
	add $t4,$a0,$t0
	lw $t4,0($t4)
	add $t1,$zero,$zero
inner:
	add $t3,$a1,$t1
	lw $t3,0($t3)
	bne $t3,$t4,skip
	addi $v0,$v0,1
skip:		
	addi $t1,$t1,4
	bne $t1,$a3,inner
	addi $t0,$t0,4
	bne $t0,$a2,outer

exit:	j exit
