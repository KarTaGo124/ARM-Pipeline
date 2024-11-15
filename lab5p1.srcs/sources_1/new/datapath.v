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
	ALUResult,
	WriteData,
	ReadData
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
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [3:0] RA1;
	wire [3:0] RA2;
	
	    wire negclk; //Añadido del clock negado
    assign negclk = ~clk;
	
	mux2 #(32) pcmux( //TODO: Cambiar luego del controller
		.d0(PCPlus4),
		.d1(Result), //ResultW
		.s(PCSrc), //PCSrcW
		.y(PCNext)
	);	
	

		
	flopenr #(2) pcreg( //Cambia a tipo ER
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
		.we3(RegWrite),//TODO: Cambiar a RegWriteW 
		.ra1(RA1),
		.ra2(RA2),
		.wa3(Instr[15:12]), //TODO: Cambiar de Instr[15:12] a WA3W, que viene del reg de escritura, que viene del reg de memoria, que viene del reg de execute que viene del Inst[15:12
		.wd3(Result), //TODO: Cambiar a ResultW
		.r15(PCPlus4), //Cambia, ya no va con pc+8 directamente
		.rd1(SrcA), //TODO: Entrada regD-E
		.rd2(WriteData) //TODO: Entrada regD-E
	);
	mux2 #(32) resmux(
		.d0(ALUResult), //TODO: Cambiar a ALUOutW
		.d1(ReadData), //TODO: Cambiar a ReadDataW
		.s(MemtoReg), //TODO: Cambiar a MemtoRegW 
		.y(Result) //TODO: Cambiar a ResultW
	);
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm) //TODO: Pasar el Extend por el regD-E y sacarlo como ExtImmE
	);
	//TODO: Falta generar un mux31, que tome RD1(SrcA), el valor de AluResultM que se da del regE-M y de ResultW, deberia generar SrcAE
	//TODO: Falta generar un mux31, que tome R2(Writedata), el ResultW o el AluResultM, que se da del regE-M
	mux2 #(32) srcbmux(//TODO: Se cambia Write data por el mux que esta atras de esta linea, y con entrade del ExtendImmE del regD-E
		.d0(WriteData),
		.d1(ExtImm),
		.s(ALUSrc),
		.y(SrcB) //Cambiar a SrcBE
	);
	alu alu(//TODO: se cambia la entrada 
		SrcA,  //Toma SrcAE
		SrcB, //Toma SrcBE
		ALUControl, //Se toma AluControlE
		ALUResult, //La salida es AluResultE, que va al regE-M
		ALUFlags
	);
endmodule
