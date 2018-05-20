        .data
N:      .word 5
FN:     .word 0
tA:	.space 4
tB:	.space 4
tC:	.space 4

	.text
main:   
	ori $sp, $0, 32767
	lw $a0, N         # $a0(= N) = 10
        jal fact          # $v0 = fact($a0)
        sw $v0 FN         # FN = $v0
        exit: j exit

fact:   addi $sp, $sp, -8 # $sp = $sp - 8 変更点１
        sw $ra, 4($sp)
        sw $a0, 0($sp)

        slti $t0, $a0,1   # $t1 = ($a0 < 1) 1:0
        beq $t0, $0, L1   # if $t1 = 0 then L1

        addi $v0,$0,1     # $v0 = 1
        addi $sp,$sp,8    # $sp = $sp + 8
        jr $ra            # return FN = 1

L1:     addi $a0,$a0,-1
        jal fact          # fact($a0 - 1)
        lw $a0, 0($sp)
        lw $ra, 4($sp)
        addi $sp,$sp,8

	addi $sp,$sp,-8	# allocate stack
	sw $t0,4($sp)	# push $t0 (also used in MUL)
	sw $ra,0($sp)	# push $ra (also used in MUL by jal inst.)
	sw $a0,tA	# ...init. for MUL
	sw $v0,tB	# ...
	jal MUL		# ...MUL...
	lw $v0,tC	# ...
	lw $ra,0($sp)	# pop $ra (used by next jal)
	lw $t0,4($sp)	# pop $t0 (used by next inst.)
	addi $sp,$sp,8	# discard stack

        jr $ra 

MUL:	# $t0,$t1,$t2,$4,$t5,$t9 is used.
	lw $t0,tA           # multiplier :A
	lw $t1,tB           # multiplicand :B
	or $t2,$zero,$zero # product :C
	addi $t4,$zero,1   # tmp left shift 1,2,4,8....
	lw $t9,N          # max num for end loop

	andi $t0,$t0,1       # get multiplier.0
step1: 	beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
	add $t2,$t2,$t1      # add product :C

step2:	add $t1,$t1,$t1 # shift left

                         
	add $t4,$t4,$t4 # shift right 1 (shift left)
	lw $t0,tA         # shift right 2 (reload A)
	and $t0,$t0,$t4  # shift right 3 (get next multiplier)

	slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
	beq $t5,$zero,loopend  # if $t4 > A, loopend
	j step1                # otherwise, goto step1

loopend: sw $t2,tC        # store product in C
	jr $ra
