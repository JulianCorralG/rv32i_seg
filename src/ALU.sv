module ALU (
    input logic signed [31:0] A,      // Operando A (con signo)
    input logic signed [31:0] B,      // Operando B (con signo)
    input logic [3:0] ALUOp,          // Código de operación de la ALU

    output logic signed [31:0] ALURes = 0 // Resultado de la operación
);

    always @* begin
        case (ALUOp)
            4'b0000: ALURes = A + B;       // Suma
            4'b1000: ALURes = A - B;       // Resta
            4'b0001: ALURes = A << B;      // Desplazamiento lógico izquierda
            4'b0010: ALURes = A < B;       // Set Less Than (Signed)
            4'b0011: ALURes = $unsigned(A) < $unsigned(B); // Set Less Than (Unsigned)
            4'b0100: ALURes = A ^ B;       // XOR bit a bit
            4'b0101: ALURes = A >> B;      // Desplazamiento lógico derecha
            4'b1101: ALURes = A >>> B;     // Desplazamiento aritmético derecha
            4'b0110: ALURes = A | B;       // OR bit a bit
            4'b0111: ALURes = A & B;       // AND bit a bit
            4'b1001: ALURes = B;           // Passthrough B (LUI)
            default: ALURes = 0;           // Default seguro
        endcase
    end
    
endmodule