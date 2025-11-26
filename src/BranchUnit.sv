module BranchUnit (
    input logic signed [31:0] RURs1, RURs2, // Operandos a comparar
    input logic [4:0] BrOp,                 // Operación de salto (incluye Funct3 y flags)

    output logic NextPCSrc // 1 si se debe saltar, 0 si sigue secuencial
);

    logic BranchTaken; // Señal interna: ¿Se cumple la condición del Branch?
    
    // Evalúa la condición basada en Funct3 (BrOp[2:0])
    always @* begin
        BranchTaken = 1'b0;
        
        case (BrOp[2:0]) 
            3'b000: BranchTaken = (RURs1 == RURs2); // BEQ: Iguales
            3'b001: BranchTaken = (RURs1 != RURs2); // BNE: Diferentes
            3'b100: BranchTaken = (RURs1 < RURs2);  // BLT: Menor que (signo)
            3'b101: BranchTaken = (RURs1 >= RURs2); // BGE: Mayor o igual (signo)
            3'b110: BranchTaken = ($unsigned(RURs1) < $unsigned(RURs2));  // BLTU (Unsigned)
            3'b111: BranchTaken = ($unsigned(RURs1) >= $unsigned(RURs2)); // BGEU (Unsigned)
            default: BranchTaken = 1'b0;
        endcase
    end
    
    // Determina si se toma el salto:
    // BrOp[4] = 1 -> Salto incondicional (JAL, JALR)
    // BrOp[3] = 1 -> Instrucción Branch (verifica condición BranchTaken)
    assign NextPCSrc = BrOp[4] | (BrOp[3] & BranchTaken);
    
endmodule