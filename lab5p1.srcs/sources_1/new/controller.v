`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:25:56 AM
// Design Name: 
// Module Name: controller
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

module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	RegSrcD,
	RegWriteW,
	ImmSrcD,
	ALUSrcE,
	ALUControlE,
	MemWriteM,
	MemtoRegW,
	PCSrcW,
	BranchTakenE
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;

	// decode 
	wire PCSD; // pre cond logic
	wire RegWD; // pre cond logic
	wire MemWD; // pre cond logic
	wire MemtoRegD; // salida de control unit
	wire [1:0] ALUControlD; // salida de control unit
	wire BranchD; // salida de control unit
	wire ALUSrcD;  // salida de control unit
	wire [1:0] FlagWD; // pre cond logic
	wire [3:0] NextFlags; // TODO Extraer de conlogid para mandarlo al flip flop

	wire [17:0] ff_control_1_in; //para el primer flip flop
	wire [17:0] ff_control_1_out;

	output wire [1:0] ImmSrcD;
	output wire [1:0] RegSrcD;

	// execute
	wire PCSE;
	wire RegWE;
	wire MemWE;

	wire PCSrcE;
	wire RegWriteE;
	wire MemWriteE;
	
	wire MemtoRegE;
	output wire [1:0] ALUControlE;
	wire BranchE;
	output wire ALUSrcE;
	wire [1:0] FlagWE;
	wire [3:0] CondE;
	wire [3:0] FlagsE;
	output wire BranchTakenE;

	// cond logic
	input wire [3:0] ALUFlags;

	//wires del segundo ff
	wire [3:0] ff_control_2_in;
	wire [3:0] ff_control_2_out;
   
    // memory
	wire PCSrcM;
	wire RegWriteM;
	wire MemtoRegM;
	output wire MemWriteM; 

	//wires del tercer ff
	wire [2:0] ff_control_3_in;
	wire [2:0] ff_control_3_out;

	// write
    output wire PCSrcW;
	output wire RegWriteW;
	output wire MemtoRegW;
	 
	assign ff_control_1_in = {PCSD, RegWD, MemtoRegD, MemWD, ALUControlD, BranchD, ALUSrcD, FlagWD, Instr[31:28], NextFlags};

	flopenr #(18) ff_control_1(
		.clk(clk),
		.reset(reset),
		.en(1'b1), //TODO: Viene del Hazzard (StallF)
		.d(ff_control_1_in),
	   .q(ff_control_1_out)
	);

	assign {PCSE, RegWE, MemtoRegE, MemWE, ALUControlE, BranchE, ALUSrcE, FlagWE, CondE, FlagsE} = ff_control_1_out;	

	
	decode dec(
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.PCSD(PCSD),
		.RegWD(RegWD),
		.MemtoRegD(MemtoRegD),
		.MemWD(MemWD),
		.ALUControlD(ALUControlD),
		//TODO Implementar BranchD, que esta ya declarada internamente
		.ALUSrcD(ALUSrcD),								
		.FlagWD(FlagWD),
		.ImmSrcD(ImmSrcD),
		.RegSrcD(RegSrcD),
		.Branch(BranchD)
	);
	
	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(CondE),
		.ALUFlags(ALUFlags),
		.FlagW(FlagWE),
		.NextFlags(NextFlags), //son los flags que salen 
		.PCS(PCSE), 
		.RegW(RegWE),
		.MemW(MemWE),
		.PCSrc(PCSrcE),
		.RegWrite(RegWriteE),
		.MemWrite(MemWriteE),
		.FlagsE(FlagsE),
		.BranchE(BranchE),
		.BranchTakenE(BranchTakenE)
	);
	
    assign ff_control_2_in = {PCSrcE, RegWriteE, MemtoRegE, MemWriteE};

	flopr #(4) ff_control_2(
	   .clk(clk),
	   .reset(reset),
	   .d(ff_control_2_in),
	   .q(ff_control_2_out)   
	);
	
    assign {PCSrcM, RegWriteM, MemtoRegM, MemWriteM} = ff_control_2_out;
	
	assign ff_control_3_in = {PCSrcM, RegWriteM, MemtoRegM};

	flopr #(3) ff_control_3(
	   .clk(clk),
	   .reset(reset),
	   .d(ff_control_3_in),
	   .q(ff_control_3_out)
	   )
	;
	assign {PCSrcW, RegWriteW, MemtoRegW} = ff_control_3_out;
	
endmodule