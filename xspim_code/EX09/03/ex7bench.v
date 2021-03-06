`timescale 1ns/1ps

`include "MIPSmulticycle.v"

module ex4bench;

reg CK;
reg CLR;

MIPSmulticycle mips_mul(CK,CLR);

initial
begin

$dumpfile("ex7bench.vcd"); //Function call for the save of execution results as VCD format to     
$dumpvars(0, mips_mul); //Function call to specify the top module

// text segment
Mem.cell['h00000000] = 32'h08000400;   // j 0x1000

Mem.cell['h00001000] = 32'h341d7fff;   // ori $29, $0, 32767              ; 10: ori $sp, $0, 32767
Mem.cell['h00001004] = 32'h8c045000;   // lw $4, 20480($0) [N]            ; 11: lw $a0, N         # $a0(= N) = 10
Mem.cell['h00001008] = 32'h0c000405;   // jal 0x00001014 [fact]           ; 12: jal fact          # $v0 = fact($a0)
Mem.cell['h0000100c] = 32'hac025004;   // sw $2, 20484($0) [FN]           ; 13: sw $v0 FN         # FN = $v0
Mem.cell['h00001010] = 32'h08000404;   // j 0x00001010 [exit]             ; 14: j exit
Mem.cell['h00001014] = 32'h23bdfff8;   // addi $29, $29, -8               ; 16: addi $sp, $sp, -8 # $sp = $sp - 8 �ѹ�����
Mem.cell['h00001018] = 32'hafbf0004;   // sw $31, 4($29)                  ; 17: sw $ra, 4($sp)
Mem.cell['h0000101c] = 32'hafa40000;   // sw $4, 0($29)                   ; 18: sw $a0, 0($sp)
Mem.cell['h00001020] = 32'h28880001;   // slti $8, $4, 1                  ; 20: slti $t0, $a0,1   # $t1 = ($a0 < 1) 1:0
Mem.cell['h00001024] = 32'h11000003;   // beq $8, $0, 12 [L1-0x00001024]  ; 21: beq $t0, $0, L1   # if $t1 = 0 then L1
Mem.cell['h00001028] = 32'h20020001;   // addi $2, $0, 1                  ; 23: addi $v0,$0,1     # $v0 = 1
Mem.cell['h0000102c] = 32'h23bd0008;   // addi $29, $29, 8                ; 24: addi $sp,$sp,8    # $sp = $sp + 8
Mem.cell['h00001030] = 32'h03e00008;   // jr $31                          ; 25: jr $ra            # return FN = 1
Mem.cell['h00001034] = 32'h2084ffff;   // addi $4, $4, -1                 ; 27: addi $a0,$a0,-1
Mem.cell['h00001038] = 32'h0c000405;   // jal 0x00001014 [fact]           ; 28: jal fact          # fact($a0 - 1)
Mem.cell['h0000103c] = 32'h8fa40000;   // lw $4, 0($29)                   ; 29: lw $a0, 0($sp)
Mem.cell['h00001040] = 32'h8fbf0004;   // lw $31, 4($29)                  ; 30: lw $ra, 4($sp)
Mem.cell['h00001044] = 32'h23bd0008;   // addi $29, $29, 8                ; 31: addi $sp,$sp,8
Mem.cell['h00001048] = 32'h23bdfff8;   // addi $29, $29, -8               ; 33: addi $sp,$sp,-8	# allocate stack
Mem.cell['h0000104c] = 32'hafa80004;   // sw $8, 4($29)                   ; 34: sw $t0,4($sp)	# push $t0 (also used in MUL)
Mem.cell['h00001050] = 32'hafbf0000;   // sw $31, 0($29)                  ; 35: sw $ra,0($sp)	# push $ra (also used in MUL by jal inst.)
Mem.cell['h00001054] = 32'hac045008;   // sw $4, 20488($0) [tA]           ; 36: sw $a0,tA	# ...init. for MUL
Mem.cell['h00001058] = 32'hac02500c;   // sw $2, 20492($0) [tB]           ; 37: sw $v0,tB	# ...
Mem.cell['h0000105c] = 32'h0c00041d;   // jal 0x00001074 [MUL]            ; 38: jal MUL		# ...MUL...
Mem.cell['h00001060] = 32'h8c025010;   // lw $2, 20496($0) [tC]           ; 39: lw $v0,tC	# ...
Mem.cell['h00001064] = 32'h8fbf0000;   // lw $31, 0($29)                  ; 40: lw $ra,0($sp)	# pop $ra (used by next jal)
Mem.cell['h00001068] = 32'h8fa80004;   // lw $8, 4($29)                   ; 41: lw $t0,4($sp)	# pop $t0 (used by next inst.)
Mem.cell['h0000106c] = 32'h23bd0008;   // addi $29, $29, 8                ; 42: addi $sp,$sp,8	# discard stack
Mem.cell['h00001070] = 32'h03e00008;   // jr $31                          ; 44: jr $ra 
Mem.cell['h00001074] = 32'h8c085008;   // lw $8, 20488($0) [tA]           ; 47: lw $t0,tA           # multiplier :A
Mem.cell['h00001078] = 32'h8c09500c;   // lw $9, 20492($0) [tB]           ; 48: lw $t1,tB           # multiplicand :B
Mem.cell['h0000107c] = 32'h00005025;   // or $10, $0, $0                  ; 49: or $t2,$zero,$zero # product :C
Mem.cell['h00001080] = 32'h200c0001;   // addi $12, $0, 1                 ; 50: addi $t4,$zero,1   # tmp left shift 1,2,4,8....
Mem.cell['h00001084] = 32'h8c195000;   // lw $25, 20480($0) [N]           ; 51: lw $t9,N          # max num for end loop
Mem.cell['h00001088] = 32'h31080001;   // andi $8, $8, 1                  ; 53: andi $t0,$t0,1       # get multiplier.0
Mem.cell['h0000108c] = 32'h11000001;   // beq $8, $0, 4 [step2-0x0000108c]; 54: beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
Mem.cell['h00001090] = 32'h01495020;   // add $10, $10, $9                ; 55: add $t2,$t2,$t1      # add product :C
Mem.cell['h00001094] = 32'h01294820;   // add $9, $9, $9                  ; 57: add $t1,$t1,$t1 # shift left
Mem.cell['h00001098] = 32'h018c6020;   // add $12, $12, $12               ; 60: add $t4,$t4,$t4 # shift right 1 (shift left)
Mem.cell['h0000109c] = 32'h8c085008;   // lw $8, 20488($0) [tA]           ; 61: lw $t0,tA         # shift right 2 (reload A)
Mem.cell['h000010a0] = 32'h010c4024;   // and $8, $8, $12                 ; 62: and $t0,$t0,$t4  # shift right 3 (get next multiplier)
Mem.cell['h000010a4] = 32'h0199682a;   // slt $13, $12, $25               ; 64: slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
Mem.cell['h000010a8] = 32'h11a00001;   // beq $13, $0, 4 [loopend-0x000010a8]; 65: beq $t5,$zero,loopend  # if $t4 > A, loopend
Mem.cell['h000010ac] = 32'h08000423;   // j 0x0000108c [step1]            ; 66: j step1                # otherwise, goto step1
Mem.cell['h000010b0] = 32'hac0a5010;   // sw $10, 20496($0) [tC]          ; 68: sw $t2,tC        # store product in C
Mem.cell['h000010b4] = 32'h03e00008;   // jr $31                          ; 69: jr $ra

// data segment
Mem.cell['h00005000] = 32'h00000005;
Mem.cell['h00005004] = 32'h00000000;
Mem.cell['h00005008] = 32'h00000000;
Mem.cell['h0000500c] = 32'h00000000;
Mem.cell['h00005010] = 32'h00000000;



CK = 1'b1;
CLR = 1'b1;

#110

CLR = 1'b0;

#500000
   $display("RESULT:");
   $display("res:  %x",Mem.cell['h00005010]);
$finish;
end

always #50 CK <= ~CK;

endmodule