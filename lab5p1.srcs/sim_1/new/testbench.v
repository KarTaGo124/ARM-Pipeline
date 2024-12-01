`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 11:21:08 AM
// Design Name: 
// Module Name: testbench
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

module testbench;
	reg clk;
	reg reset;
	wire [31:0] WriteDataM;
	wire [31:0] DataAdr;
	wire MemWrite;
	wire sw;
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteDataM(WriteDataM),
		.DataAdr(DataAdr),
		.MemWrite(MemWrite),
		.sw(sw)
	);
	initial begin
		reset <= 1;
		#(22)
			;
		reset <= 0;
	end
	always begin
		clk <= 1;
		#(5)
			;
		clk <= 0;
		#(5)
			;
	end
	always @(negedge clk)
		if (MemWrite)
			if ((DataAdr === 100) & (WriteDataM === 7)) begin
				$display("Simulation succeeded");

			end
			else if (DataAdr !== 96) begin
				$display("Simulation failed");

			end
endmodule
