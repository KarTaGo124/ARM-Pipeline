`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.11.2024 12:33:12
// Design Name: 
// Module Name: BranchPredictor
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


module BranchPredictor(
    actualyTaken,
    clk,
    reset,
    predictTaken
    );
    input wire actualyTaken;
    input wire clk;
    input wire reset;

    output wire predictTaken;

    reg [1:0] state;    
    reg [1:0] nextState;

    parameter [1:0] StronglyTaken = 2'b00;
    parameter [1:0] WeaklyTaken = 2'b01;
    parameter [1:0] WeaklyNotTaken = 2'b10;
    parameter [1:0] StronglyNotTaken = 2'b11;

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= StronglyTaken;
        else
            state <= nextState;
    end

    always @(*)
    begin
        case (state)
            StronglyTaken:
                if (actualyTaken)
                    nextState = StronglyTaken;
                else
                    nextState = WeaklyTaken;
            WeaklyTaken:
                if (actualyTaken)
                    nextState = StronglyTaken;
                else
                    nextState = StronglyNotTaken;
            StronglyNotTaken:
                if (actualyTaken)
                    nextState = WeaklyNotTaken;
                else
                    nextState = StronglyNotTaken;                    
            WeaklyNotTaken:
                if (actualyTaken)
                    nextState = StronglyTaken;
                else
                    nextState = StronglyNotTaken;
        endcase
    end

    assign predictTaken = (state == StronglyTaken) || (state == WeaklyTaken);

endmodule