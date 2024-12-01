`timescale 1ns / 1ps


module display7seg(
    input wire [3:0] bcd,  // Entrada BCD de 4 bits
    output reg [6:0] seg   // Salida para el display de 7 segmentos
);

    always @(*) begin
        case (bcd)
            4'h0: seg = 7'b0111111;  // 0
            4'h1: seg = 7'b0000110;  // 1
            4'h2: seg = 7'b1011011;  // 2
            4'h3: seg = 7'b1001111;  // 3
            4'h4: seg = 7'b1100110;  // 4
            4'h5: seg = 7'b1101101;  // 5
            4'h6: seg = 7'b1111101;  // 6
            4'h7: seg = 7'b0000111;  // 7
            4'h8: seg = 7'b1111111;  // 8
            4'h9: seg = 7'b1101111;  // 9
            4'hA: seg = 7'b1110111;  // A
            4'hB: seg = 7'b1111100;  // b
            4'hC: seg = 7'b0111001;  // C
            4'hD: seg = 7'b1011110;  // d
            4'hE: seg = 7'b1111001;  // E
            4'hF: seg = 7'b1110001;  // F
            default: seg = 7'b0000000;  // Default case (apagado o error)
        endcase
    end

endmodule
