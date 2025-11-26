module PC (
    input logic clk, reset,       // Reloj y Reset
    input logic [31:0] NextPC,    // Siguiente dirección a la que saltar

    output logic [31:0] PCOutput  // Dirección actual
);

    // Registro interno para almacenar el PC
    logic [31:0] current_PC;

    // La salida es el valor almacenado
    assign PCOutput = current_PC;

    // Actualización síncrona en flanco de subida del reloj
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_PC <= 32'h00000000; // Reset asíncrono a 0
        else
            current_PC <= NextPC;       // Carga nuevo valor
    end
    
endmodule