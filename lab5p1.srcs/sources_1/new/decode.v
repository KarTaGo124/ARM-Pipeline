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
	Branch,
	NoWrite
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
	output reg [3:0] ALUControlD;
	output wire NoWrite;
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
				//logica
				4'b0000: ALUControlD = 4'b0010;//and
				4'b0001: ALUControlD = 4'b0111;//eor xor
				4'b1000: ALUControlD = 4'b0010;//tst // todo:gg
				4'b1001: ALUControlD = 4'b0111;//teq // todo:gg
				4'b1100: ALUControlD = 4'b0011;//orr
				4'b1110: ALUControlD = 4'b1011;//bic

				//operaciones
				4'b0010: ALUControlD = 4'b01;//sub
				4'b0110: ALUControlD = 4'b11;//sbc // todo:carry
				4'b0011: ALUControlD = 4'b11;//rsb
				4'b0111: ALUControlD = 4'b11;//rsc--- falta el orn y // todo:carry (bait)
				4'b0100: ALUControlD = 4'b00;//add				
				4'b0101: ALUControlD = 4'b11;//adc // todo:carry
				4'b1010: ALUControlD = 4'b11;//cmp
				4'b1011: ALUControlD = 4'b11;//cmn


				4'b1101: ALUControlD = 4'b11;//shift
				4'b1111: ALUControlD = 4'b11;//mvn

				default: ALUControlD = 4'bxx;
			endcase
			FlagWD[1] = Funct[0];
			FlagWD[0] = Funct[0] & ((ALUControlD[1]==0));
		end
		else begin
			ALUControlD = 4'b0000;
			FlagWD = 2'b00;
		end
	assign PCSD = ((Rd == 4'b1111) & RegWD) | Branch;
	assign NoWrite = Funct[0] & Funct[4];
endmodule
