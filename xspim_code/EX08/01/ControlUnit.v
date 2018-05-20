`define LW 35
`define SW 43
`define RTYPE 0
`define BEQ 4
`define JMP 2
`define ADDI 8
`define SLTI 10
`define ANDI 12
`define ORI 13

// assign A = state == 0 || state == 1; これは if文で書く場合注意。ステート 0,1 以外の場合にも記述が必要。

module ControlUnit(PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDST, Op, CK, CLR);

input CK;
input CLR;

output PCWriteCond;
output PCWrite;
output IorD;
output MemRead;
output MemWrite;
output MemtoReg;
output IRWrite;
output [1:0] PCSource;
output [1:0] ALUOp;
output [2:0] ALUSrcB;
output ALUSrcA;
output RegWrite;
output RegDST;


reg PCWriteCond;
reg PCWrite;
reg IorD;
reg MemRead;
reg MemWrite;
reg MemtoReg;
reg IRWrite;
reg [1:0] PCSource;
reg [1:0] ALUOp;
reg [2:0] ALUSrcB;
reg ALUSrcA;
reg RegWrite;
reg RegDST;


input [5:0] Op;

reg [3:0] state;


always @(posedge CK or posedge CLR)
begin
 if(CLR==1) state <= 0;
 else
  case(state)
   0: state <= 1;

   1:
    begin
     if(Op == `LW || Op == `SW)
      state <= 2;
     else if(Op == `RTYPE)
      state <= 6;
     else if(Op == `BEQ)
      state <= 8;
     else if(Op == `JMP)
      state <= 9;
     else if(Op == `ADDI || Op == `SLTI)
      state <= 10;
     else if(Op == `ANDI || Op == `ORI)
      state <= 12;
    end

   2:
    begin
     if(Op == `LW)
      state <= 3;
     else if(Op == `SW)
      state <= 5;
    end

   3: state <= 4;

   4: state <= 0;

   5: state <= 0;

   6: state <= 7;

   7: state <= 0;

   8: state <= 0;

   9: state <= 0;

   10: state <= 11;

   11: state <= 0;

   12: state <= 11;

   default: ;
  endcase
end


/*
assign MemRead = state == 0 || state == 3;

assign ALUSrcA = state == 0 ? 1'b0 : state == 1 ? 1'b0 : state == 2 ? 1'b1 : state == 6 ? 1'b1 : state == 8 ? 1'b1 : state == 10 ? 1'b1 : state == 12 ? 1'b1 : 1'bx;

assign IorD = state == 0 ? 1'b0 : state == 3 ? 1'b1 : state == 5 ? 1'b1 : 1'bx;

assign IRWrite = state == 0;

assign ALUSrcB = state == 0 ? 3'b001 : state == 1 ? 3'b011 : state == 2 ? 3'b010 : state == 6 ? 3'b000 : state == 8 ? 3'b000 : state == 10 ? 3'b010 : state == 12 ? 3'b100 : 3'bxxx;

assign ALUOp = state == 0 ? 2'b00 : state == 1 ? 2'b00 : state == 2 ? 2'b00 : state == 6 ? 2'b10 : state == 8 ? 2'b01 : state == 10 ? 2'b11 : state == 12 ? 2'b11 : 2'bxx;

assign PCWrite = state == 0 || state == 9;
assign PCSource = state == 0 ? 2'b00 : state == 8 ? 2'b01 : state == 9 ? 2'b10 : 2'bxx;
assign RegDST = state == 4 ? 1'b0 : state == 7 ? 1'b1 : state == 11 ? 1'b0 : 1'bx;
assign MemtoReg = state == 4 ? 1'b1 : state == 7 ? 1'b0 : state == 11 ? 1'b0 : 1'bx;
assign MemWrite = state == 5;
assign PCWriteCond = state == 8;
assign RegWrite = state == 4 || state == 7  || state == 11;
*/



always @(state)
begin
 case(state)
  0:
   begin
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    MemRead <= 1;
    ALUSrcA <= 1'b0;
    IorD <= 1'b0;
    IRWrite <= 1;
    ALUSrcB <= 3'b001;
    ALUOp <= 2'b00;
    PCWrite <= 1;
    PCSource <= 2'b00;
   end

  1:
   begin
    MemRead <= 0;
    IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b0;
    ALUSrcB <= 3'b011;
    ALUOp <= 2'b00;
   end

  2:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b1;
    ALUSrcB <= 3'b010;
    ALUOp <= 2'b00;
   end

  3:
   begin
    MemRead <= 1;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    IorD <= 1'b1;
   end

  4:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
    RegDST <= 1'b0;
    RegWrite <= 1;
    MemtoReg <= 1'b1;
   end

  5:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    MemWrite <= 1;
    IorD <= 1'b1;
   end

  6:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b1;
    ALUSrcB <= 3'b000;
    ALUOp <= 2'b10;
   end

  7:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
    RegDST <= 1'b1;
    RegWrite <= 1;
    MemtoReg <= 1'b0;
   end

  8:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b1;
    ALUSrcB <= 3'b000;
    ALUOp <= 2'b01;
    PCWriteCond <= 1;
    PCSource <= 2'b01;
   end

  9:
   begin
    MemRead <= 0;
IRWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    PCWrite <= 1;
    PCSource <= 2'b10;
   end

  10:
   begin
    MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b1;
    ALUSrcB <= 3'b010;
    ALUOp <= 2'b11;
   end

  11:
   begin
 MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
    RegDST <= 1'b0;
    RegWrite <= 1;
    MemtoReg <= 1'b0;
   end

  12:
   begin
MemRead <= 0;
IRWrite <= 0;
PCWrite <= 0;
MemWrite <= 0;
PCWriteCond <= 0;
RegWrite <= 0;
    ALUSrcA <= 1'b1;
    ALUSrcB <= 3'b100;
    ALUOp <= 2'b11;
   end

  default: ;
 endcase
end


endmodule
