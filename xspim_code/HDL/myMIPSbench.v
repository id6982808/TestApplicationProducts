`timescale 1ns/1ps

`include "MIPSmulticycle.v"

module myMIPSbench;

reg CK;
reg CLR;

MIPSmulticycle mips_mul(CK,CLR);

initial
begin

$dumpfile("myMIPSbench.vcd"); //Function call for the save of execution results as VCD format to     
$dumpvars(0, mips_mul); //Function call to specify the top module

// text segment

Mem.cell['h00000000] = 32'h08000400;   // j 0x1000
Mem.cell['h00001000] = 32'h8c055000;   // lw $5, 20480($0) [A]            ; 23: lw   $5, A		#  lw のテスト
Mem.cell['h00001004] = 32'h8c065004;   // lw $6, 20484($0) [B]            ; 24: lw   $6, B		#  lw のテスト
Mem.cell['h00001008] = 32'h8c075008;   // lw $7, 20488($0) [C]            ; 25: lw   $7, C		#  lw のテスト
Mem.cell['h0000100c] = 32'hace55000;   // sw $5, 20480($7) [A]            ; 26: sw   $5, A($7)		#  sw のテスト (期待結果 = 0x335e) 
Mem.cell['h00001010] = 32'h00a64020;   // add $8, $5, $6                  ; 28: add  $8, $5, $6		#  add のテスト 
Mem.cell['h00001014] = 32'hac085010;   // sw $8, 20496($0) [ADD_RSLT]     ; 29: sw   $8, ADD_RSLT	#  期待結果 = 0x407f
Mem.cell['h00001018] = 32'h00a64822;   // sub $9, $5, $6                  ; 31: sub  $9, $5, $6         #  sub のテスト 
Mem.cell['h0000101c] = 32'hac095014;   // sw $9, 20500($0) [SUB_RSLT]     ; 32: sw   $9, SUB_RSLT	#  期待結果 = 0x263d
Mem.cell['h00001020] = 32'h20aa0100;   // addi $10, $5, 256               ; 34: addi $10, $5, 0x100     #  addi のテスト 
Mem.cell['h00001024] = 32'hac0a5018;   // sw $10, 20504($0) [ADDI_RSLT]   ; 35: sw   $10, ADDI_RSLT	#  期待結果 = 0x345e
Mem.cell['h00001028] = 32'h00a65824;   // and $11, $5, $6                 ; 37: and  $11, $5, $6        #  and のテスト 
Mem.cell['h0000102c] = 32'hac0b501c;   // sw $11, 20508($0) [AND_RSLT]    ; 38: sw   $11, AND_RSLT	#  期待結果 = 0x100
Mem.cell['h00001030] = 32'h00a66025;   // or $12, $5, $6                  ; 40: or   $12, $5, $6        #  or のテスト 
Mem.cell['h00001034] = 32'hac0c5020;   // sw $12, 20512($0) [OR_RSLT]     ; 41: sw   $12, OR_RSLT	#  期待結果 = 0x3f7f
Mem.cell['h00001038] = 32'h30ad01ff;   // andi $13, $5, 511               ; 43: andi $13, $5, 0x1ff     #  andi のテスト
Mem.cell['h0000103c] = 32'hac0d5024;   // sw $13, 20516($0) [ANDI_RSLT]   ; 44: sw   $13, ANDI_RSLT	#  期待結果 = 0x15e
Mem.cell['h00001040] = 32'h34ae01ff;   // ori $14, $5, 511                ; 46: ori  $14, $5, 0x1ff	#  ori のテスト
Mem.cell['h00001044] = 32'hac0e5028;   // sw $14, 20520($0) [ORI_RSLT]    ; 47: sw   $14, ORI_RSLT	#  期待結果 = 0x33ff
Mem.cell['h00001048] = 32'h340f0001;   // ori $15, $0, 1                  ; 49: ori  $15, $0, 1		#  j のテストのための初期設定
Mem.cell['h0000104c] = 32'h08000415;   // j 0x00001054 [skip1]            ; 50: j skip1
Mem.cell['h00001050] = 32'h340f0000;   // ori $15, $0, 0                  ; 51: ori  $15, $0, 0
Mem.cell['h00001054] = 32'hac0f502c;   // sw $15, 20524($0) [J_RSLT]      ; 53: sw   $15, J_RSLT	#  期待結果 = 1
Mem.cell['h00001058] = 32'h340f0001;   // ori $15, $0, 1                  ; 55: ori  $15, $0, 1        	#  beq のテストのための初期設定
Mem.cell['h0000105c] = 32'h34100002;   // ori $16, $0, 2                  ; 56: ori  $16, $0, 2        	#  beq のテストのための初期設定
Mem.cell['h00001060] = 32'h11f00001;   // beq $15, $16, 4 [skip2-0x00001060]; 57: beq  $15, $16, skip2    #  beq のテスト (not taken)
Mem.cell['h00001064] = 32'h34100003;   // ori $16, $0, 3                  ; 58: ori  $16, $0, 3
Mem.cell['h00001068] = 32'hac105030;   // sw $16, 20528($0) [BEQ_NT_RSLT] ; 60: sw   $16, BEQ_NT_RSLT	#  期待結果 = 3
Mem.cell['h0000106c] = 32'h34100001;   // ori $16, $0, 1                  ; 62: ori  $16, $0, 1
Mem.cell['h00001070] = 32'h11f00001;   // beq $15, $16, 4 [skip3-0x00001070]; 63: beq  $15, $16, skip3    #  beq のテスト (taken)
Mem.cell['h00001074] = 32'h34100003;   // ori $16, $0, 3                  ; 64: ori  $16, $0, 3
Mem.cell['h00001078] = 32'hac105034;   // sw $16, 20532($0) [BEQ_T_RSLT]  ; 66: sw   $16, BEQ_T_RSLT	#  期待結果 = 1
Mem.cell['h0000107c] = 32'h00a6882a;   // slt $17, $5, $6                 ; 68: slt  $17, $5, $6        #  slt のテスト
Mem.cell['h00001080] = 32'hac115038;   // sw $17, 20536($0) [SLT0_RSLT]   ; 69: sw   $17, SLT0_RSLT	#  期待結果 = 0
Mem.cell['h00001084] = 32'h00c5902a;   // slt $18, $6, $5                 ; 70: slt  $18, $6, $5        #
Mem.cell['h00001088] = 32'hac12503c;   // sw $18, 20540($0) [SLT1_RSLT]   ; 71: sw   $18, SLT1_RSLT	#  期待結果 = 1
Mem.cell['h0000108c] = 32'h28b31000;   // slti $19, $5, 4096              ; 73: slti $19, $5, 0x1000    #  slti のテスト
Mem.cell['h00001090] = 32'hac135040;   // sw $19, 20544($0) [SLTI0_RSLT]  ; 74: sw   $19, SLTI0_RSLT	#  期待結果 = 0
Mem.cell['h00001094] = 32'h28b45000;   // slti $20, $5, 20480             ; 75: slti $20, $5, 0x5000    #
Mem.cell['h00001098] = 32'hac145044;   // sw $20, 20548($0) [SLTI1_RSLT]  ; 76: sw   $20, SLTI1_RSLT   	#  期待結果 = 1
Mem.cell['h0000109c] = 32'h08000427;   // j 0x0000109c [exit]             ; 78: j    exit

/*
Mem.cell['h00000000] = 32'h8c055000;   // lw $5, 20480($0) [A]
Mem.cell['h00000004] = 32'h8c065004;   // lw $6, 20484($0) [B]
Mem.cell['h00000008] = 32'h8c075008;   // lw $7, 20488($0) [C]
Mem.cell['h0000000c] = 32'hace55000;   // sw $5, 20480($7) [A]
Mem.cell['h00000010] = 32'h00a64020;   // add $8, $5, $6
Mem.cell['h00000014] = 32'hac085010;   // sw $8, 20496($0) [ADD_RSLT]
Mem.cell['h00000018] = 32'h00a64822;   // sub $9, $5, $6
Mem.cell['h0000001c] = 32'hac095014;   // sw $9, 20500($0) [SUB_RSLT]
Mem.cell['h00000020] = 32'h20aa0100;   // addi $10, $5, 256          
Mem.cell['h00000024] = 32'hac0a5018;   // sw $10, 20504($0) [ADDI_RSLT]
Mem.cell['h00000028] = 32'h00a65824;   // and $11, $5, $6              
Mem.cell['h0000002c] = 32'hac0b501c;   // sw $11, 20508($0) [AND_RSLT]
Mem.cell['h00000030] = 32'h00a66025;   // or $12, $5, $6              
Mem.cell['h00000034] = 32'hac0c5020;   // sw $12, 20512($0) [OR_RSLT] 
Mem.cell['h00000038] = 32'h30ad01ff;   // andi $13, $5, 511           
Mem.cell['h0000003c] = 32'hac0d5024;   // sw $13, 20516($0) [ANDI_RSLT] 
Mem.cell['h00000040] = 32'h34ae01ff;   // ori $14, $5, 511             
Mem.cell['h00000044] = 32'hac0e5028;   // sw $14, 20520($0) [ORI_RSLT]
Mem.cell['h00000048] = 32'h340f0001;   // ori $15, $0, 1             
Mem.cell['h0000004c] = 32'h08000015;   // j 0x00000054 [skip1]        
Mem.cell['h00000050] = 32'h340f0000;   // ori $15, $0, 0            
Mem.cell['h00000054] = 32'hac0f502c;   // sw $15, 20524($0) [J_RSLT]
Mem.cell['h00000058] = 32'h340f0001;   // ori $15, $0, 1            
Mem.cell['h0000005c] = 32'h34100002;   // ori $16, $0, 2           
Mem.cell['h00000060] = 32'h11f00001;   // beq $15, $16, 4 [skip2]
Mem.cell['h00000064] = 32'h34100003;   // ori $16, $0, 3               
Mem.cell['h00000068] = 32'hac105030;   // sw $16, 20528($0) [BEQ_NT_RSLT]
Mem.cell['h0000006c] = 32'h34100001;   // ori $16, $0, 1              
Mem.cell['h00000070] = 32'h11f00001;   // beq $15, $16, 4 [skip3]
Mem.cell['h00000074] = 32'h34100003;   // ori $16, $0, 3               
Mem.cell['h00000078] = 32'hac105034;   // sw $16, 20532($0) [BEQ_T_RSLT]
Mem.cell['h0000007c] = 32'h00a6882a;   // slt $17, $5, $6               
Mem.cell['h00000080] = 32'hac115038;   // sw $17, 20536($0) [SLT0_RSLT] 
Mem.cell['h00000084] = 32'h00c5902a;   // slt $18, $6, $5               
Mem.cell['h00000088] = 32'hac12503c;   // sw $18, 20540($0) [SLT1_RSLT] 
Mem.cell['h0000008c] = 32'h28b31000;   // slti $19, $5, 4096            
Mem.cell['h00000090] = 32'hac135040;   // sw $19, 20544($0) [SLTI0_RSLT]
Mem.cell['h00000094] = 32'h28b45000;   // slti $20, $5, 20480           
Mem.cell['h00000098] = 32'hac145044;   // sw $20, 20548($0) [SLTI1_RSLT]
Mem.cell['h0000009c] = 32'h08000027;   // j 0x0000009c [exit]           
*/

// data segment
Mem.cell['h00005000] = 32'h0000335e;
Mem.cell['h00005004] = 32'h00000d21;
Mem.cell['h00005008] = 32'h0000000c;
Mem.cell['h0000500c] = 32'h00000000;
Mem.cell['h00005010] = 32'h00000000;
Mem.cell['h00005014] = 32'h00000000;
Mem.cell['h00005018] = 32'h00000000;
Mem.cell['h0000501c] = 32'h00000000;
Mem.cell['h00005020] = 32'h00000000;
Mem.cell['h00005024] = 32'h00000000;
Mem.cell['h00005028] = 32'h00000000;
Mem.cell['h0000502c] = 32'h00000000;
Mem.cell['h00005030] = 32'h00000000;
Mem.cell['h00005034] = 32'h00000000;
Mem.cell['h00005038] = 32'h00000000;
Mem.cell['h0000503c] = 32'h00000000;
Mem.cell['h00005040] = 32'h00000000;
Mem.cell['h00005044] = 32'h00000000;

CK = 1'b1;
CLR = 1'b1;

#110

CLR = 1'b0;

#20000
   $display("RESULT:");
   //$display("test      : %x",Mem.cell['h00001000]);
   $display("sw:   335e: %x",Mem.cell['h500c]);
   $display("add:  407f: %x",Mem.cell['h5010]);
   $display("sub:  263d: %x",Mem.cell['h5014]);
   $display("addi: 345e: %x",Mem.cell['h5018]);
   $display("and:   100: %x",Mem.cell['h501c]);
   $display("or:   3f7f: %x",Mem.cell['h5020]);
   $display("andi:  15e: %x",Mem.cell['h5024]);
   $display("ori:  33ff: %x",Mem.cell['h5028]);
   $display("j:       1: %x",Mem.cell['h502c]);
   $display("beq_nt:  3: %x",Mem.cell['h5030]);
   $display("beq_t:   1: %x",Mem.cell['h5034]);
   $display("slt0:    0: %x",Mem.cell['h5038]);
   $display("slt1:    1: %x",Mem.cell['h503c]);
   $display("slti0:   0: %x",Mem.cell['h5040]);
   $display("slti1:   1: %x",Mem.cell['h5044]);
   $finish;
end

always #50 CK <= ~CK;

endmodule
