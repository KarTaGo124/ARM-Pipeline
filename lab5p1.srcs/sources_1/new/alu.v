`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// f
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

    
module alu(input [31:0] SrcA,
 input [31:0] SrcB, input [3:0] ALUControl, 
 output reg [31:0]  ALUResult, 
 output wire [3:0] ALUFlags,
 input wire [3:0] ALUFlags_carry);
  
wire neg, zero, carry, overflow;
wire [31:0] condinvb;
wire [32:0] sum;
wire [31:0] sra_neg; //para el rsb y rsc
wire qflag; //para la bandera q
wire adc;
assign adc = ALUFlags_carry[1];

assign sra_neg = ~SrcA +1;
assign condinvb = ALUControl[0] ? ~SrcB : SrcB;
assign sum = SrcA + condinvb + ALUControl[0];

//para el q flag 

wire q;

always @(*)
    begin
        casex (ALUControl[3:0])
            4'b000?: ALUResult = sum; 
            4'b0010: ALUResult = SrcA & SrcB;//and y tst
            4'b0011: ALUResult = SrcA | SrcB;//orr
            4'b0111: ALUResult = SrcA ^ SrcB;//eor xor y teq
            4'b1011: ALUResult = SrcA & ~SrcB;//bic
            //operaciones
            4'b0101: ALUResult = sum - ~adc;//sbc
            4'b0100: ALUResult = sra_neg + SrcB;//rsb
            4'b1000: ALUResult = sra_neg + SrcB - ~adc;  //rsc
            4'b1001: ALUResult = sum + adc; //adc
            4'b1110: 
                if (~qflag)
                    ALUResult = SrcA + SrcB;// qadd
                else
                    ALUResult = 32'b01111111111111111111111111111111;
            4'b1111:
                if (~qflag)
                    ALUResult = SrcA + ~SrcB + 1;// qsub
                else
                    ALUResult = ~(32'b01111111111111111111111111111111)+1 ; 
            //4'b0111: ALUResult = SrcA ^ SrcB;
            //4'b0111: ALUResult = SrcA ^ SrcB;
            //4'b0111: ALUResult = SrcA ^ SrcB;
            //4'b0111: ALUResult = SrcA ^ SrcB;
           
        endcase
    end

assign neg = ALUResult[31];
assign zero = (ALUResult == 32'b0);
assign carry = (ALUControl[1] == 1'b0) & sum[32];
assign overflow = (ALUControl[1] ==1'b0) & ~(SrcA[31] ^ SrcB[31] ^ ALUControl[0]) & (SrcA[31] ^ sum[31]);
assign qflag = (SrcA[31] == 0 & SrcB [31] == 0 & ALUResult[31] == 1) | (SrcA[31] == 1 & SrcB [31] == 1 & ALUResult[31] == 0);




assign ALUFlags = {neg, zero, carry, overflow};
endmodule