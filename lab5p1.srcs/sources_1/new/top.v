`timescale 1ns / 1ps


module top (

    input wire clk,
    input wire reset,
    input wire  sw,               // Entrada para el switch (simula el botón)
    output wire [31:0] WriteDataM,
    output wire [31:0] DataAdr,
    output wire MemWrite,
    output wire [31:0] pcf    // El PC será de 32 bits

    // Salidas para el display de 7 segmentos (por ejemplo, 4 displays de 7 segmentos)
);

    wire [31:0] PCF;  // PC de 32 bits
    wire [31:0] Instr;
    wire [31:0] ReadDataM;

    // Control para incrementar el PC
    reg [31:0] PC_reg;

    // Lógica para manejar el PC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Si hay reset, el PC se pone a cero
            PC_reg <= 32'h00000000;
        end else if (sw) begin
            // Si el switch está presionado, avanzamos el PC
            PC_reg <= PC_reg + 4;  // Aumentamos el PC en 4 (típico en arquitecturas RISC)
        end
    end

    // Asignamos el valor de PC_reg a la señal de salida pcf
    assign pcf = PC_reg;

    // Instanciamos la unidad "arm" para que use el PC actualizado
    arm arm (
        .clk(clk),
        .reset(reset),
        .PC(PCF),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteDataM),
        .ReadData(ReadDataM)
    );

    // Memoria de instrucciones (imem) que toma el valor del PC
    imem imem (
        .a(PCF),
        .rd(Instr)
    );

    // Asignamos el PCF (que en este caso es igual a PC_reg) a la señal de salida
    assign pcf = PC_reg;

    // Memoria de datos (dmem)
    dmem dmem (
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteDataM),
        .rd(ReadDataM)
    );

    // Extraemos los últimos 16 bits de pcf
   

endmodule
