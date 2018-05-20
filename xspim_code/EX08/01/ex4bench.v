`timescale 1ns/1ps

`include "MIPSmulticycle.v"

module ex4bench;

reg CK;
reg CLR;

MIPSmulticycle mips_mul(CK,CLR);

initial
begin

$dumpfile("ex4bench.vcd"); //Function call for the save of execution results as VCD format to     
$dumpvars(0, mips_mul); //Function call to specify the top module

// text segment
Mem.cell['h00000000] = 32'h08000400;   // j 0x1000

Mem.cell['h00001000] = 32'h8c085000;   // lw $8, 20480($0) [A]            ; 8: lw $t0,A           # multiplier :A
Mem.cell['h00001004] = 32'h8c095004;   // lw $9, 20484($0) [B]            ; 9: lw $t1,B           # multiplicand :B
Mem.cell['h00001008] = 32'h00005025;   // or $10, $0, $0                  ; 10: or $t2,$zero,$zero # product :C
Mem.cell['h0000100c] = 32'h200c0001;   // addi $12, $0, 1                 ; 11: addi $t4,$zero,1   # tmp left shift 1,2,4,8....
Mem.cell['h00001010] = 32'h8c19500c;   // lw $25, 20492($0) [N]           ; 12: lw $t9,N           # max num for end loop
Mem.cell['h00001014] = 32'h31080001;   // andi $8, $8, 1                  ; 14: andi $t0,$t0,1       # get multiplier.0
Mem.cell['h00001018] = 32'h11000001;   // beq $8, $0, 4 [step2-0x00001018]; 15: beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
Mem.cell['h0000101c] = 32'h01495020;   // add $10, $10, $9                ; 16: add $t2,$t2,$t1      # add product :C
Mem.cell['h00001020] = 32'h01294820;   // add $9, $9, $9                  ; 18: add $t1,$t1,$t1 # shift left
Mem.cell['h00001024] = 32'h018c6020;   // add $12, $12, $12               ; 21: add $t4,$t4,$t4 # shift right 1 (shift left)
Mem.cell['h00001028] = 32'h8c085000;   // lw $8, 20480($0) [A]            ; 22: lw $t0,A         # shift right 2 (reload A)
Mem.cell['h0000102c] = 32'h010c4024;   // and $8, $8, $12                 ; 23: and $t0,$t0,$t4  # shift right 3 (get next multiplier)
Mem.cell['h00001030] = 32'h0199682a;   // slt $13, $12, $25               ; 25: slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
Mem.cell['h00001034] = 32'h11a00001;   // beq $13, $0, 4 [loopend-0x00001034]; 26: beq $t5,$zero,loopend  # if $t4 > A, loopend
Mem.cell['h00001038] = 32'h08000406;   // j 0x00001018 [step1]            ; 27: j step1                # otherwise, goto step1
Mem.cell['h0000103c] = 32'hac0a5008;   // sw $10, 20488($0) [C]           ; 29: sw $t2,C        # store product in C
Mem.cell['h00001040] = 32'h08000410;   // j 0x00001040 [exit]             ; 31: j exit

// data segment
Mem.cell['h00005000] = 32'h0000000d;
Mem.cell['h00005004] = 32'h00000025;
Mem.cell['h00005008] = 32'h00000000;
Mem.cell['h0000500c] = 32'h00000020;

CK = 1'b1;
CLR = 1'b1;

#110

CLR = 1'b0;

#20000
   $display("RESULT:");
   $display("mul:  %x",Mem.cell['h00005008]);
$finish;
end

always #50 CK <= ~CK;

endmodule