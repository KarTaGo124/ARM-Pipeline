`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:26:15 AM
// Design Name: 
// Module Name: condlogic
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


module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	RegW,
	MemW,
	PCSrc,
	RegWrite,
	MemWrite,
	FlagsE,
	BranchE,
	NextFlags,
	BranchTakenE,
	NoWrite
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire RegW;
	input wire MemW;
	input wire BranchE;
	input wire [3:0] FlagsE;
	input wire NoWrite;
	output wire PCSrc;
	output wire RegWrite;
	output wire MemWrite;
	output wire [3:0] NextFlags;
	output wire BranchTakenE;
	wire [1:0] FlagWrite;

	wire CondEx;
	flopenr #(2) flagreg1(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[1]),
		.d(ALUFlags[3:2]),
		.q(NextFlags[3:2])
	);
	flopenr #(2) flagreg0(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[0]),
		.d(ALUFlags[1:0]),
		.q(NextFlags[1:0])
	);
	condcheck cc(
		.Cond(Cond),
		.Flags(NextFlags),
		.CondEx(CondEx)
	);
	assign FlagWrite = FlagW & {2 {CondEx}};
	assign RegWrite = RegW & CondEx & ~NoWrite;
	assign MemWrite = MemW & CondEx;
	assign PCSrc = PCS & CondEx;
	assign BranchTakenE = BranchE & CondEx;
	
endmodule
