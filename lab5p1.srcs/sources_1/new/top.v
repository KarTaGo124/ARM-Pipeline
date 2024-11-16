`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:22:14 AM
// Design Name: 
// Module Name: top
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

module top (
	clk,
	reset,
	WriteData,
	DataAdr,
	MemWrite
);
	input wire clk;
	input wire reset;
	output wire [31:0] WriteDataM;
	output wire [31:0] DataAdr;
	output wire MemWrite;
	wire [31:0] PCF;
	wire [31:0] InstrF;
	wire [31:0] InstrD;
	wire [31:0] ReadDataM;
	arm arm(
		.clk(clk),
		.reset(reset),
		.PC(PCF),
		.Instr(InstrD),
		.MemWrite(MemWrite),
		.ALUResult(DataAdr),
		.WriteData(WriteDataM),
		.ReadData(ReadDataM)
	);
	imem imem(
		.a(PCF),
		.rd(InstrF)
	);
	
	flopenr #(32) regfd(
	   .clk(clk),
	   .reset(FlushD), //TODO: Viene del Hazzard (FlushD)
	   .e(~StallD), //TODO: Viene del Hazzard (StallD)
	   .d(InstrF),  
	   .q(InstrD)
	   )
	;
	dmem dmem(
		.clk(clk),
		.we(MemWrite),
		.a(DataAdr),
		.wd(WriteDataM),
		.rd(ReadDataM)
	);
endmodule