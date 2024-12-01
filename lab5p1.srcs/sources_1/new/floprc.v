`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2024 20:14:16
// Design Name: 
// Module Name: floprc
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


module floprc  (
    clk,
    reset,
    clear,
    d,
    q
);
    parameter WIDTH = 8;
    input wire clk;
    input wire reset;
    input wire clear;
    input wire [WIDTH - 1:0] d;
    output reg [WIDTH - 1:0] q;
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0;
        else if (clear)
            q <= 0;
        else
            q <= d;
    end
endmodule
