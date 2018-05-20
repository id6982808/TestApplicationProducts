	 .data
A:		.word  0x335e	
B:	 	.word  0x0d21
C:	 	.word  0xc
SW_RSLT:	.word  0
ADD_RSLT:	.word  0		
SUB_RSLT:	.word  0	
ADDI_RSLT:	.word  0	
AND_RSLT:	.word  0
OR_RSLT:	.word  0
ANDI_RSLT:	.word  0
ORI_RSLT:	.word  0
J_RSLT:		.word  0
BEQ_NT_RSLT:	.word  0
BEQ_T_RSLT:	.word  0
SLT0_RSLT:	.word  0
SLT1_RSLT:	.word  0
SLTI0_RSLT:	.word  0
SLTI1_RSLT:	.word  0
	
	.text
main:
	lw   $5, A		#  lw $B$N%F%9%H(B
	lw   $6, B		#  lw $B$N%F%9%H(B
	lw   $7, C		#  lw $B$N%F%9%H(B
	sw   $5, A($7)		#  sw $B$N%F%9%H(B ($B4|BT7k2L(B = 0x335e) 

	add  $8, $5, $6		#  add $B$N%F%9%H(B 
	sw   $8, ADD_RSLT	#  $B4|BT7k2L(B = 0x407f
	
	sub  $9, $5, $6         #  sub $B$N%F%9%H(B 
	sw   $9, SUB_RSLT	#  $B4|BT7k2L(B = 0x263d

	addi $10, $5, 0x100     #  addi $B$N%F%9%H(B 
	sw   $10, ADDI_RSLT	#  $B4|BT7k2L(B = 0x345e
	
	and  $11, $5, $6        #  and $B$N%F%9%H(B 
	sw   $11, AND_RSLT	#  $B4|BT7k2L(B = 0x100

	or   $12, $5, $6        #  or $B$N%F%9%H(B 
	sw   $12, OR_RSLT	#  $B4|BT7k2L(B = 0x3f7f
	
	andi $13, $5, 0x1ff     #  andi $B$N%F%9%H(B
	sw   $13, ANDI_RSLT	#  $B4|BT7k2L(B = 0x15e

	ori  $14, $5, 0x1ff	#  ori $B$N%F%9%H(B
	sw   $14, ORI_RSLT	#  $B4|BT7k2L(B = 0x33ff
	
	ori  $15, $0, 1		#  j $B$N%F%9%H$N$?$a$N=i4|@_Dj(B
	j skip1
	ori  $15, $0, 0
skip1:
	sw   $15, J_RSLT	#  $B4|BT7k2L(B = 1
		
	ori  $15, $0, 1        	#  beq $B$N%F%9%H$N$?$a$N=i4|@_Dj(B
	ori  $16, $0, 2        	#  beq $B$N%F%9%H$N$?$a$N=i4|@_Dj(B
	beq  $15, $16, skip2    #  beq $B$N%F%9%H(B (not taken)
	ori  $16, $0, 3
skip2:		
	sw   $16, BEQ_NT_RSLT	#  $B4|BT7k2L(B = 3
	
	ori  $16, $0, 1
	beq  $15, $16, skip3    #  beq $B$N%F%9%H(B (taken)
	ori  $16, $0, 3
skip3:	
	sw   $16, BEQ_T_RSLT	#  $B4|BT7k2L(B = 1
	
	slt  $17, $5, $6        #  slt $B$N%F%9%H(B
	sw   $17, SLT0_RSLT	#  $B4|BT7k2L(B = 0
	slt  $18, $6, $5        #
	sw   $18, SLT1_RSLT	#  $B4|BT7k2L(B = 1
	
	slti $19, $5, 0x1000    #  slti $B$N%F%9%H(B
	sw   $19, SLTI0_RSLT	#  $B4|BT7k2L(B = 0
	slti $20, $5, 0x5000    #
	sw   $20, SLTI1_RSLT   	#  $B4|BT7k2L(B = 1
exit:
	j    exit