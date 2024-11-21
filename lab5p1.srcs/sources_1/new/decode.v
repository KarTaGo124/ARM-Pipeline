`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:33:01 AM
// Design Name: 
// Module Name: decode
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


module decode (
	Op,
	Funct,
	Rd,
	FlagWD,
	PCSD,
	RegWD,
	MemWD,
	MemtoRegD,
	ALUSrcD,
	ImmSrcD,
	RegSrcD,
	ALUControlD,
	Branch
);
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagWD;
	output wire PCSD;
	output wire RegWD;
	output wire MemWD;
	output wire MemtoRegD;
	output wire ALUSrcD;
	output wire [1:0] ImmSrcD;
	output wire [1:0] RegSrcD;
	output reg [1:0] ALUControlD;
	reg [9:0] controls;
	output wire Branch;
	wire ALUOp;
	always @(*)
		casex (Op)
			2'b00:
				if (Funct[5])
					controls = 10'b0000101001;
				else
					controls = 10'b0000001001;
			2'b01:
				if (Funct[0])
					controls = 10'b0001111000;
				else
					controls = 10'b1001110100;
			2'b10: controls = 10'b0110100010;
			default: controls = 10'bxxxxxxxxxx;
		endcase
	assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWD, MemWD, Branch, ALUOp} = controls;
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: ALUControlD = 2'b00;
				4'b0010: ALUControlD = 2'b01;
				4'b0000: ALUControlD = 2'b10;
				4'b1100: ALUControlD = 2'b11;
				default: ALUControlD = 2'bxx;
			endcase
			FlagWD[1] = Funct[0];
			FlagWD[0] = Funct[0] & ((ALUControlD == 2'b00) | (ALUControlD == 2'b01));
		end
		else begin
			ALUControlD = 2'b00;
			FlagWD = 2'b00;
		end
	assign PCSD = ((Rd == 4'b1111) & RegWD) | Branch;
endmodule
