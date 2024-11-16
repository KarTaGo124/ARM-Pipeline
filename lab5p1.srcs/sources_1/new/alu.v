`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:35:36 AM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(input [31:0] SrcA, input [31:0] SrcB, input [1:0] ALUControl, output reg [31:0]  ALUResult, output wire [3:0] ALUFlags);
  
wire neg, zero, carry, overflow;
wire [31:0] condinvb;
wire [32:0] sum;

assign condinvb = ALUControl[0] ? ~SrcB : SrcB;
assign sum = SrcA + condinvb + ALUControl[0];
  
always @(*)
    begin
        casex (ALUControl[1:0])
            2'b0?: ALUResult = sum;
            2'b10: ALUResult = SrcA & SrcB;
            2'b11: ALUResult = SrcA | SrcB;
        endcase
    end

assign neg = ALUResult[31];
assign zero = (ALUResult == 32'b0);
assign carry = (ALUControl[1] == 1'b0) & sum[32];
assign overflow = (ALUControl[1] ==1'b0) & ~(SrcA[31] ^ SrcB[31] ^ ALUControl[0]) & (SrcA[31] ^ sum[31]);

assign ALUFlags = {neg, zero, carry, overflow};
endmodule






