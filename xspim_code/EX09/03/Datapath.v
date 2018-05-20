`include "ALU.v"
`include "Memory.v"
`include "Registers.v" // Register File


module Datapath( CK, CLR, ALUOp, ALUSrcA, ALUSrcB, IRWrite, IorD, MemRead, MemWrite, MemtoReg, PCSource, PCWrite, PCWriteCond, RegDst, RegWrite, Op, Op2, ALUoperation);

input   CK;  
input   CLR;  
input [1:0]  ALUOp;  
input   ALUSrcA ;  
input [2:0]  ALUSrcB ;  
input   IRWrite ;  
input   IorD ;  
input   MemRead ;  
input   MemWrite ;  
input [1:0]  MemtoReg ;  
input [1:0]  PCSource ;  
input   PCWrite ;  
input   PCWriteCond ;  
input [1:0]  RegDst ;  
input   RegWrite ;
input [3:0] ALUoperation;
  
output [5:0]  Op ;
output [5:0] Op2;


reg [31:0] out_PC;
reg [31:0] out_mux3;
reg [31:0] ALUOut;
reg [31:0] out_mux2_1;
reg [4:0] out_mux2_2;
reg [31:0] out_mux2_3;
reg [31:0] out_mux2_4;
reg [31:0] out_mux5;
reg [31:0] A;
reg [31:0] B;
reg [31:0] MDR;
reg [31:0] InstReg;

wire PCload;
wire [31:0] from_ALU;
wire from_ALU_zero;
wire [31:0] from_RF1;
wire [31:0] from_RF2;
wire [31:0] from_memory;
wire [4:0] from_InstReg_25_21;
wire [4:0] from_InstReg_20_16;
wire [15:0] from_InstReg_15_0;


// PCload
assign PCload = (PCWrite | ( from_ALU_zero & PCWriteCond ));



// PC
always @(posedge CK)
begin
 if(CLR == 1'b1)
  out_PC <= 32'h00000000;
 else if(PCload == 1'b1)
  out_PC <= out_mux3;
end


// Multiplexor 2 to 1 (1)
always @(IorD or out_PC or ALUOut)
begin
 if(IorD == 1'b0) out_mux2_1 <= out_PC;
 else if(IorD == 1'b1) out_mux2_1 <= ALUOut;
 else out_mux2_1 <= 32'hxxxxxxxx; 
end


// Memory data
Memory _memory(out_mux2_1, B, from_memory, MemWrite, MemRead, CK);


// Instruction Register
always @(posedge CK or posedge CLR) 
begin
      if(CLR==1'b1) InstReg <= 32'h00000000;
     else if(IRWrite==1'b1) InstReg <= from_memory;
end

   assign Op = InstReg[31:26];
   assign Op2 = InstReg[5:0];
   assign from_InstReg_25_21 = InstReg[25:21];
   assign from_InstReg_20_16 = InstReg[20:16];
   assign from_InstReg_15_0 = InstReg[15:0];


// Multiplexor 2 to 1 (2)
always @(RegDst or from_InstReg_20_16 or from_InstReg_15_0)
begin
  if(RegDst == 1'b0) out_mux2_2 <= from_InstReg_20_16;
  else if(RegDst == 1'b1) out_mux2_2 <= from_InstReg_15_0[15:11];
  else if(RegDst == 2'b10) out_mux2_2 <= 5'd31;
end


// Multiplexor 2 to 1 (3)
always @(MemtoReg or ALUOut or MDR or out_PC)
begin
  if(MemtoReg == 2'b00) out_mux2_3 <= ALUOut;
  else if(MemtoReg == 2'b01) out_mux2_3 <= MDR;
  else if(MemtoReg == 2'b10) out_mux2_3 <= out_PC;
end


// Memory Data Register
always @(posedge CK or posedge CLR) 
begin
      MDR <= from_memory;
      if(CLR==1'b1) MDR <=32'h00000000;
end



// Register File
Registers RegFile(from_InstReg_25_21, from_InstReg_20_16, out_mux2_3, RegWrite, out_mux2_2, CK, CLR, from_RF1, from_RF2);


// A
/*
always @(posedge CK or posedge CLR) begin
      if(CLR == 1'b1)
        A <= 32'h00000000;
      else A <= from_RF1;
   end
*/
always @(from_RF1) begin
      A <= from_RF1;
   end



// B
always @(posedge CK or posedge CLR) begin
      if(CLR == 1'b1)
        B <= 32'h00000000;
      else B <= from_RF2;
   end

// Multiplexor 2 to 1 (4)
always @(ALUSrcA or out_PC or A)
begin
  if(ALUSrcA == 1'b0) out_mux2_4 <= out_PC;
  else if(ALUSrcA == 1'b1) out_mux2_4 <= A;
end


// Multiplexor 5 to 1
always @(ALUSrcB or B or from_InstReg_15_0)
begin
  if(ALUSrcB == 3'b000) out_mux5 <= B;
  else if(ALUSrcB == 3'b001) out_mux5 <= 32'd4;
  else if(ALUSrcB == 3'b010) out_mux5 <= {{16{from_InstReg_15_0[15]}}, from_InstReg_15_0};
  else if(ALUSrcB == 3'b011) out_mux5 <= {{14{from_InstReg_15_0[15]}}, from_InstReg_15_0, 2'b00};
  else if(ALUSrcB == 3'b100) out_mux5 <= {16'h0000, from_InstReg_15_0};
end


// ALU
ALU alu(out_mux2_4, out_mux5, ALUoperation, from_ALU, from_ALU_zero);


// ALUOut register
always @(posedge CK or posedge CLR)
begin
      if(CLR == 1'b1)
        ALUOut <= 32'h00000000;
      else ALUOut <= from_ALU;
end


// Multiplexor 3 to 1
always @(PCSource or from_ALU or ALUOut or out_PC or InstReg or A)
begin
  if(PCSource == 2'b00) out_mux3 <= from_ALU;
  else if(PCSource == 2'b01) out_mux3 <= ALUOut;
  else if(PCSource == 2'b10) out_mux3 <= {out_PC[31:28], InstReg[25:0], 2'b00};
  else if(PCSource == 2'b11) out_mux3 <= A;
end


endmodule