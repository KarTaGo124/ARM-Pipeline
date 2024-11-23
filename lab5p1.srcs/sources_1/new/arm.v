`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:25:08 AM
// Design Name: 
// Module Name: arm
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


module arm (
	clk,
	reset,
	PC,
	Instr,
	MemWrite,
	ALUResult,
	WriteData,
	ReadData,
);
	input wire clk;
	input wire reset;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire MemWrite;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	wire [3:0] ALUFlags;
	wire RegWrite;
	wire ALUSrc;
	wire MemtoReg;
	wire PCSrc;
	wire [1:0] RegSrc;
	wire [1:0] ImmSrc;
	wire [1:0] ALUControl;
	
	//Wires del hazard
	wire [31:0] RA1E;
	wire [31:0] RA2E;
	wire [3:0] WA3M;
	wire [3:0] WA3W;
	wire RegWriteM; //controller
	wire RegWriteW; //controller
	wire [3:0] WA3E: //hazard
	wire [3:0] RA1D;//hazard
	wire [3:0] RA2D; //hazard
	wire MemtoRegE; // controller

	wire ForwardAE;
	wire ForwardBE;
	wire StallF;
	wire StallD;
	wire FlushE;

	wire BranchTakenE;
	controller c(
		.clk(clk),
		.reset(reset),
		.Instr(Instr[31:12]),
		.ALUFlags(ALUFlags),
		.RegSrcD(RegSrc),
		.RegWriteW(RegWrite),
		.ImmSrcD(ImmSrc),
		.ALUSrcE(ALUSrc),
		.ALUControlE(ALUControl),
		.MemWriteM(MemWrite),
		.MemtoRegW(MemtoReg),
		.PCSrcW(PCSrc),
		.BranchTakenE(BranchTakenE), //hazard---
		.RegWriteM_hazard(RegWriteM),
		.RegWriteW_hazard(RegWriteW),
		.MemtoRegE_hazard(MemtoRegE)
	);
	datapath dp(
		.clk(clk),
		.reset(reset),
		.RegSrcD(RegSrc),
		.RegWriteW(RegWrite),
		.ImmSrcD(ImmSrc),
		.ALUSrcE(ALUSrc),
		.ALUControlE(ALUControl),
		.MemtoRegW(MemtoReg),
		.PCSrcW(PCSrc),
		.ALUFlags(ALUFlags),
		.PCF(PC),
		.InstrF(Instr), // ahora entra el InstrF
		.WriteDataM(WriteData),
		.ReadDataM(ReadData),
		.BranchTakenE(BranchTakenE),
		.ALUResultM(ALUResult), //hazard--
		.RA1E_hazard(RA1E),
	    .RA2E_hazard(RA2E),
        .WA3M_hazard(WA3M),
        .WA3W_hazard(WA3W),
		.WA3E_hazard(WA3E),
		.RA1D_hazard(RA1D),
		.RA2D_hazard(RA2D),
		
		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE),
		.StallF(StallF),
		.StallD(StallD),
		.FlushE(FlushE)
	);

	hazard hz(
		.RA1E(RA1E),
		.RA2E(RA2E),
		.WA3M(WA3M),
		.WA3W(WA3W),
		.RegWriteM(RegWriteM),
		.RegWriteW(RegWriteW),
		.WA3E(WA3E),
		.RA1D(RA1D),
		.RA2D(RA2D),
		.MemtoRegE(MemtoRegE),

		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE),
		.StallF(StallF),
		.StallD(StallD),
		.FlushE(FlushE)
	)

endmodule