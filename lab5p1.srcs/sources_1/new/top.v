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
	WriteDataM,
	DataAdr,
	MemWrite
);
	input wire clk;
	input wire reset;
	output wire [31:0] WriteDataM;
	output wire [31:0] DataAdr;
	output wire MemWrite;
	wire [31:0] PCF;
	wire [31:0] Instr;
	wire [31:0] ReadDataM;
	arm arm(
		.clk(clk),
		.reset(reset),
		.PC(PCF),
		.Instr(Instr),
		.MemWrite(MemWrite),
		.ALUResult(DataAdr),
		.WriteData(WriteDataM),
		.ReadData(ReadDataM)
	);
	imem imem(
		.a(PCF),
		.rd(Instr)
	);
	
	dmem dmem(
		.clk(clk),
		.we(MemWrite),
		.a(DataAdr),
		.wd(WriteDataM),
		.rd(ReadDataM)
	);
endmodule