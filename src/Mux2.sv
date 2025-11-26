module Mux2 #(parameter WIDTH = 32) (
    input  logic              sel, // Selector: 0 -> a, 1 -> b
    input  logic [WIDTH-1:0] a,    // Entrada 0
    input  logic [WIDTH-1:0] b,    // Entrada 1
    output logic [WIDTH-1:0] y     // Salida
);
    // Lógica combinacional simple: si sel es 1, sale b, si no, sale a
    always_comb begin
        y = sel ? b : a;
    end
endmodule