module InstructionMemory (
    input logic [31:0] Address_PC,

    output logic [31:0] Instruction
);

    // Declaración del Banco de Memoria (Instrucciones)
    // Se define un tamaño de 1024 palabras (4 KB de memoria de instrucciones)
    localparam MEM_SIZE = 1024; //por que 1024 y no mas o menos???
    logic [31:0] mem [MEM_SIZE-1:0];

    initial begin
        $readmemh("program.hex", mem);
    end

    // Lógica Combinacional de Lectura
    // Las instrucciones son de 32 bits, por lo que las direcciones son múltiplos de 4.
    // Usamos Address_PC[31:2] para indexar la memoria de palabras (Word Addressing).
    assign Instruction = mem[Address_PC[31:2]];
endmodule