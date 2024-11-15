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
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemtoReg,
	PCSrc,
	ALUFlags,
	PC,
	Instr,
	ALUResultE,
	WriteDataM,
	ReadDataM
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	input wire [1:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire [31:0] ALUResultE;
|
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] ExtImmD;
	wire [31:0] SrcAD;
	wire [31:0] SrcBE;
	wire [31:0] ResultW;
	wire [3:0] RA1;
	wire [3:0] RA2;

	wire [99:0] ff_DE_Dp_in;
	wire [99:0] ff_DE_Dp_out;

	wire [67:0] ff_EM_Dp_in;
	wire [67:0] ff_EM_Dp_out;

	wire [67:0] ff_MW_Dp_in;
	wire [67:0] ff_MW_Dp_out;

	wire [31:0] ExtImmE;
	wire [31:0] SrcAE;
	wire [31:0] SrcAEM; //para el mux3
	wire [31:0] WriteDataEM;
	wire [31:0] WriteDataE;
	wire [3:0] WA3E;
	
	//señales de hazard para los mux3
	wire [1:0] ForwardBE;
	wire [1:0] ForwardAE;
    
	wire [31:0] ALUOutM;
	wire [31:0] WriteDataM;
	wire [3:0] WA3M;
	
	input wire [31:0] ReadDataM;

	wire negclk; //Añadido del clock negado
    assign negclk = ~clk;
	
	mux2 #(32) pcmux(
		.d0(PCPlus4),
		.d1(ResultW),
		.s(PCSrcW)
		.y(PCNext)
	);	
	
	flopenr #(2) pcreg(
	   .clk(clk),
	   .reset(reset),
	   .e(en), //TODO: Viene del Hazzard (Stall)F
	   .d(PCNext),
	   .q(PC)
	   )
	;
	adder #(32) pcadd1(
		.a(PC),
		.b(32'b100),
		.y(PCPlus4)
	);

	mux2 #(4) ra1mux(
		.d0(Instr[19:16]),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);

	mux2 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);

	regfile rf(
		.clk(negclk),
		.we3(RegWriteW),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(WA3W),
		.wd3(ResultW),
		.r15(PCPlus4),
		.rd1(SrcAD), 
		.rd2(WriteDataD)
	);

	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImmD)
	);

	assign ff_DE_Dp_in = {SrcAD, WriteDataD, Inst[15:12], ExtImmD};

	flopr #(100) ff_DE_Dp(
		.clk(clk),
		.reset(reset),
		.d(ff_DE_Dp_in),
		.q(ff_DE_Dp_out)
	);

	assign {SrcAEM, WriteDataEM, WA3E, ExtImmE} = ff_DE_Dp_out;
	
	mux3 #(32) E1(
		.d0(SrcAEM)
		.d1(ResultW)
		.d2(ALUOutM)
		.s(ForwardAE)
		.y(SrcAE) 
	);
	    
	mux3 #(32) E2(
		.d0(WriteDataEM)
		.d1(ResultW)
		.d2(ALUOutM)
		.s(ForwardBE) // TODO: A 
		.y(WriteDataE)
		
	);
	mux2 #(32) srcbmux(
		.d0(WriteDataE),
		.d1(ExtImmE),
		.s(ALUSrc),
		.y(SrcBE) 
	);

	alu alu(
		SrcAE,  
		SrcBE, 
		ALUControlE,
		ALUResultE,
		ALUFlags
	);

	assign ff_EM_Dp_in = {AluResultE, WriteDataE, WA3E};

	flopr #(68) ff_EM_Dp(
		.clk(clk),
		.reset(reset),
		.d(ff_EM_Dp_in),
		.q(ff_EM_Dp_out)		
	);
	
	assign {ALUOutM, WriteDataM, WA3M} = ff_EM_Dp_out;

	assign ff_MW_Dp_in = {ReadDataM, ALUOutM, WA3M};

	flopr #(68) ff_MW_Dp(
		.clk(clk),
		.reset(reset),
		.d(ff_MW_Dp_in),
		.q(ff_MW_Dp_out),
	);
	assign {ReadDataW, ALUOutW, WA3W} = ff_MW_Dp_out;
	
	mux2 #(32) resmux(
		.d0(ALUOutW),
		.d1(ReadDataW), 
		.s(MemtoRegW), 
		.y(ResultW) 
	);
	
endmodule
