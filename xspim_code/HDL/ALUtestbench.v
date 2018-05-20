`timescale 1ns/1ps     
     
`include "ALU.v"   // Include statement of ALU module  
     
module  ALUtestbench;   // testbench module ALUtestbench do not have inputs and output
     
reg [31:0]     inA;
reg [31:0]     inB;
reg [3:0]      inALUop;
wire [31:0]    outALUresult;
wire           outZero;
     
ALU     alu(inA,inB,inALUop,outALUresult,outZero); // Instance definition
     
initial     
 begin     
     
  $dumpfile("ALUtestbench.vcd"); //Function call for the save of execution results as VCD format to     
  $dumpvars(0, alu); //Function call to specify the top module     
     

  // AND op
  #0 inALUop = 4'b0000;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h0F0F0F0F; inB = 32'hF0F0F0F0;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'hf0f0f0f0; inB = 32'h0f0f0f0f;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hFFFFFFFF; inB = 32'hFFFFFFFF;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 
     
  
  // OR op
  #0 inALUop = 4'b0001;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h0F0F0F0F; inB = 32'hF0F0F0F0;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'hf0f0f0f0; inB = 32'h0f0f0f0f;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hFFFFFFFF; inB = 32'hFFFFFFFF;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 


  // ADD op
  #0 inALUop = 4'b0010;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h0F0F0F0F; inB = 32'hF0F0F0F0;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'h7FFFFFFF; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hFFFFFFFF; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 


  // SUB op
  #0 inALUop = 4'b0110;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h00000000; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'h00000001; inB = 32'h80000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'h00000001; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 


  // SLT op
  #0 inALUop = 4'b0111;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h00000000; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'h00000001; inB = 32'h80000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'h00000001; inB = 32'h00000001;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 


  // NOR op
  #0 inALUop = 4'b1100;

  inA= 32'h00000000; inB = 32'h00000000;      //Setting of inputs
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);         

  inA= 32'h0F0F0F0F; inB = 32'hFFFFFFFF;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero);    
     
  inA= 32'hf0f0f0f0; inB = 32'h0f0f0f0f;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hFFFFFFFF; inB = 32'hFFFFFFFF;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 

  inA= 32'hD8A3B8D4; inB = 32'h63B9D6F2;           
  #100           
  $display( $time, " ALUoperation=%h, A=%h, B=%h, ALUresult=%h, Zero=%h",inALUop,inA,inB,outALUresult,outZero); 




  inALUop = 4'b0000; inA= 32'h00000000; inB = 32'h00000000; // dummy input
  $finish;      
 end     
endmodule     
