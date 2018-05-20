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
	lw   $5, A		#  lw のテスト
	lw   $6, B		#  lw のテスト
	lw   $7, C		#  lw のテスト
	sw   $5, A($7)		#  sw のテスト (期待結果 = 0x335e) 

	add  $8, $5, $6		#  add のテスト 
	sw   $8, ADD_RSLT	#  期待結果 = 0x407f
	
	sub  $9, $5, $6         #  sub のテスト 
	sw   $9, SUB_RSLT	#  期待結果 = 0x263d

	addi $10, $5, 0x100     #  addi のテスト 
	sw   $10, ADDI_RSLT	#  期待結果 = 0x345e
	
	and  $11, $5, $6        #  and のテスト 
	sw   $11, AND_RSLT	#  期待結果 = 0x100

	or   $12, $5, $6        #  or のテスト 
	sw   $12, OR_RSLT	#  期待結果 = 0x3f7f
	
	andi $13, $5, 0x1ff     #  andi のテスト
	sw   $13, ANDI_RSLT	#  期待結果 = 0x15e

	ori  $14, $5, 0x1ff	#  ori のテスト
	sw   $14, ORI_RSLT	#  期待結果 = 0x33ff
	
	ori  $15, $0, 1		#  j のテストのための初期設定
	j skip1
	ori  $15, $0, 0
skip1:
	sw   $15, J_RSLT	#  期待結果 = 1
		
	ori  $15, $0, 1        	#  beq のテストのための初期設定
	ori  $16, $0, 2        	#  beq のテストのための初期設定
	beq  $15, $16, skip2    #  beq のテスト (not taken)
	ori  $16, $0, 3
skip2:		
	sw   $16, BEQ_NT_RSLT	#  期待結果 = 3
	
	ori  $16, $0, 1
	beq  $15, $16, skip3    #  beq のテスト (taken)
	ori  $16, $0, 3
skip3:	
	sw   $16, BEQ_T_RSLT	#  期待結果 = 1
	
	slt  $17, $5, $6        #  slt のテスト
	sw   $17, SLT0_RSLT	#  期待結果 = 0
	slt  $18, $6, $5        #
	sw   $18, SLT1_RSLT	#  期待結果 = 1
	
	slti $19, $5, 0x1000    #  slti のテスト
	sw   $19, SLTI0_RSLT	#  期待結果 = 0
	slti $20, $5, 0x5000    #
	sw   $20, SLTI1_RSLT   	#  期待結果 = 1
exit:
	j    exit