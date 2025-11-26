module Mux3 #(parameter WIDTH = 32) (
    input  logic [1:0]        sel, // Selector de 2 bits
    input  logic [WIDTH-1:0]  a,   // Entrada 00
    input  logic [WIDTH-1:0]  b,   // Entrada 01
    input  logic [WIDTH-1:0]  c,   // Entrada 10
    output logic [WIDTH-1:0]  y    // Salida
);
    always_comb begin
        case (sel)
            2'b00: y = a; // Selecciona A
            2'b01: y = b; // Selecciona B
            2'b10: y = c; // Selecciona C
            default: y = a; // Default seguro
        endcase
    end
endmodule