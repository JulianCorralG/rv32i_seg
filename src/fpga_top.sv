module fpga_top (
    input logic clk,      // Reloj de la placa (ej. 50MHz o 100MHz)
    input logic rst_n,    // Reset activo bajo (botón)
    output logic [15:0] LEDS // 16 LEDs para visualización
);

    logic reset;
    logic [31:0] WriteData;
    logic [31:0] DataAdr;

    // Invertir reset (activo alto para el procesador)
    assign reset = ~rst_n;

    // Instancia del procesador
    cpu_top processor (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr)
    );

    // Mapeo de salida a LEDs
    // Mostramos los 16 bits menos significativos del dato escrito
    assign LEDS = WriteData[15:0];

endmodule
