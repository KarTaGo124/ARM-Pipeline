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
	BranchTakenE,
	// hazard
	RegWriteM_hazard,
	RegWriteW_hazard,
	MemtoRegE_hazard,
	PCSrcD_hazard,
	PCSrcE_hazard,
	PCSrcM_hazard,
	PCSrcW_hazard,
	FlushE,
	ALUFlags_carry,
	//BranchPred
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;
	wire NoWrite;
    output wire [3:0] ALUFlags_carry; // para la instrucci?n con carry
	// decode 
	wire PCSD; // pre cond logic output
	wire RegWD; // pre cond logic
	wire MemWD; // pre cond logic
	wire MemtoRegD; // salida de control unit
	wire [3:0] ALUControlD; // salida de control unit
	wire BranchD; // salida de control unit
	wire ALUSrcD;  // salida de control unit
	wire [1:0] FlagWD; // pre cond logic
	wire [3:0] NextFlags; 

	wire [17:0] ff_control_1_in; //para el primer flip flop
	wire [17:0] ff_control_1_out;

	output wire [1:0] ImmSrcD;
	output wire [1:0] RegSrcD;

	// execute
	wire PCSE; //Output
	wire RegWE;
	wire MemWE;

	input wire FlushE;

	wire PCSrcE;
	wire RegWriteE;
	wire MemWriteE;
	
	wire MemtoRegE;
	output wire [3:0] ALUControlE;
	wire BranchE;
	output wire ALUSrcE;
	wire [1:0] FlagWE;
	wire [3:0] CondE;
	wire [3:0] FlagsE;
	output wire BranchTakenE; //BranchTakenE deberia pasar a ser input del predictor
	//output wire BranchPred; //BranchPred deberia pasar a ser output del predictor


	// cond logic
	input wire [3:0] ALUFlags;

	//wires del segundo ff
	wire [3:0] ff_control_2_in;
	wire [3:0] ff_control_2_out;
   
    // memory
	wire PCSrcM; //Output
	wire RegWriteM;
	wire MemtoRegM;
	output wire MemWriteM; 

	//wires del tercer ff
	wire [2:0] ff_control_3_in;
	wire [2:0] ff_control_3_out;

	// write
    output wire PCSrcW; //Output
	output wire RegWriteW;
	output wire MemtoRegW;
	 
   //HAZARD
    output wire RegWriteM_hazard;
	output wire RegWriteW_hazard;
	output wire MemtoRegE_hazard;
	output wire PCSrcD_hazard;
	output wire PCSrcE_hazard;
	output wire PCSrcM_hazard;
	output wire PCSrcW_hazard;

	

	assign ff_control_1_in = {PCSD, RegWD, MemtoRegD, MemWD, ALUControlD, BranchD, ALUSrcD, FlagWD, Instr[31:28], NextFlags};

	flopr #(18) ff_control_1(
		.clk(clk),
		.reset(BranchTakenE),
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
		.ALUSrcD(ALUSrcD),								
		.FlagWD(FlagWD),
		.ImmSrcD(ImmSrcD),
		.RegSrcD(RegSrcD),
		.Branch(BranchD),
		.NoWrite(NoWrite)
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
		.BranchTakenE(BranchTakenE),
		.NoWrite(NoWrite)
	);
	assign ALUFlags_carry= NextFlags;//para el carry
	  
    assign ff_control_2_in = {PCSrcE, RegWriteE, MemtoRegE, MemWriteE};
    
    assign MemtoRegE_hazard = MemtoRegE;

	flopr #(4) ff_control_2(
	   .clk(clk),
	   .reset(reset),
	   .d(ff_control_2_in),
	   .q(ff_control_2_out)   
	);
	
    assign {PCSrcM, RegWriteM, MemtoRegM, MemWriteM} = ff_control_2_out;

	assign RegWriteM_hazard = RegWriteM;
	
	assign ff_control_3_in = {PCSrcM, RegWriteM, MemtoRegM};

	flopr #(3) ff_control_3(
	   .clk(clk),
	   .reset(reset),
	   .d(ff_control_3_in),
	   .q(ff_control_3_out)
	   )
	;
	assign {PCSrcW, RegWriteW, MemtoRegW} = ff_control_3_out;
	
	assign RegWriteW_hazard = RegWriteW;

	assign PCSrcD_hazard = PCSD;
	assign PCSrcE_hazard = PCSE;
	assign PCSrcM_hazard = PCSrcM;
	assign PCSrcW_hazard = PCSrcW;
	
	BranchPredictor bp(
		.actualyTaken(BranchTakenE),
		.clk(clk),
		.reset(reset),
		.predictTaken(BranchPred)
	);


endmodule