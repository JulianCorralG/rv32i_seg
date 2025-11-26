module Adder (
    input logic [31:0] PCOutput,    // Valor actual del PC

    output logic [31:0] AdderOutput // PC + 4
);

    // Sumador simple que incrementa el PC en 4 bytes (siguiente instrucción)
    assign AdderOutput = PCOutput + 32'd4;
    
endmodule