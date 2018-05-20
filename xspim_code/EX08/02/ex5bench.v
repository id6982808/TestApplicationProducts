`timescale 1ns/1ps

`include "MIPSmulticycle.v"

module ex5bench;

reg CK;
reg CLR;

MIPSmulticycle mips_mul(CK,CLR);

initial
begin

$dumpfile("ex5bench.vcd"); //Function call for the save of execution results as VCD format to     
$dumpvars(0, mips_mul); //Function call to specify the top module

// text segment
Mem.cell['h00000000] = 32'h08000400;   // j 0x1000

Mem.cell['h00001000] = 32'h34105000;   // ori $16, $0, 20480 [A]          ; 47: la $s0,A	# address of A[0]
Mem.cell['h00001004] = 32'h34115040;   // ori $17, $0, 20544 [B]          ; 48: la $s1,B	# address of B[0]
Mem.cell['h00001008] = 32'h34125080;   // ori $18, $0, 20608 [C]          ; 49: la $s2,C	# address of C[0]
Mem.cell['h0000100c] = 32'h00002025;   // or $4, $0, $0                   ; 51: or $a0,$zero,$zero # for Iloop. (counter I address)
Mem.cell['h00001010] = 32'h00002825;   // or $5, $0, $0                   ; 52: or $a1,$zero,$zero # for Iloop. (counter i)
Mem.cell['h00001014] = 32'h0010d020;   // add $26, $0, $16                ; 55: add $k0,$zero,$s0 # load address of A[0]
Mem.cell['h00001018] = 32'h0012d820;   // add $27, $0, $18                ; 56: add $k1,$zero,$s2 # load address of C[0]
Mem.cell['h0000101c] = 32'h0344d020;   // add $26, $26, $4                ; 58: add $k0,$k0,$a0    # next A[i][]
Mem.cell['h00001020] = 32'h0364d820;   // add $27, $27, $4                ; 59: add $k1,$k1,$a0    # next C[i][]
Mem.cell['h00001024] = 32'h28b50004;   // slti $21, $5, 4                 ; 61: slti $s5,$a1,4      # counter i < 4
Mem.cell['h00001028] = 32'h12a0002c;   // beq $21, $0, 176 [exit-0x00001028]; 62: beq $s5,$zero,exit # if counter i >= 4, goto exit
Mem.cell['h0000102c] = 32'h20840010;   // addi $4, $4, 16                 ; 63: addi $a0,$a0,16    # 0,16,32,48
Mem.cell['h00001030] = 32'h20a50001;   // addi $5, $5, 1                  ; 64: addi $a1,$a1,1     # counter++
Mem.cell['h00001034] = 32'h00001025;   // or $2, $0, $0                   ; 66: or $v0,$zero,$zero # for Jloop. (counter J address)
Mem.cell['h00001038] = 32'h00001825;   // or $3, $0, $0                   ; 67: or $v1,$zero,$zero # for Jloop. (counter j)
Mem.cell['h0000103c] = 32'h001a5820;   // add $11, $0, $26                ; 70: add $t3,$zero,$k0 # load address of A[0]
Mem.cell['h00001040] = 32'h00117020;   // add $14, $0, $17                ; 71: add $t6,$zero,$s1 # load address of B[0]
Mem.cell['h00001044] = 32'h001b7820;   // add $15, $0, $27                ; 72: add $t7,$zero,$k1 # load address of C[0]
Mem.cell['h00001048] = 32'h01c27020;   // add $14, $14, $2                ; 74: add $t6,$t6,$v0 # next B[][j]
Mem.cell['h0000104c] = 32'h01e27820;   // add $15, $15, $2                ; 75: add $t7,$t7,$v0 # next C[][j]
Mem.cell['h00001050] = 32'h28750004;   // slti $21, $3, 4                 ; 77: slti $s5,$v1,4       # counter j < 4
Mem.cell['h00001054] = 32'h12a0ffef;   // beq $21, $0, -68 [Iloop-0x00001054]; 78: beq $s5,$zero,Iloop # if counter j >= 4, goto i
Mem.cell['h00001058] = 32'h20420004;   // addi $2, $2, 4                  ; 79: addi $v0,$v0,4      # 0,4,8,12
Mem.cell['h0000105c] = 32'h20630001;   // addi $3, $3, 1                  ; 80: addi $v1,$v1,1      # counter++
Mem.cell['h00001060] = 32'h0000b025;   // or $22, $0, $0                  ; 82: or $s6,$zero,$zero # for Kloop. (sum)
Mem.cell['h00001064] = 32'h0000b825;   // or $23, $0, $0                  ; 83: or $s7,$zero,$zero # for Kloop. (counter k)
Mem.cell['h00001068] = 32'h8d730000;   // lw $19, 0($11)                  ; 86: lw $s3,0($t3) # A
Mem.cell['h0000106c] = 32'h8dd40000;   // lw $20, 0($14)                  ; 87: lw $s4,0($t6) # B
Mem.cell['h00001070] = 32'hac1350c0;   // sw $19, 20672($0) [tA]          ; 88: sw $s3,tA
Mem.cell['h00001074] = 32'hac1450c4;   // sw $20, 20676($0) [tB]          ; 89: sw $s4,tB
Mem.cell['h00001078] = 32'h8c0850c0;   // lw $8, 20672($0) [tA]           ; 93: lw $t0,tA           # multiplier :A
Mem.cell['h0000107c] = 32'h8c0950c4;   // lw $9, 20676($0) [tB]           ; 94: lw $t1,tB           # multiplicand :B
Mem.cell['h00001080] = 32'h00005025;   // or $10, $0, $0                  ; 95: or $t2,$zero,$zero # product :C
Mem.cell['h00001084] = 32'h200c0001;   // addi $12, $0, 1                 ; 96: addi $t4,$zero,1   # tmp left shift 1,2,4,8....
Mem.cell['h00001088] = 32'h8c1950cc;   // lw $25, 20684($0) [N]           ; 97: lw $t9,N          # max num for end loop
Mem.cell['h0000108c] = 32'h31080001;   // andi $8, $8, 1                  ; 99: andi $t0,$t0,1       # get multiplier.0
Mem.cell['h00001090] = 32'h11000001;   // beq $8, $0, 4 [step2-0x00001090]; 100: beq $t0,$zero,step2  # multiplier.0 == 0, goto step2
Mem.cell['h00001094] = 32'h01495020;   // add $10, $10, $9                ; 101: add $t2,$t2,$t1      # add product :C
Mem.cell['h00001098] = 32'h01294820;   // add $9, $9, $9                  ; 103: add $t1,$t1,$t1 # shift left
Mem.cell['h0000109c] = 32'h018c6020;   // add $12, $12, $12               ; 106: add $t4,$t4,$t4 # shift right 1 (shift left)
Mem.cell['h000010a0] = 32'h8c0850c0;   // lw $8, 20672($0) [tA]           ; 107: lw $t0,tA         # shift right 2 (reload A)
Mem.cell['h000010a4] = 32'h010c4024;   // and $8, $8, $12                 ; 108: and $t0,$t0,$t4  # shift right 3 (get next multiplier)
Mem.cell['h000010a8] = 32'h0199682a;   // slt $13, $12, $25               ; 110: slt $t5,$t4,$t9        # counter check if [ $t4 < multiplier(A) ]
Mem.cell['h000010ac] = 32'h11a00001;   // beq $13, $0, 4 [loopend-0x000010ac]; 111: beq $t5,$zero,loopend  # if $t4 > A, loopend
Mem.cell['h000010b0] = 32'h08000424;   // j 0x00001090 [step1]            ; 112: j step1                # otherwise, goto step1
Mem.cell['h000010b4] = 32'hac0a50c8;   // sw $10, 20680($0) [tC]          ; 114: sw $t2,tC        # store product in C
Mem.cell['h000010b8] = 32'h8c1550c8;   // lw $21, 20680($0) [tC]          ; 117: lw $s5,tC
Mem.cell['h000010bc] = 32'h02d5b020;   // add $22, $22, $21               ; 118: add $s6,$s6,$s5
Mem.cell['h000010c0] = 32'hadf60000;   // sw $22, 0($15)                  ; 119: sw $s6,0($t7)
Mem.cell['h000010c4] = 32'h22f70001;   // addi $23, $23, 1                ; 121: addi $s7,$s7,1  # counter++
Mem.cell['h000010c8] = 32'h2af50004;   // slti $21, $23, 4                ; 122: slti $s5,$s7,4       # counter k < 4
Mem.cell['h000010cc] = 32'h12a0ffdb;   // beq $21, $0, -148 [Jloop-0x000010cc]; 123: beq $s5,$zero,Jloop # if counter k >= 4, goto j
Mem.cell['h000010d0] = 32'h216b0004;   // addi $11, $11, 4                ; 124: addi $t3,$t3,4  # next A[][k]
Mem.cell['h000010d4] = 32'h21ce0010;   // addi $14, $14, 16               ; 125: addi $t6,$t6,16 # next B[k][]
Mem.cell['h000010d8] = 32'h0800041a;   // j 0x00001068 [Kloop]            ; 126: j Kloop
Mem.cell['h000010dc] = 32'h08000437;   // j 0x000010dc [exit]             ; 128: j exit

// data segment
Mem.cell['h00005000] = 32'h00000000;
Mem.cell['h00005004] = 32'h00000001;
Mem.cell['h00005008] = 32'h00000000;
Mem.cell['h0000500c] = 32'h00000000;
Mem.cell['h00005010] = 32'h00000002;
Mem.cell['h00005014] = 32'h00000000;
Mem.cell['h00005018] = 32'h00000000;
Mem.cell['h0000501c] = 32'h00000000;
Mem.cell['h00005020] = 32'h00000000;
Mem.cell['h00005024] = 32'h00000000;
Mem.cell['h00005028] = 32'h00000000;
Mem.cell['h0000502c] = 32'h00000003;
Mem.cell['h00005030] = 32'h00000000;
Mem.cell['h00005034] = 32'h00000000;
Mem.cell['h00005038] = 32'h00000004;
Mem.cell['h0000503c] = 32'h00000000;
Mem.cell['h00005040] = 32'h00000001;
Mem.cell['h00005044] = 32'h00000002;
Mem.cell['h00005048] = 32'h00000003;
Mem.cell['h0000504c] = 32'h00000004;
Mem.cell['h00005050] = 32'h00000005;
Mem.cell['h00005054] = 32'h00000006;
Mem.cell['h00005058] = 32'h00000007;
Mem.cell['h0000505c] = 32'h00000008;
Mem.cell['h00005060] = 32'h00000009;
Mem.cell['h00005064] = 32'h0000000a;
Mem.cell['h00005068] = 32'h0000000b;
Mem.cell['h0000506c] = 32'h0000000c;
Mem.cell['h00005070] = 32'h0000000d;
Mem.cell['h00005074] = 32'h0000000e;
Mem.cell['h00005078] = 32'h0000000f;
Mem.cell['h0000507c] = 32'h00000010;
Mem.cell['h00005080] = 32'h00000000;
Mem.cell['h00005084] = 32'h00000000;
Mem.cell['h00005088] = 32'h00000000;
Mem.cell['h0000508c] = 32'h00000000;
Mem.cell['h00005090] = 32'h00000000;
Mem.cell['h00005094] = 32'h00000000;
Mem.cell['h00005098] = 32'h00000000;
Mem.cell['h0000509c] = 32'h00000000;
Mem.cell['h000050a0] = 32'h00000000;
Mem.cell['h000050a4] = 32'h00000000;
Mem.cell['h000050a8] = 32'h00000000;
Mem.cell['h000050ac] = 32'h00000000;
Mem.cell['h000050b0] = 32'h00000000;
Mem.cell['h000050b4] = 32'h00000000;
Mem.cell['h000050b8] = 32'h00000000;
Mem.cell['h000050bc] = 32'h00000000;
Mem.cell['h000050c0] = 32'h00000000;
Mem.cell['h000050c4] = 32'h00000000;
Mem.cell['h000050c8] = 32'h00000000;
Mem.cell['h000050cc] = 32'h00000020;


CK = 1'b1;
CLR = 1'b1;

#110

CLR = 1'b0;

#3200000 // 5*4*4*4 *100

$display("RESULT:");
$display("arr[]: %x",Mem.cell['h00005080]);
$display("arr[]: %x",Mem.cell['h00005084]);
$display("arr[]: %x",Mem.cell['h00005088]);
$display("arr[]: %x",Mem.cell['h0000508c]);
$display("arr[]: %x",Mem.cell['h00005090]);
$display("arr[]: %x",Mem.cell['h00005094]);
$display("arr[]: %x",Mem.cell['h00005098]);
$display("arr[]: %x",Mem.cell['h0000509c]);
$display("arr[]: %x",Mem.cell['h000050a0]);
$display("arr[]: %x",Mem.cell['h000050a4]);
$display("arr[]: %x",Mem.cell['h000050a8]);
$display("arr[]: %x",Mem.cell['h000050ac]);
$display("arr[]: %x",Mem.cell['h000050b0]);
$display("arr[]: %x",Mem.cell['h000050b4]);
$display("arr[]: %x",Mem.cell['h000050b8]);
$display("arr[]: %x",Mem.cell['h000050bc]);
   
$finish;
end

always #50 CK <= ~CK;

endmodule