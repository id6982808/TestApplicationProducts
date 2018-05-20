module Memory(Address, WriteData, ReadData, MemWrite, MemRead, CK);

input[31:0] 	Address, WriteData;
input           MemWrite, MemRead, CK;
output[31:0]	ReadData;

always @(posedge CK)
 begin 
   if (( MemWrite == 1'b1 ) && (32'h00000000 <= Address) && ( Address <= 32'h0000ffff) )
     begin
       Mem.cell[Address] = WriteData;
     end
 end

assign #5 ReadData = (MemRead == 1'b1) && (32'h00000000 <= Address) && ( Address <= 32'h0000ffff) ? Mem.cell[Address] : 32'bx;

endmodule


module Mem ();
  reg [31:0]  cell [0:65535];
endmodule
