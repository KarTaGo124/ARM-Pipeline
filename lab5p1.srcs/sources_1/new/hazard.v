`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2024 18:31:35
// Design Name: 
// Module Name: hazard
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


module hazard(
    RA1E,
    RA2E,
    WA3M,
    WA3W,
    RegWriteM,
    RegWriteW,
    WA3E,
    RA2D,
    RA1D,
    MemtoRegE,
    ForwardAE,
    ForwardBE,
    StallF,
    StallD,
    FlushE
);
    
    input wire RA1E;
    input wire RA2E;
    input wire WA3M;
    input wire WA3W;
    input wire RegWriteM;
    input wire RegWriteW;
    input wire WA3E;
    input wire RA2D;
    input wire RA1D;
    input wire MemtoRegE;

    output reg [1:0] ForwardAE;
    output reg [1:0] ForwardBE;
    output wire StallF;
    output wire StallD;
    output wire FlushE;

  // Forwarding Logic
    wire Match_1E_M = (RA1E == WA3M);
    wire Match_2E_M = (RA2E == WA3M);
    wire Match_1E_W = (RA1E == WA3W);
    wire Match_2E_W = (RA2E == WA3W);

    always @(*) begin
        // ForwardAE logic
        if (Match_1E_M && RegWriteM)
            ForwardAE = 2'b10;
        else if (Match_1E_W && RegWriteW)
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;

        // ForwardBE logic
        if (Match_2E_M && RegWriteM)
            ForwardBE = 2'b10;
        else if (Match_2E_W && RegWriteW)
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end


    // Stall Logic
    wire Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E);
    wire ldrstall = Match_12D_E && MemtoRegE;

    assign StallF = ldrstall;
    assign StallD = ldrstall;
    assign FlushE = ldrstall;

endmodule
