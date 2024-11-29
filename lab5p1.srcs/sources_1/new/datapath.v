`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:27:41 AM
// Design Name: 
// Module Name: datapath
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


module datapath (
	clk,
	reset,
	RegSrcD,
	RegWriteW,
	ImmSrcD,
	ALUSrcE,
	ALUControlE,
	MemtoRegW,
	PCSrcW,
	ALUFlags,
	PCF,
	InstrF,
	WriteDataM,
	ReadDataM,
	BranchPred,
	ALUResultM,
	RA1D_hazard,
	RA2D_hazard,
	RA1E_hazard,
	RA2E_hazard,
	WA3E_hazard,
	WA3M_hazard,
	WA3W_hazard,
	ForwardAE,
	ForwardBE,
	StallF,
	StallD,
	FlushD,
	FlushE,
	ALUFlags_carry // para el carry
);
	// Principal Signals
	input wire clk;
	input wire reset;
    input wire [3:0]ALUFlags_carry; //para el carry
    
    // Fetch Signals
	wire [31:0] PCNext; // Signal that enter to FF PC and output of the Mux
	output wire [31:0] PCF; // PC that enter in Imem module and adder module
	wire [31:0] PCMuxResult; // Result of the Mux between PCPlus4F-PCPlus8D and ResultW
	wire [31:0] PCPlus4F;
	input wire BranchPred; // Signal that comes from the controller TODO Change to BranchPred
	input wire [31:0] InstrF; // Before FF

	// Decode Signals
	input wire [1:0] RegSrcD; // Selector Muxes before RegFile
	input wire [1:0] ImmSrcD; // Selector Extend Module

	wire [3:0] RA1D;
	wire [3:0] RA2D;

	wire [31:0] InstrD; // After FF
	
	wire [31:0] SrcAD;
	wire [31:0] WriteDataD;
	wire [31:0] ExtImmD;

	// Execute Signals
	input wire ALUSrcE; // Selector Mux before ALU
	input wire [3:0] ALUControlE; // Selector ALU Module

	output wire [3:0] ALUFlags;
	wire [31:0] ALUResultE;

	wire [31:0] RA1E; //para el mux3
	wire [31:0] RA2E; // para el otro mux3
	wire [31:0] ExtImmE;
	wire [3:0] WA3E;

	wire [31:0] SrcAE;
	wire [31:0] WriteDataE;
	wire [31:0] SrcBE;


	// Memory Signals
	wire [31:0] ALUOutM;
	output wire [31:0] WriteDataM;
	wire [3:0] WA3M;
	output wire [31:0] ReadDataM;
	
	output wire [31:0] ALUResultM;


	// Writeback Signals
	input wire RegWriteW; // Enable RegFile
	input wire MemtoRegW; // Selector Mux before ResultW
	input wire PCSrcW; // Selector Mux between PCPlus4F-PCPlus8D or ResultW

	wire [31:0] ReadDataW;
	wire [31:0] ALUOutW;
	wire [3:0] WA3W;

	wire [31:0] ResultW;
	
	// Concatenated Signals for FFs
	wire [99:0] ff_DE_Dp_in;
	wire [99:0] ff_DE_Dp_out;

	wire [67:0] ff_EM_Dp_in;
	wire [67:0] ff_EM_Dp_out;

	wire [67:0] ff_MW_Dp_in;
	wire [67:0] ff_MW_Dp_out;

	
	//se�ales de hazard para los mux3
	output wire [3:0] RA1D_hazard;
	output wire [3:0] RA2D_hazard;
	output wire [31:0] RA1E_hazard;
	output wire [31:0] RA2E_hazard;
	output wire [3:0] WA3E_hazard;
	output wire [3:0] WA3M_hazard;
	output wire [3:0] WA3W_hazard;

	//se�ales de hazard para los flip flops
	input wire StallF;
	input wire StallD;
	input wire FlushD;
	input wire FlushE;
	input wire [1:0] ForwardBE;
	input wire [1:0] ForwardAE;
    
	wire negclk; //A�adido del clock negado
    assign negclk = ~clk;

	mux2 #(32) pcmux1(
		.d0(PCPlus4F),
		.d1(ResultW),
		.s(PCSrcW),
		.y(PCMuxResult)
	);	

	//branch taken E
	mux2 #(32) pcmux2(
		.d0(PCMuxResult),
		.d1(ALUResultE),
		.s(BranchPred),
		.y(PCNext)
	);	
	
	flopenr #(32) pcimem(
	   .clk(clk),
	   .reset(reset),
	   .en(~StallF), 
	   .d(PCNext),
	   .q(PCF)
	   )
	;

	adder #(32) pcadd1(
		.a(PCF),
		.b(32'b100),
		.y(PCPlus4F)
	);

	flopenr #(32) regfd(
	   .clk(clk),
	   .reset(FlushD), //TODO Change to ~BranchPred
	   .en(~StallD),
	   .d(InstrF),  
	   .q(InstrD)
	   )
	;

	mux2 #(4) ra1mux(
		.d0(InstrD[19:16]),
		.d1(4'b1111),
		.s(RegSrcD[0]),
		.y(RA1D)
	);

	assign RA1D_hazard = RA1D;

	mux2 #(4) ra2mux(
		.d0(InstrD[3:0]),
		.d1(InstrD[15:12]),
		.s(RegSrcD[1]),
		.y(RA2D)
	);

	assign RA2D_hazard = RA2D;

	regfile rf(
		.clk(negclk),
		.we3(RegWriteW),
		.ra1(RA1D),
		.ra2(RA2D),
		.wa3(WA3W),
		.wd3(ResultW),
		.r15(PCPlus4F),
		.rd1(SrcAD), 
		.rd2(WriteDataD)
	);

	extend ext(
		.Instr(InstrD[23:0]),
		.ImmSrc(ImmSrcD),
		.ExtImm(ExtImmD)
	);

	assign ff_DE_Dp_in = {SrcAD, WriteDataD, InstrD[15:12], ExtImmD};

	flopr #(100) ff_DE_Dp(
		.clk(clk),
		.reset(FlushE), //TODO Change to ~BranchPred
		.d(ff_DE_Dp_in),
		.q(ff_DE_Dp_out)
	);

	assign {RA1E, RA2E, WA3E, ExtImmE} = ff_DE_Dp_out;

	assign WA3E_hazard = WA3E;
	
	mux3 #(32) E1(
		.d0(RA1E),
		.d1(ResultW),
		.d2(ALUOutM),
		.s(ForwardAE), 
		.y(SrcAE) 
	);

	assign RA1E_hazard = RA1E;
	    
	mux3 #(32) E2(
		.d0(RA2E),
		.d1(ResultW),
		.d2(ALUOutM),
		.s(ForwardBE), 
		.y(WriteDataE)
	);

	assign RA2E_hazard = RA2E;

	mux2 #(32) srcbmux(
		.d0(WriteDataE),
		.d1(ExtImmE),
		.s(ALUSrcE),
		.y(SrcBE) 
	);

	alu alu(
		.SrcA(SrcAE),  
		.SrcB(SrcBE), 
		.ALUControl(ALUControlE),
		.ALUResult(ALUResultE),
		.ALUFlags(ALUFlags),
		.ALUFlags_carry(ALUFlags_carry)
	);

	assign ff_EM_Dp_in = {ALUResultE, WriteDataE, WA3E};

	flopr #(68) ff_EM_Dp(
		.clk(clk),
		.reset(reset),
		.d(ff_EM_Dp_in),
		.q(ff_EM_Dp_out)		
	);
	
	assign {ALUOutM, WriteDataM, WA3M} = ff_EM_Dp_out;

	assign WA3M_hazard = WA3M; // HAZARD

	assign ff_MW_Dp_in = {ReadDataM, ALUOutM, WA3M};

	flopr #(68) ff_MW_Dp(
		.clk(clk),
		.reset(reset),
		.d(ff_MW_Dp_in),
		.q(ff_MW_Dp_out)
	);
	assign {ReadDataW, ALUOutW, WA3W} = ff_MW_Dp_out;

	assign WA3W_hazard = WA3W;
	
	mux2 #(32) resmux(
		.d0(ALUOutW),
		.d1(ReadDataW), 
		.s(MemtoRegW), 
		.y(ResultW) 
	);
	
	assign ALUResultM = ALUOutM;
endmodule