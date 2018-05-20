module Registers(ReadRegster1, ReadRegster2, WriteData, RegWrite, WriteRegster, CK, CLR, ReadData1, ReadData2);

input[4:0] 	ReadRegster1, ReadRegster2, WriteRegster;
input[31:0] 	WriteData;
input		RegWrite, CK, CLR;
output[31:0]	ReadData1, ReadData2;

reg[31:0]	regfile[1:31];
integer i;

always	@(posedge CK) begin
      if (CLR == 1'b1)
            for( i = 1; i < 31; i = i + 1)
                  regfile[i] <= 32'h00000000;
      else if ( RegWrite == 1'b1 && WriteRegster != 5'b00000)
                  regfile[WriteRegster] <= WriteData;
      end
 

assign #5 ReadData1 = (ReadRegster1 == 5'b00000) ? 32'h00000000 : regfile[ReadRegster1];
assign #5 ReadData2 = (ReadRegster2 == 5'b00000) ? 32'h00000000 : regfile[ReadRegster2];

endmodule

