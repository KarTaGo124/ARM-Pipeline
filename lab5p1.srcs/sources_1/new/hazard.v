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
    PCSrcD,
    PCSrcE,
    PCSrcM,
    PCSrcW,
    BranchTakenE,
    MemtoRegE,    
    RA1D,
    WA3E, 
    RA2D,

    StallD,
    StallF,
    FlushD,
    FlushE,
    ForwardAE,
    ForwardBE
);
    input wire [31:0] RA1E; //Datapath
    input wire [31:0] RA2E; //Datapath
    input wire [3:0] WA3M; //Datapath
    input wire [3:0] WA3W; //Datapath
    input wire RegWriteM; //Controller
    input wire RegWriteW; //Controller

    input wire PCSrcD; //Controller 
    input wire PCSrcE; //Controller
    input wire PCSrcM; //Controller
    input wire PCSrcW; //Controller
    input wire BranchTakenE; //Controller
    input wire MemtoRegE; //Controller    

    input wire [3:0] RA1D; //Datapath
    input wire [3:0] WA3E; //Datapath
    input wire [3:0] RA2D; //Datapath

    output wire StallD;
    output wire StallF;
    output wire FlushD;
    output wire FlushE;
    output wire ForwardAE;
    output wire ForwardBE;

    wire Match_1E_M;
    wire Match_2E_M;
    wire Match_1E_W;
    wire Match_2E_W;

    wire ldrStallD;
    wire PCWrPendingF;
    wire Match_12D_E;

    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);

    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);

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


    assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;
    assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);

    assign ldrStallD = Match_12D_E & MemtoRegE;

    assign StallF = ldrStallD | PCWrPendingF;

    assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;

    assign FlushE = ldrStallD | BranchTakenE;

    assign StallD = ldrStallD;   

endmodule
