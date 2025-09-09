`timescale 1ns/1ps
module ALU(A,B,en,y);
input [3:0] A,B;
input [2:0] en;
output reg [3:0]y;
always @(*)
begin
case(en)
3'b110: y=A+B;
3’b011: y=A-B;
3'b010: y=A&B;
3’b101: y=A|B;
3'b100: y=A^B;
default: y=4'b0000;
endcase
end
endmodule
