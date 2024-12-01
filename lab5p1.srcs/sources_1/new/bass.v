`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2024 22:08:06
// Design Name: 
// Module Name: bass
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


module bass(
input wire clk,
input wire reset,
input wire  sw,
output wire [6:0] seg0
    );
    wire [31:0] pcf;
    top funca( 
    .clk(clk),
    .reset(reset),
    .sw(sw),
    .pcf(pcf)
    );
    wire [15:0] pcf_last_16 = pcf[15:0];
    // Convertimos esos 16 bits en 4 dígitos hexadecimales
    wire [3:0] hex_digit0 = pcf_last_16[3:0];   // Primer dígito (menos significativo)
    wire [3:0] hex_digit1 = pcf_last_16[7:4];   // Segundo dígito
    wire [3:0] hex_digit2 = pcf_last_16[11:8];  // Tercer dígito
    wire [3:0] hex_digit3 = pcf_last_16[15:12]; // Cuarto dígito (más significativo)
    display7seg bcd_to_7seg_inst0 (
        .bcd(hex_digit0),   // BCD para el primer dígito
        .seg(seg0)           // Salida para el primer display
    );
endmodule
