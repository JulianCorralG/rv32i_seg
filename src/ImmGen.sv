module ImmGen (
    input logic [31:7] Instr, // Parte relevante de la instrucción (bits 31 a 7)
    input logic [2:0] ImmSrc, // Selector de tipo de inmediato

    output logic [31:0] ImmExt // Inmediato extendido a 32 bits
);

    always_comb begin
        case (ImmSrc)
            // I-Type (ADDI, LW, JALR): Copia bit 31 (signo) 20 veces, concatena bits [31:20]
            3'b000: ImmExt = {{20{Instr[31]}}, Instr[31:20]};

            // S-Type (SW): Combina bits [31:25] y [11:7]
            3'b001: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};

            // B-Type (Branches): Reordena bits para formar el offset del salto
            3'b010: ImmExt = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            
            // J-Type (JAL): Reordena bits para saltos largos
            3'b011: ImmExt = {{12{Instr[31]}}, Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0};

            // U-Type (LUI, AUIPC): Carga inmediato en parte alta (bits 12-31)
            3'b100: ImmExt = {Instr[31:12], 12'b0};

            default: ImmExt = 32'b0;
        endcase
    end
    
endmodule