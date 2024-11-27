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
	ReadData
);
	// Inputs and outputs
	input wire clk;
	input wire reset;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire MemWrite;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;

	// Internal signals
	wire [3:0] ALUFlags;
	wire RegWrite;
	wire ALUSrc;
	wire MemtoReg;
	wire PCSrc;
	wire [1:0] RegSrc;
	wire [1:0] ImmSrc;
	wire [1:0] ALUControl;

	// Hazard-related wires
	wire [31:0] RA1E;
	wire [31:0] RA2E;
	wire [3:0] WA3M;
	wire [3:0] WA3W;
	wire RegWriteM; //Controller
	wire RegWriteW; //Controller
	wire [3:0] WA3E; //Hazard
	wire [3:0] RA1D; //Hazard
	wire [3:0] RA2D; //Hazard
	wire MemtoRegE; //Controller
	wire PCSrcD_h; //Controller
	wire PCSrcE_h; //Controller
	wire PCSrcM_h; //Controller
	wire PCSrcW_h; //Controller

	wire [1:0] ForwardAE;
	wire [1:0] ForwardBE;

	wire StallF;
	wire StallD;
	wire FlushE;
	wire FlushD;

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
		.MemtoRegE_hazard(MemtoRegE),
		.PCSrcD_hazard(PCSrcD_h),
		.PCSrcE_hazard(PCSrcE_h),
		.PCSrcM_hazard(PCSrcM_h),
		.PCSrcW_hazard(PCSrcW_h)
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
		.FlushD(FlushD),
		.FlushE(FlushE)
	);

	hazard hz(
		.RA1E(RA1E), //Input Datapath
		.RA2E(RA2E), //Input Datapath
		.WA3M(WA3M), //Input Datapath
		.WA3W(WA3W), //Input Datapath
		.RA1D(RA1D), //Input Datapath
		.WA3E(WA3E), //Input Datapath
		.RA2D(RA2D), //Input Datapath
		
		.RegWriteM(RegWriteM), //Input Controller
		.RegWriteW(RegWriteW), //Input Controller
		.PCSrcD(PCSrcD_h), //Input Controller
		.PCSrcE(PCSrcE_h), //Input Controller
		.PCSrcM(PCSrcM_h), //Input Controller
		.PCSrcW(PCSrcW_h), //Input Controller
		.BranchTakenE(BranchTakenE), //Input Controller
		.MemtoRegE(MemtoRegE), //Input Controller

		.StallD(StallD), 
		.StallF(StallF),
		.FlushD(FlushD),
		.FlushE(FlushE),
		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE)
	);

endmodule