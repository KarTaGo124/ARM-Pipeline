`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:28:25 AM
// Design Name: 
// Module Name: regfile
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


module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3,
	wd3,
	r15,
	rd1,
	rd2,
	Instr
);
	input wire clk;
	input wire we3;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] wa3;
	input wire [31:0] wd3;
	input wire [31:0] r15;
	input wire [31:0] Instr;//para el mov xd
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	reg [31:0] rf [14:0];
	wire op;//para el mvn
	wire cmd;//para el mvn
	assign op=Instr[27:26];
	assign  cmd= Instr[24:21];
	always @(posedge clk)
		if (we3)
			rf[wa3] <= wd3;//Instr[24:21]
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]); 
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule