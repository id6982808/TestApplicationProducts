module ALUcontrol(ALUop, FA, FB, ALUoperation);

input [1:0] ALUop;
input [5:0] FA; // 5-0
input [5:0] FB; // 31-26
output [3:0] ALUoperation;
reg [3:0] ALUoperation;

always @(ALUop or FA or FB)
begin

 if(ALUop == 2'b00) ALUoperation <= 4'b0010;

 else if(ALUop == 2'b01) ALUoperation <= 4'b0110;

 else if(ALUop == 2'b10)
  begin
   if(FA == 6'b100000) ALUoperation <= 4'b0010;
   else if(FA == 6'b100010) ALUoperation <= 4'b0110;
   else if(FA == 6'b100100) ALUoperation <= 4'b0000;
   else if(FA == 6'b100101) ALUoperation <= 4'b0001;
   else if(FA == 6'b101010) ALUoperation <= 4'b0111;
  end

 else if(ALUop == 2'b11)
  begin
   if(FB == 6'b001000) ALUoperation <= 4'b0010;
   else if(FB == 6'b001100) ALUoperation <= 4'b0000;
   else if(FB == 6'b001101) ALUoperation <= 4'b0001;
   else if(FB == 6'b001010) ALUoperation <= 4'b0111;
  end 

end


/*
input [1:0]     ALUop;
input [5:0]     FA;// {F5,F4,F3,F2,F1,F0}
input [5:0]     FB;// {F31,F30,F29,F28,F27,F26}
output [3:0]    ALUoperation;
     
wire        ALUoperation0, ALUoperation1, ALUoperation2;
     
      assign ALUoperation0 = (ALUop[1] && ~ALUop[0] && FA[0]) || (ALUop[1] && ~ALUop[0] && FA[3]) || (ALUop[1] && ALUop[0] && FB[0]) || (ALUop[1] && ALUop[0] && FB[1]);
   
      assign ALUoperation1 = (~ALUop[1]) || (~ALUop[0] && ~FA[2]) || (ALUop[0] && ~FB[2]);
   
      assign ALUoperation2 = ( ~ALUop[1] && ALUop[0]) || (ALUop[1] && ~ALUop[0] && FA[1]) || (ALUop[1] && ALUop[0] && FB[1])  ;    
 
      assign ALUoperation = {1'b0, ALUoperation2, ALUoperation1, ALUoperation0};
*/

endmodule