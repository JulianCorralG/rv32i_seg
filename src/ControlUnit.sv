module ControlUnit (
    input logic [6:0] OpCode, Funct7,
    input logic [2:0] Funct3,

    output logic RUWr, ALUASrc, ALUBSrc, DMWr,
    output logic [1:0] RUDataWrSrc,
    output logic [2:0] ImmSrc, DMCtrl,
    output logic [3:0] ALUOp,
    output logic [4:0] BrOp
);

    always_comb begin
        // Valores por defecto (seguro)
        RUWr = 1'b0;
        ALUOp = 4'b0000;
        ImmSrc = 3'b000;
        ALUASrc = 1'b0;
        ALUBSrc = 1'b0;
        DMWr = 1'b0;
        DMCtrl = 3'b000;
        BrOp = 5'b00000;   
        RUDataWrSrc = 2'b00;   

        case (OpCode)
            // R-TYPE (Ej. ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
            7'b0110011: begin
                RUWr = 1'b1; 
                ImmSrc = 3'b000; 
                ALUASrc = 1'b0; 
                ALUBSrc = 1'b0; 
                DMWr = 1'b0; 
                DMCtrl = 3'b000; 
                BrOp = 5'b00000; 
                RUDataWrSrc = 2'b00;
                // ALUOp depende de Funct3 y Funct7 (debe mapearse a la ALU.sv)
                case ({Funct7, Funct3})
                    10'b0000000_000: ALUOp = 4'b0000; // ADD
                    10'b0100000_000: ALUOp = 4'b1000; // SUB
                    10'b0000000_001: ALUOp = 4'b0001; // SLL
                    10'b0000000_010: ALUOp = 4'b0010; // SLT 
                    10'b0000000_011: ALUOp = 4'b0011; // SLTU
                    10'b0000000_100: ALUOp = 4'b0100; // XOR
                    10'b0000000_101: ALUOp = 4'b0101; // SRL
                    10'b0100000_101: ALUOp = 4'b1101; // SRA
                    10'b0000000_110: ALUOp = 4'b0110; // OR
                    10'b0000000_111: ALUOp = 4'b0111; // AND
                    //COMO SERIA PARA ALURES = B???
                    
                endcase
            end

            // I-TYPE (Ej. ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI)
            7'b0010011: begin
                RUWr = 1'b1; 
                ImmSrc = 3'b000; 
                ALUASrc = 1'b0; 
                ALUBSrc = 1'b1; 
                DMWr = 1'b0; 
                DMCtrl = 3'b000; 
                BrOp = 5'b00000; 
                RUDataWrSrc = 2'b00;
                // ALUOp depende de Funct3
                case (Funct3)
                    3'b000: ALUOp = 4'b0000; // ADDI
                    3'b001: ALUOp = 4'b0001; // SLLI
                    3'b010: ALUOp = 4'b0010; // SLTI
                    3'b011: ALUOp = 4'b0011; // SLTIU
                    3'b100: ALUOp = 4'b0100; // XORI
                    3'b101: begin
                        // Diferenciar SRLI vs SRAI usando Funct7[5] (bit 30 de instr)
                        if (Funct7[5]) 
                            ALUOp = 4'b1101; // SRAI (Arithmetic)
                        else 
                            ALUOp = 4'b0101; // SRLI (Logical)
                    end
                    3'b110: ALUOp = 4'b0110; // ORI
                    3'b111: ALUOp = 4'b0111; // ANDI
                    default: ALUOp = 4'b0000;
                endcase
            end

            // LOAD (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                RUWr = 1'b1; 
                ALUOp = 4'b0000; 
                ImmSrc = 3'b000; 
                ALUASrc = 1'b0; 
                ALUBSrc = 1'b1; 
                DMWr = 1'b0; 
                BrOp = 5'b00000; 
                RUDataWrSrc = 2'b01; 
                 // ALUOp = 4'b0000 ADD (para calcular dirección)
                // DMCtrl depende de Funct3 (para el tipo de carga)
                case (Funct3)
                    3'b000: DMCtrl = 3'b000; // LB
                    3'b001: DMCtrl = 3'b001; // LH
                    3'b010: DMCtrl = 3'b010; // LW
                    3'b100: DMCtrl = 3'b100; // LBU
                    3'b101: DMCtrl = 3'b101; // LHU
                    //jalr como se implementa???
                endcase
            end

            // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                RUWr = 1'b0; 
                ALUOp = 4'b0000; 
                ImmSrc = 3'b010; // CORREGIDO: B-Type es 010 en ImmGen 
                ALUASrc = 1'b1; 
                ALUBSrc = 1'b1; 
                DMWr = 1'b0; 
                DMCtrl = 3'b000; 
                RUDataWrSrc = 2'b00;
                 // ALUOp = 4'b1000 SUB (para comparación)
                // BrOp depende de Funct3
                BrOp = {2'b01, Funct3}; // Ejemplo de mapeo
                case (Funct3)
                    3'b000: BrOp = {2'b01, Funct3}; // LB
                    3'b001: BrOp = {2'b01, Funct3}; // LH
                    3'b100: BrOp = {2'b01, Funct3}; // LW
                    3'b101: BrOp = {2'b01, Funct3}; // LBU
                    3'b110: BrOp = {2'b01, Funct3}; // LHU
                    3'b111: BrOp = {2'b01, Funct3}; // LHU
                    //muchas dudas con esta parte branch???
                endcase
            end

            // STORE (SB, SH, SW)
            7'b0100011: begin
                RUWr = 1'b0; 
                ALUOp = 4'b0000; 
                ImmSrc = 3'b001; 
                ALUASrc = 1'b0; 
                ALUBSrc = 1'b1; 
                DMWr = 1'b1; 
                BrOp = 5'b00000; 
                RUDataWrSrc = 2'b00;
                 // ALUOp = 4'b0000 ADD (para calcular dirección)
                // DMCtrl depende de Funct3 (para el tipo de almacenamiento)
                case (Funct3)
                    3'b000: DMCtrl = 3'b000; // SB
                    3'b001: DMCtrl = 3'b001; // SH
                    3'b010: DMCtrl = 3'b010; // SW
                endcase
            end

            //JAL
            7'b1101111: begin
                RUWr = 1'b1; 
                ALUOp = 4'b0000; 
                ImmSrc = 3'b011; // J-Type (Corregido de 3'b110 a 3'b011 según ImmGen)
                ALUASrc = 1'b1; // PC
                ALUBSrc = 1'b1; // Imm
                DMWr = 1'b0; 
                DMCtrl = 3'b000; 
                BrOp = 5'b10000; // Jump incondicional
                RUDataWrSrc = 2'b10; // PC+4
            end

            // JALR
            7'b1100111: begin
                RUWr = 1'b1;
                ALUOp = 4'b0000; // ADD
                ImmSrc = 3'b000; // I-Type
                ALUASrc = 1'b0; // Rs1
                ALUBSrc = 1'b1; // Imm
                DMWr = 1'b0;
                DMCtrl = 3'b000;
                BrOp = 5'b10000; // Jump incondicional
                RUDataWrSrc = 2'b10; // PC+4
            end

            default: ; 
        endcase
    end
    
endmodule