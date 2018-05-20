module  ALU(A,B,ALUoperation,ALUresult,Zero);   
     
input [31:0]     A;
input [31:0]     B;
input [3:0]      ALUoperation;
output [31:0]    ALUresult;
output           Zero;
     
reg    [31:0]    ALUresult;
wire   [32:0]    tmp;
     
      // Output Zero is defined by assign statement
     
      assign Zero = (ALUresult == 0)? 1'b1 : 1'b0;
     
      // tmp is the result of A - B, in 33bit
     
      assign tmp = {A[31], A} - {B[31], B};
     
      // Output ALUresult is defined by always statement
     
      always @(A or B or ALUoperation or tmp)
        begin case( ALUoperation )
          4'b0000 : ALUresult <= A & B;
          4'b0001 : ALUresult <= A | B;
          4'b0010 : ALUresult <= A + B;
          4'b0110 : ALUresult <= A - B;
          4'b0111 : ALUresult <= {31'b0, tmp[32]};
          4'b1100 : ALUresult <= (~A) & (~B);
          default : ALUresult <= 32'b0;
       endcase
      end
     
endmodule     

