`include "ControlUnit.v"
`include "ALUcontrol.v"
`include "Datapath.v"

module MIPSmulticycle(CK, CLR);

input CK;
input CLR;

wire [1:0] wALUOp;
wire wALUSrcA;
wire [2:0] wALUSrcB;
wire wIRWrite ;  
wire wIorD ;  
wire wMemRead ;  
wire wMemWrite ;  
wire wMemtoReg ;  
wire [1:0] wPCSource ;  
wire wPCWrite ;  
wire wPCWriteCond ;  
wire wRegDst ;  
wire wRegWrite ;  
wire [5:0] wOp ;
wire [5:0] wOp2;
wire [3:0] wALUoperation;
wire [31:0] wInstReg;


ControlUnit main_cont_unit(wPCWriteCond, wPCWrite, wIorD, wMemRead, wMemWrite, wMemtoReg, wIRWrite, wPCSource, wALUOp, wALUSrcB, wALUSrcA, wRegWrite, wRegDst, wOp, CK, CLR);

Datapath data_path(CK, CLR, wALUOp, wALUSrcA, wALUSrcB, wIRWrite, wIorD, wMemRead, wMemWrite, wMemtoReg, wPCSource, wPCWrite, wPCWriteCond, wRegDst, wRegWrite, wOp, wOp2, wALUoperation);

ALUcontrol alu_cont_unit(wALUOp, wOp2, wOp, wALUoperation);


endmodule